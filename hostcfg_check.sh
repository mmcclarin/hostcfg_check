#!/bin/bash
#NAGIOS SCRIPT TO CHECK IF THE IP ADDRESSES IN THE CONFIGURATION FILE IS THE SAME RETURNED BY NSLOOKUP.
#WRITTEN BY MIKE MCCLARIN (mike@mcclarin.net)

#VARIABLES##################################
#NAGIOS HOSTS.CFG FILE
HOST_CFG="/usr/local/nagios/etc/hosts.cfg"
SUPP_ADDR="email@address.com"
DNS_SERVER="172.26.1.1"
############################################

NAGIOS_SERVER=`hostname`
EXCEPTIONS="etc/exception_hosts"
LOC=`pwd`

#get host names
cat $HOST_CFG | grep host_name | sed -n -e '{s/.*host_name *//p}' > etc/host_names
#get ip addresses
cat $HOST_CFG | grep address | sed -n -e '{s/.*address *//p}' | sed -e 's/^[ \t]*//' > etc/ip_addresses

i="0"
host_names_count=`cat etc/host_names | wc -l`
ip_addresses_count=`cat etc/ip_addresses | wc -l`
echo $host_names_count
echo $ip_addresses_count

#VERIFY THAT THE SAME NUMBER OF ROWS ARE RETURNED FOR EACH
if [ $host_names_count != $ip_addresses_count ]
then
echo "FAIL"
mail -s "There was a problem running the hostcfg_check on $NAGIOS_SERVER located in $LOC" $SUPP_ADDR <<END
There was a problem running the hostcfg_check on $NAGIOS_SERVER.

The file is in $LOC. Please investigate why this is not running properly. 

There are an unequal number of hosts an ip addresses.
END
else
echo "SUCCESS"
fi


HOST_NAMES=($(<etc/host_names));
IP_ADDRESSES=($(<etc/ip_addresses));
echo $HOST_NAMES
echo $IP_ADDRESSES

#DEBUG
#host_names_count="5"
#DEBUG

while [ $i -lt $host_names_count ]
do

HOST_NAME="${HOST_NAMES[$i]}"
IP_ADDRESS="${IP_ADDRESSES[$i]}"
NS_LOOKUP=`nslookup $HOST_NAME $DNS_SERVER | grep Address: | sed -n -e '{s/.*Address: *//p}' | sed -e 's/^[ \t]*//' | cut -d"#"  -f 10`
echo "Host Name: "$HOST_NAME
echo "NS Lookup: "$NS_LOOKUP
echo "Nagios IP: "$IP_ADDRESS
num=$(($i + 1))

cat $EXCEPTIONS | grep $HOST_NAME > etc/exception
EXCEPTION=`cat etc/exception`
##DEBUG
#echo $EXCEPTION
##DEBUG

if [ ! -s $EXCEPTION ]; then
echo "Skipping $EXCEPTION since it is in the exceptions list"
elif [[ $NS_LOOKUP =~ $IP_ADDRESS ]]; then
echo "SUCCESS"
else
echo "FAIL"
mail -s "$HOST_NAME is incorrectly configured in nagios on $NAGIOS_SERVER" $SUPP_ADDR <<END
The NSLOOKUP for $HOST_NAME is incosistent with the nagios configuration file. Please see below for investigation. 

Please see below for the following nagios configuration file and dns server:
TimeStamp for Check:            `date`
Nagios Configuration File:      $NAGIOS_SERVER:$HOST_CFG
DNS SERVER:                     $DNS_SERVER

Host Name (should be the same for nslookup and nagios configuration):
$HOST_NAME

Nagios IP Address Configured in nagios configuration:
$IP_ADDRESS

NSLookup Results:
$NS_LOOKUP

If this host should be excepted from this check, please add the hostname to the following file:
$NAGIOS_SERVER:$LOC/$EXCEPTIONS

END
fi

echo "Line" $num "of" $host_names_count "processed"
echo "**********"
i=$((i+1))
done
