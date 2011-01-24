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

#------------------------------------------------------------------------------

send_email () {
	tmp=`mktemp transmission.XXXXXXXXXX`
	#Set up the various headers for sendmail to use
	TO=`/sbin/getcfg Main MAILTO -f ${QPKG_DIR}/scripts/email_notifier/config`;
	MAILFROM=`/sbin/getcfg Main FROM -f ${QPKG_DIR}/scripts/email_notifier/config`;
	SUBJECT="Torrent [$TR_TORRENT_NAME] done!";
	MIMEVersion="1.0";
	CONTENTType="text/html; charset=us-ascii";
	#Here write the content of your mail.
	BODY="\nTransmission finished downloading [$TR_TORRENT_NAME] to the directory [$TR_TORRENT_DIR].\n"

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

send_email
