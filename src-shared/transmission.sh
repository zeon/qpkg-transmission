#!/bin/sh
### BEGIN INIT INFO
# Provides:          transmission-daemon
# Required-Start:    networking
# Required-Stop:     networking
# Default-Start:     2 3 5
# Default-Stop:      0 1 6
# Short-Description: Start the transmission BitTorrent daemon client.
### END INIT INFO
# Modified by Maarten Van Coile & others (on IRC)

DOWNLOAD_SHARE=`/sbin/getcfg SHARE_DEF defDownload -d Qdownload -f /etc/config/def_share.info`
PUBLIC_SHARE=`/sbin/getcfg SHARE_DEF defPublic -d Public -f /etc/config/def_share.info`
WEB_SHARE=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
QPKG_NAME=Transmission
QPKG_DIR=
FRONTEND_NAME=

_exit()
{
    /bin/echo -e "Error: $*"
    /bin/echo
    exit 1
}

# Determine BASE installation location according to smb.conf
find_base() {	
	BASE=""
	DEV_DIR="HDA HDB HDC HDD HDE HDF HDG HDH MD0 MD1 MD2 MD3"
	publicdir=`/sbin/getcfg Public path -f /etc/config/smb.conf`
	if [ ! -z $publicdir ] && [ -d $publicdir ];then
		BASE=`echo $publicdir |awk -F/Public '{ print $1 }'`
	else
		for datadirtest in $DEV_DIR; do
			[ -d /share/${datadirtest}_DATA/Public ] && BASE=/share/${datadirtest}_DATA
		done
	fi
	if [ -z $BASE ]; then
		echo "The base directory cannot be found."
		_exit 1
	else
		QPKG_DIR=${BASE}/.qpkg/${QPKG_NAME}
	fi
}

find_base

export LD_LIBRARY_PATH=${QPKG_DIR}/lib
export EVENT_NOEPOLL=0

USERNAME=admin
GROUPNAME=administrators
TRANSMISSION_HOME="${QPKG_DIR}/conf"
TRANSMISSION_WEB_HOME="${QPKG_DIR}/web"
TRANSMISSION_ARGS="--blocklist --config-dir $TRANSMISSION_HOME --logfile /share/${DOWNLOAD_SHARE}/transmission/logs/debug.log"

DESC="bittorrent client"
NAME=transmission-daemon
DAEMON=/usr/bin/transmission-daemon
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

init_check() {
	if [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` = UNKNOWN ]; then
		/sbin/setcfg ${QPKG_NAME} Enable TRUE -f /etc/config/qpkg.conf
	elif [ `/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf` != TRUE ]; then
		echo "${QPKG_NAME} is disabled."
	#	_exit
	fi
}

create_dir() {
	[ -d "/share/${DOWNLOAD_SHARE}/transmission" ] || /bin/mkdir "/share/${DOWNLOAD_SHARE}/transmission"
	/bin/chmod 777 /share/$DOWNLOAD_SHARE/transmission
	[ -d "/share/${DOWNLOAD_SHARE}/transmission/completed" ] || /bin/mkdir "/share/${DOWNLOAD_SHARE}/transmission/completed"
	/bin/chmod 777 /share/$DOWNLOAD_SHARE/transmission/completed
	[ -d "/share/${DOWNLOAD_SHARE}/transmission/incomplete" ] || /bin/mkdir -p "/share/${DOWNLOAD_SHARE}/transmission/incomplete"
	/bin/chmod 777 /share/$DOWNLOAD_SHARE/transmission/incomplete
	[ -d "/share/${DOWNLOAD_SHARE}/transmission/watch" ] || /bin/mkdir -p "/share/${DOWNLOAD_SHARE}/transmission/watch"
	/bin/chmod 777 /share/$DOWNLOAD_SHARE/transmission/watch
    [ -d "/share/${DOWNLOAD_SHARE}/transmission/logs" ] || /bin/mkdir -p "/share/${DOWNLOAD_SHARE}/transmission/logs"
    /bin/chmod 777 /share/$DOWNLOAD_SHARE/transmission/logs
}

create_links(){
	DIRS="bin"
	for i in $DIRS
	do
		j="`/bin/ls ${QPKG_DIR}/$i`"
		for k in $j
		do
			l="/usr"
			[ $i = "etc" ] && l=""
			[ ! -e "$l/$i/$k" ] && /bin/ln -sf "${QPKG_DIR}/$i/$k" $l/$i/$k
		done
	done

	if [[ "`uname -m`" = "armv5tejl" || "`uname -m`" = "armv5tel" ]]; then
		export LD_LIBRARY_PATH=${QPKG_DIR}/lib
		[ -f /usr/lib/libevent-1.4.so.2 ] || ln -sf ${QPKG_DIR}/lib/libevent-1.4.so.2.2.0 /usr/lib/libevent-1.4.so.2
		[ -f /usr/lib/libssl.so.0.9.8 ] || ln -sf ${QPKG_DIR}/lib/libssl.so.0.9.8 /usr/lib/libssl.so.0.9.8
		[ -f /usr/lib/libcrypto.so.0.9.8 ] || ln -sf ${QPKG_DIR}/lib/libcrypto.so.0.9.8 /usr/lib/libcrypto.so.0.9.8
	fi

	[ -d /share/${WEB_SHARE}/transmission ] || ln -sf ${QPKG_DIR}/web-gui/admin /share/${WEB_SHARE}/transmission
	[ -f /home/httpd/transmission.cgi ] || ln -sf /share/${WEB_SHARE}/transmission/transmission.cgi /home/httpd/
	[ -d ${QPKG_DIR}/web ] || ln -sf ${QPKG_DIR}/web-gui/default ${QPKG_DIR}/web
	[ -f /etc/init.d/max-running-torrents.sh ] || ln -sf ${QPKG_DIR}/scripts/max-running-torrents/max-running-torrents.sh /etc/init.d/
	
	ln -sf ${QPKG_DIR}/bin/sort /usr/bin/sort
	ln -sf ${QPKG_DIR}/bin/bash /bin/bash
}

setup_log_file() {
	[ -f /share/$DOWNLOAD_SHARE/transmission/logs/debug.log ] || /bin/touch /share/$DOWNLOAD_SHARE/transmission/logs/debug.log
	
	# if it's too large
	SIZE="`/bin/ls -al /share/"$DOWNLOAD_SHARE"/transmission/logs/debug.log |awk '{ print $5 }'`"
	if [ "$SIZE" -gt "2048" ]; then
		/bin/rm /share/$DOWNLOAD_SHARE/transmission/logs/debug.log
		/bin/touch /share/$DOWNLOAD_SHARE/transmission/logs/debug.log
	fi
    chmod -R 777 /share/$DOWNLOAD_SHARE/transmission/logs
	[ -f /share/$WEB_SHARE/transmission/logs/transmission.log ] || ln -sf /share/$DOWNLOAD_SHARE/transmission/logs/debug.log /share/$WEB_SHARE/transmission/logs/transmission.log
}

change_permission() {
	grep transmission /etc/passwd 1>/dev/null
	if [ "$?" != "0" ]; then
		delgroup transmission 2>/dev/null
		/bin/adduser -DH $USERNAME 2>/dev/null
	fi

    grep transmission /etc/group 1>/dev/null
    if [ "$?" != "0" ]; then
		addgroup transmission 2>/dev/null
	fi	
	chown -R ${USERNAME}.${GROUPNAME} ${QPKG_DIR}/conf
	chmod 666 ${QPKG_DIR}/scripts/email_notifier/config
	chmod 666 ${QPKG_DIR}/scripts/max-running-torrents/config
	chmod 666 ${QPKG_DIR}/conf/settings.json
	chmod +x ${QPKG_DIR}/scripts/run_scripts.sh
	chmod +x ${QPKG_DIR}/scripts/email_notifier/email_notifier.sh
}

setup_email_notifier() {	
	if [ `/sbin/getcfg Main ENABLE -f ${QPKG_DIR}/scripts/email_notifier/config` -eq 1 ]; then
		echo "Hooking to the run_scripts.sh ..."
		grep email_notifier ${QPKG_DIR}/scripts/run_scripts.sh 1>/dev/null
		[ "$?" != "0" ] && echo -e "${QPKG_DIR}/scripts/email_notifier/email_notifier.sh" >> ${QPKG_DIR}/scripts/run_scripts.sh
	else
		echo "Removing from the run_scripts.sh... "
		grep email_notifier ${QPKG_DIR}/scripts/run_scripts.sh 1>/dev/null
		[ "$?" = "0" ] && /bin/sed -i '/email_notifier/d' ${QPKG_DIR}/scripts/run_scripts.sh
	fi
}

max_running_torrents() {
	if [ -f ${QPKG_DIR}/scripts/max-running-torrents/config ]; then
		/sbin/dos2unix -u ${QPKG_DIR}/scripts/max-running-torrents/config
		/bin/chmod 666 ${QPKG_DIR}/scripts/max-running-torrents/config
		. ${QPKG_DIR}/scripts/max-running-torrents/config 
	fi
	
	if [ "$ONLY_START_TORRENTS" = "$ONLY_PAUSE_TORRENTS" ]; then
		echo "You can only choose to set max running jobs to start or pause torrents."
		exit 1
	fi

	if [ "${ENABLE}" -eq "1" ]; then
		OPT="-m %s %s -- -n %s:%s"	
		TEMP=$ONLY_START_TORRENTS
		if [ "$TEMP" = "0" ]; then
			TEMP="-p"
		else
			TEMP="-s"
		fi
		ARGS=`printf -- "$OPT" "$MAX_ACTIVE" "$TEMP" "$RPC_USERNAME" "$RPC_PASSWORD"`

		echo "Hooking to the run_scripts.sh ..."
		echo -e "\n/etc/init.d/max-running-torrents.sh "$ARGS"" >> ${QPKG_DIR}/scripts/run_scripts.sh
	else
		echo "Removing from the run_scripts.sh... "
		grep max-running-torrents ${QPKG_DIR}/scripts/run_scripts.sh 1>/dev/null
		[ "$?" = "0" ] && /bin/sed -i '/max-running-torrents/d' ${QPKG_DIR}/scripts/run_scripts.sh
	fi
}

change_web_frontend() {	
	FRONTEND_AVAIL="default gearbox kettu"
	FRONTEND_NAME=$1
	for frontend_name in $FRONTEND_AVAIL; do 
		if [ "$FRONTEND_NAME" = "$frontend_name" ]; then
			/bin/rm ${QPKG_DIR}/web
			/bin/ln -sf ${QPKG_DIR}/web-gui/$FRONTEND_NAME ${QPKG_DIR}/web
		fi
	done
	/bin/kill -1 `cat $PIDFILE`
	sleep 3
}

#
# Function that starts the daemon/service
#
do_start()
{
	init_check
    create_links
	create_dir
	setup_log_file
	change_permission

	# Start apache if it's not enabled
	/etc/init.d/Qthttpd.sh restart 1>/dev/null 2>/dev/null

	# Export the configuration/web directory, if set
    if [ -n "$TRANSMISSION_HOME" ]; then
          export TRANSMISSION_HOME
    fi
    if [ -n "$TRANSMISSION_WEB_HOME" ]; then
          export TRANSMISSION_WEB_HOME
    fi

    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    ${QPKG_DIR}/bin/start-stop-daemon --chuid $USERNAME --start --pidfile $PIDFILE --make-pidfile --exec $DAEMON --background --test -- -f $TRANSMISSION_ARGS > /dev/null || return 1
    
    ${QPKG_DIR}/bin/start-stop-daemon --chuid $USERNAME --start --pidfile $PIDFILE --make-pidfile --exec $DAEMON --background -- -f $TRANSMISSION_ARGS || return 2
}
    
#
# Function that stops the daemon/service
#
do_stop()
{
        # Return
        #   0 if daemon has been stopped
        #   1 if daemon was already stopped
        #   2 if daemon could not be stopped
        #   other if a failure occurred
        ${QPKG_DIR}/bin/start-stop-daemon --stop --quiet --retry=TERM/10/KILL/5 --pidfile $PIDFILE --name $NAME
        RETVAL="$?"
        [ "$RETVAL" = 2 ] && return 2

        # Wait for children to finish too if this is a daemon that forks
        # and if the daemon is only ever run from this initscript.
        # If the above conditions are not satisfied then add some other code
        # that waits for the process to drop all resources that could be
        # needed by services started subsequently.  A last resort is to
        # sleep for some time.

        ${QPKG_DIR}/bin/start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
        [ "$?" = 2 ] && return 2

        # Many daemons don't delete their pidfiles when they exit.
        rm -f $PIDFILE

        return "$RETVAL"
}

case "$1" in
	start)
        echo "Starting $DESC" "$NAME..."
        do_start
        case "$?" in
                0|1) echo "   Starting $DESC $NAME succeeded" ;;
                *)   echo "   Starting $DESC $NAME failed" ;;
        esac
        ;;
	stop)
        echo "Stopping $DESC $NAME..."
        do_stop
        case "$?" in
                0|1) echo "   Stopping $DESC $NAME succeeded" ;;
                *)   echo "   Stopping $DESC $NAME failed" ;;
        esac
        ;;
	restart|force-reload)
        #
        # If the "reload" option is implemented then remove the
        # 'force-reload' alias
        #
        echo "Restarting $DESC $NAME..."
        do_stop
        case "$?" in
          0|1)
                do_start
                case "$?" in
                    0|1) echo "   Restarting $DESC $NAME succeeded" ;;
                    *)   echo "   Restarting $DESC $NAME failed: couldn't start $NAME" ;;
                esac
                ;;
          *)
                echo "   Restarting $DESC $NAME failed: couldn't stop $NAME" ;;
        esac
        ;;		
	config)
		echo "Configuring settings.json..."
		change_permission
		;;
	max-running-torrents)
		echo "Setting max running torrents... "
		max_running_torrents
		;;		
	change_frontend)
		echo "Changing the web frontend... "
		change_web_frontend "$2"
		;;
	setup_email_notifier)
		echo "Setting up email notifier... "
		setup_email_notifier
		;;
  *)
        echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload|config|max-running-torrents|convert|change_frontend|setup_email_notifier}" >&2
        exit 3
        ;;
esac


