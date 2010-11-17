#!/bin/sh

# Script that checks for finished downloads in Transmission and
# sends email to a specified user.
# This code placed into public domain

# Requires:
#   GNU mailutils | bsd-mailx (does not work with heirloom-mailx)
#   lockfile-progs
#   transmission-cli

# History:
#----------------------------------------------------------------------------
# Date        | Author <EMail>                  | Description               |
#----------------------------------------------------------------------------
# 04 May 2009 | A.Galanin <gaa.nnov AT mail.ru> | Creation                  |
# 04 May 2009 | A.Galanin <gaa.nnov AT mail.ru> | Usage moved before locking|
#----------------------------------------------------------------------------

QPKG_DIR=
MAIL_CONTENT="\nDownloading of \"%s\" has been finished.\nGo to %s to make an approriate action.\n"

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
                QPKG_DIR=${BASE}/.qpkg/Transmission
        fi
}

find_base

# files
FILEPATH="$QPKG_DIR/scripts/email_notifier"
CONFIG_FILE="$FILEPATH/config"
NOTIFY_FILE="$FILEPATH/notified"
ALL_FILE="$FILEPATH/tmp/checkFinishedTransmissionDownloads.all"
TMP_FILE="$FILEPATH/tmp/checkFinishedTransmissionDownloads.tmp"
LOCK_FILE="$FILEPATH/tmp/checkFinishedTransmissionDownloads"

[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

#------------------------------------------------------------------------------

send_email () {
	tmp=/tmp/mail-body-`date +%F`;
	touch $tmp && chmod 600 $tmp;
	#Set up the various headers for sendmail to use
	TO="$MAILTO";
	CC="$MAILCC";
	MAILFROM="$FROM";
	SUBJECT="Torrents info: $name";
	MIMEVersion="1.0";
	CONTENTType="text/html; charset=us-ascii";
	#Here write the content of your mail.
	BODY="`printf "$MAIL_CONTENT" "$name" "http://$HOST:$PORT/"`"

	echo -e "To: $TO" > $tmp;
	echo -e "Cc: $CC" >> $tmp;
	echo -e "From: $FROM" >> $tmp;
	echo -e "Content-Type: $CONTENTType" >> $tmp;
	echo -e "MIME-Version: $MIMEVersion" >> $tmp;
	echo -e "Subject: $SUBJECT" >> $tmp;
	echo -e "Body: $BODY" >> $tmp;

	/usr/sbin/sendmail -t < $tmp;	
	rm $tmp;
}

# Call transmission-remote with corresponding parameters
callTransmission () {
echo "$HOST"
if [ "$RPC_AUTH" -eq 0 ]; then
	transmission-remote $HOST:$PORT "$@"
else
	transmission-remote $HOST:$PORT -N "$TMP_FILE" "$@"
fi
}

# Remove lock and temporary files, exit with code $1
exitAndClean () {
	kill "$LOCK_PID"
	lockfile-remove "$LOCK_FILE"
	rm -f "$TMP_FILE" "$ALL_FILE"
	
	exit "$1"
}

# initialization
if [ $# != 0 ]
then
	echo "$0: check for finished downloads in Transmission"
	echo "USAGE: $0"
	exit 1
fi

lockfile-create "$LOCK_FILE" || (echo "Unable to lock lockfile!"; exitAndClean 2)
lockfile-touch "$LOCK_FILE" &
LOCK_PID="$!"

trap "exitAndClean 1" HUP INT QUIT KILL

mkdir -p "$FILEPATH"
touch "$NOTIFY_FILE" "$TMP_FILE"
echo -n > "$ALL_FILE"
chmod 600 "$TMP_FILE" "$ALL_FILE"
# generate netrc file for RPC authorisation
printf "machine %s\nlogin %s\npassword %s\n" "$HOST" "$USER" "$PASS" > "$TMP_FILE"

# main
callTransmission -l | gawk '{
	if ($1 != "Sum:" && $1 != "ID") {
		print $1,$2
	}
}' | while read id percent
do
	reply="`callTransmission -t "$id" -i | grep -E '^  Name|^  Hash'`"

	name="`echo "$reply" | grep '^  Name'  | cut -c 9-`"
	hash="`echo "$reply" | grep '^  Hash'  | cut -c 9-`"

	# check that notification is not yet sent
	grep -q "$hash" "$NOTIFY_FILE"
	if [ $? = 1 -a "$percent" = "100%" ]
	then
		send_email
		echo "$hash" >> "$NOTIFY_FILE"
	
	fi
	echo "$hash" >> "$ALL_FILE"
done

# remove deleted torrents from sent notifications list
sort "$NOTIFY_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$NOTIFY_FILE"

sort "$ALL_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$ALL_FILE"

comm -1 -2 "$NOTIFY_FILE" "$ALL_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$NOTIFY_FILE"

exitAndClean 0