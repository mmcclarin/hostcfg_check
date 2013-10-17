hostcfg_check
=============
Contributors: Mike McClarin (mike@mcclarin.net)
License: GPLv2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html

== Description ==
Script to check if IP address is the same in Nagios as in DNS lookup

== Installation ==

This section describes how to install hostcfg_check.sh and get it working.


e.g.

1. Upload hostcfg_check.tar.gz to the nagios server you want to check (usually to the nagios root)
2. Unzip the folder
3. Open hostcfg_check.sh and edit the variables for HOST_CFG (Nagios hosts.cfg file. Usually in nagios/etc/hosts.cfg) and SUPP_ADDR (Email address to notify of problems) and edit DNS_SERVER to reflect the DNS Server you want to check against.
4. To add exception hosts to not process, add them to etc/exception_hosts
5. Create a cronjob to run hostcfg_check.sh as often as you want (daily, weekly, etc)

== Frequently Asked Questions ==

== Changelog ==

= 1.0 =
* Initial Version
