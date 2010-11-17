<?php
/************************************************************************

	Config file

	- File:			conf.php
	- Date:			Oct 11th, 2010
	- Version:		1.0
	- Author:		AdNovea (Laurent)
	- Modified by:	Andy Chuo (QNAPAndy)
	- Description:  Transmission Admin main config & defines


*************************************************************************/

	$debugging = true;

// Common system variables
	define("_APPS_NAME",		"Transmission Admin Center");
	define("_COPYRIGHTS",		"Transmission Admin Center v0.1 by QNAPAndy.<br>All rights reserved for its respective owners.");
	define("PWD_MIN_LENGHT",	5);			// Minimum number of password characters
	define("DOC_TYPE",			"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1-transitional.dtd\">");
	$lb_size = "width=800, height=450";		// Slimbox dimensions

	define("CMD_AWK",			"/bin/awk");
	define("CMD_CUT",			"/bin/cut");
	define("CMD_GETCFG",		"/sbin/getcfg");
	define("CMD_GREP",			"/bin/grep");
	define("CMD_HOSTNAME",		"/bin/hostname");
	define("CMD_IFCONFIG",		"/sbin/ifconfig");
	define("CMD_PIDOF",			"/bin/pidof");
	define("CMD_PS",			"/bin/ps");
	define("CMD_TAR",			"/bin/tar");
	define("CMD_UNAME",			"/bin/uname");
	define("CMD_WGET",			"/usr/bin/wget");
	define("HTPASSWD",			"/usr/local/apache/bin/htpasswd");
	define("CRONTAB_FILE",		"/etc/config/crontab");
	define("CMD_DATE",			"/bin/date");
	define("CMD_READLINK",		"/usr/bin/readlink");

	
// Get QNAP server type, name and base location (ATTENTION: Do not change the cmds order below !!!)
	define("BASE",				exec(CMD_GETCFG." Public path -f /etc/config/smb.conf | ".CMD_CUT." -c 1-16"));
	if (BASE == "") die("SYSTEM ERROR: Cannot find QNAP server base location!<br>Returns:".BASE);
	define("SYS_MODEL",			exec(CMD_GETCFG." system model", $output));
	define("KERNEL",			exec(CMD_UNAME." -mr | ".CMD_CUT." -d '-'  -f 1 | ".CMD_CUT." -d ' '  -f 1", $output));
	if (KERNEL == "2.6.12.6")	define("CHROOTED",true); else define("CHROOTED",false);
	define("QNAP_NAME",			exec(CMD_HOSTNAME, $output));
	
	$output = null;	exec(CMD_IFCONFIG." eth0 | ".CMD_AWK." '/addr:/{print $2}' | ".CMD_CUT." -f2 -d:", $output);
	if (trim($output[0])!="") define("QNAP_IP", $output[0]);
	else {
		$output = null;	exec(CMD_IFCONFIG." bond0 | ".CMD_AWK." '/addr:/{print $2}' | ".CMD_CUT." -f2 -d:", $output);
		if (trim($output[0])!="") define("QNAP_IP", $output[0]);
		else {
			$output = null; exec(CMD_IFCONFIG." eth1 | ".CMD_AWK." '/addr:/{print $2}' | ".CMD_CUT." -f2 -d:", $output);
			if (trim($output[0])!="") define("QNAP_IP", $output[0]);
			else {
				$output = null; exec(CMD_IFCONFIG." bond1 | ".CMD_AWK." '/addr:/{print $2}' | ".CMD_CUT." -f2 -d:", $output);
				if (trim($output[0])!="") define("QNAP_IP", $output[0]);
				else define("QNAP_IP", "127.0.0.1");
			}
		}
	}
	
	define("QNAP_HTTPD_PORT",		exec(CMD_GETCFG." SYSTEM \"Web Access Port\" -f /etc/config/uLinux.conf"));	// Default is 8080
	define("QNAP_WEB_PORT",			exec(CMD_GETCFG." QWEB Port -u -f /etc/config/uLinux.conf"));				// Default is 80
	define("QNAP_WEB_FOLDER", 		exec(CMD_GETCFG." SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info"));	
	define("QNAP_DOWNLOAD_FOLDER", 		exec(CMD_GETCFG." SHARE_DEF defDownload -d Qdownload -f /etc/config/def_share.info"));

	
	

	
	// Paths, Mail server files and scripts paths
	define("QPKG_ROOTFS",			"/mnt/HDA_ROOT/rootfs_2_3_6/");
	define("TRANSMISSION_ROOT",		BASE.".qpkg/Transmission/");
	define("QWEB_DIR",				"/share/".QNAP_WEB_FOLDER."/");
	define("QDOWNLOAD_DIR",			"/share/".QNAP_DOWNLOAD_FOLDER."/");
	define("TRANSMISSION_WEBDIR",	QWEB_DIR."transmission/");	
	define("LOGS_DIR",				"logs/");	
	define("HTPASSWD_FILE",			"/root/.htpasswd");
	define("TRANSMISSION_PID_FILE",	"/var/run/transmission-daemon.pid");
	define("CUR_FRONTEND", exec(CMD_READLINK." ".TRANSMISSION_ROOT."web | ".CMD_AWK." -F/ '{ print $7}'"));
	
	define("WRITE_HTTP",			CMD_WGET." \"http://127.0.0.1:".QNAP_HTTPD_PORT."/transmission.cgi?");
	
	if ($debugging)
		define("WRITE_LOG",		"\" -O ".TRANSMISSION_WEBDIR.LOGS_DIR."debug.log");
	else 
		define("WRITE_LOG",		"\"");		
	
	define("TRANSMISSION_DEBUG_LOG",		"logs/transmission.log");	
	define("TRANSMISSION_DEBUG_LOG_NAME",	"transmission.log");	

	$HOSTNAME = $_SERVER['SERVER_NAME'] ;
	define("TRANSMISSION_RUNNING",		"Transmission is running and the web interface is at <a href='http://".$HOSTNAME.":9091' target='_blank'>http://".$HOSTNAME.":9091</a>");
	define("TRANSMISSION_NOT_RUNNING",	"Transmission is not running");
	
	// Execute a bash cmd
	function bash($stt, $debug=false) {
		$output = null; $result = exec($stt, $output);
		if ($debug) foreach ($output as $line) echo "==>$line<br>";
		return $result;
	}

// Prepare for Internationalization
	$lid = (isset($_GET['lid']) ? $_GET['lid'] : "English");
	$lid = ($lid!=""?$lid:"en_US");
	$rootfolder = dirname(__FILE__)."/../";
	include($rootfolder."langs/languages.php");

// Add language droplist 
	function add_language_list($urlfile) {
		global $languages, $innerBanner, $lid;
		if (isset($_GET['first'])) $first = "&first=".$_GET['first'];
		$innerBanner = "
		<select onchange=\"javascript:location='$urlfile.php?lid='+this.value+'$first';\">";	
		foreach($languages as $key => $lang) {
			$selected = ($lid == $key)?" selected":"";
			$innerBanner .= "<option value=\"$key\"$selected>".$lang["name"]."</option>\r";
		}
		$innerBanner .= "</select>";
	}

// Load language strings
	function load_language($section) { 
		global $lid, $rootfolder, $languages;
		
		$lg = file($rootfolder."langs/".$languages[$lid]['path'].".txt");
		$getstring = false;
		while (list($line,$value) = each($lg)) {
			if($value[0] == "[") {
				if (trim($value) == "[$section]") {
					$getstring = true; 
				} else {
					if ($getstring) break;	// End of section reached
					$getstring = false;
				}
			}
			if ($getstring && strpos(";#",$value[0]) === false && ($pos = strpos($value,"=")) != 0 && trim($value) != "") {
				$varname  = trim(substr($value,0,$pos));
				$varvalue = trim(substr($value,$pos+1));
				define("_".strtoupper($varname),$varvalue);
			}
		}
	}
	load_language("common");	// Load common language strings

// Set javascript variables
	function set_js_vars() { 
		echo "
		<script type='text/javascript'>
			<!--
			var bt_close='"._BT_CLOSE."';	// Internationalization of the Slimbox close button
			//-->
		</script>";
	}

// Get XDove base URL
	$root = $_SERVER['PHP_SELF']; 	
	$root = str_replace(".config/","",$root);
	$root = str_replace("docs/","",$root);
	$root = str_replace("auto_install/","",$root);
	$root = str_replace(basename($root),"",$root);
	$URL_site = "$root";
?>
