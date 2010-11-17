#!/bin/sh

WEB_SHARE=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`


/bin/rm /usr/bin/transmission-* /home/httpd/transmission.cgi /usr/bin/lockfile* /share/${WEB_SHARE}/transmission /home/httpd/transmission.cgi /etc/init.d/max-running-torrents.sh /bin/bash /usr/bin/sort


deluser transmission
delgroup transmission

/usr/bin/crontab -l > /tmp/tmp_crontab
grep email_notifier /tmp/tmp_crontab 1>/dev/null
[ "$?" = "0" ] && sed -i '/email_notifier/d' /tmp/tmp_crontab
/usr/bin/crontab /tmp/tmp_crontab
rm /tmp/tmp_crontab


