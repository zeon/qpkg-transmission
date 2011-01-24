<?php
	/************************************************************************

	Transmission config editor
	
	**********************************************
	- File:			edit.php
	- Date:			Oct 11th, 2010
	- Version:		1.0
	- Author:		AdNovea (Laurent)
	- Modified by:	Andy Chuo (QNAPAndy)
	- Description:  Transmission config editor

*************************************************************************/

	require("conf.php");
	
	$viewconfig = $_POST['viewconfig'];
	$save_it = $_POST['save_it'];
	$cfg = $_GET['cfg'];
	$file = $_GET['file'];
	$action = (isset($_GET['action'])?$_GET['action']:"");
	$email_notifier_enabled = $_POST['enabled'];
	$from = $_POST['from'];
	$mailto = $_POST['mailto'];
	
	echo "
	<html>
	<head>
		<meta http-equiv='Content-Type' content='text/html; charset="._CHARSET."'>
		<link href='".$URL_site."css/jquery-ui.css' rel='stylesheet' type='text/css' >
		<script src='".$URL_site."js/jquery.min.js'></script>
	</head>
	<body>";
		
	load_language("edit_file");	// Load language strings for configuration file edition
	set_js_vars();
	echo "<script type=\"text/javascript\" language=\"javascript\">editor=true;
		$(document).ready( function(){
			if ($('#radio1:checked').val() == null) {
				$('.email_config').attr('disabled','disabled');
			}
		});
		</script>";
	
	if (CHROOTED) $chrooted = QPKG_ROOTFS; else $chrooted = ""; 

	switch ($cfg) {
		case "transmission_conf": 
			exec(WRITE_HTTP."config=1".WRITE_LOG);
			$loadcontent = TRANSMISSION_ROOT.$file; 
			$title = "Settings.json Configuration";
			break;		
		case "max_running_torrents":	
			exec(WRITE_HTTP."config=1".WRITE_LOG);
			$loadcontent = TRANSMISSION_ROOT.$file; 
			$title = "Max. Running Torrents";
			break;
		case "email_notify":	
			exec(WRITE_HTTP."config=1".WRITE_LOG);
			$loadcontent = TRANSMISSION_ROOT.$file; 
			$ini_array = parse_ini_file($loadcontent);
			$title = "Email Notification";
			break;
		default: die('System error');
	}

	if ($save_it == "1") {		
		if ($cfg == "transmission_conf") {
			
			$savecontent = stripslashes($viewconfig);
			$fp = @fopen($loadcontent, "w");
			if ($fp) {
				fwrite($fp, $savecontent);
				fclose($fp);			
			} else $msg = _EDIT_CANNOT_SAVE." &nbsp; ";
		}
		if ($cfg == "max_running_torrents") {			
			exec(WRITE_HTTP."max_running_torrents=1".WRITE_LOG);
		}
		if ($cfg == "email_notify"){

			exec("setcfg Main ENABLE " . ($email_notifier_enabled == 'enabled'? "1":"0") . " -f " . TRANSMISSION_ROOT.$file);
			if($email_notifier_enabled == 'enabled') {
				exec("setcfg Main FROM " . $from . " -f " . TRANSMISSION_ROOT.$file);
				exec("setcfg Main MAILTO " . $mailto . " -f " . TRANSMISSION_ROOT.$file);
			}
			exec(WRITE_HTTP."email_notify=1".WRITE_LOG);
		}
	}
	if (!file_exists($loadcontent)) {
		$action = "";
		$loadcontent = _EDIT_NOFILE;
	} else {
		$fp = @fopen($loadcontent, "r");
		$loadcontent = fread($fp, filesize($loadcontent));
		$loadcontent = htmlspecialchars($loadcontent);
		fclose($fp);
	}	

	echo "
		<style type='text/css'>
			textarea {
				width: 100%;
				height: 400px;
				font: 12px Tahoma, Courier New;
				color: #dddddd;
				background-color: #525252;			
			}		
			#viewconfig {
				width: 99%; 
				height: 380px;	
				font-variant: normal; 
				font: normal 12px Courier New; 
				line-height: normal; 
				font-size-adjust: none; 
				font-stretch: normal; 
			}			
			.button {
				padding: 2px 5px 1px 5px;
				font-size: 11px;
				color: #2F3A55;
				border: 1px solid #DCDCC6;
				background-color: #aaa;				
			}
		</style>
		<form style='position: absolute; top: 0px; left: 0px;' method=post action=\"".$_SERVER['PHP_SELF']."?&amp;lid=$lid&amp;cfg=$cfg&amp;file=$file&amp;action=$action\">
			<div id='dialog_console' class='ui-dialog ui-widget ui-widget-content ui-corner-all  ui-draggable' style='left: 0px; right: 0pt; width: 791px;'>
				<div class='ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix' style='height: 25px; width: 787px; margin: 0 0 10px; padding: 4px 0 0;'>
					<span class='ui-dialog-title' style='padding: 0 0 0 10px; font-family: Trebuchet MS,Tahoma,Verdana,Arial,sans-serif; font-size: 13px;'>$title ";
					if($msg == 'conf/settings.json') echo "<span style='font-size: 10px;'>(<a href='https://trac.transmissionbt.com/wiki/EditConfigFiles#Options' target='_blank'>Reference of configuration options)</a></span>"; echo "</span>";
					
					if ($action == "save") echo "<input type='submit' value='"._BT_SAVE."' name='save_file' class='button' style='float: right; height:15px; font-size:11px; font-weight:normal; height:21px; width: 50px; margin-right:60px;'>";
				echo "
				</div>";
				if($cfg == 'transmission_conf')
					echo "<textarea name=\"viewconfig\" id=\"viewconfig\">$loadcontent</textarea>";
				if($cfg == 'email_notify') {
					echo "<div style='font-size: 12px; padding-left:10px;'>
						Enable/Disable the email notifier when a torrent download job is finished.<br />";
						exec("getcfg Main ENABLE -f " . TRANSMISSION_ROOT.$file, $enabled);
						if ($enabled[0] == '1'){
							$checked1 = 'checked = "true"';
							$checked2 = '';
						}
						else{
							$checked1 = '';
							$checked2 = 'checked = "true"';
						}
						echo "
						<label for='enabled'><span>Enable </span></label>
						<input type='radio' id='radio1' name='enabled' value='enabled' $checked1 onclick=\"$('.email_config').removeAttr('disabled'); \"/>
						<label for='enabled'><span>Disable </span></label>
						<input type='radio' id='radio2' name='enabled' value='disabled' $checked2 onclick=\"$('.email_config').attr('disabled','disabled')\"/><br /><br />";
						echo "
						Specify the name of the sender you wish to see in the mail notification<br />
						<input type='text' class='email_config' name='from' value='" . $ini_array['FROM'] . "'><br /><br />";
						echo "
						Specify the email address you wish to receive the notification mail<br />
						<input type='text' class='email_config' name='mailto' value='" . $ini_array['MAILTO']. "'><br /><br /></div>";
				}
				echo "<input type=\"hidden\" name=\"save_it\" value=\"1\">
			</div>
		</form>";
	include('footer.php');
	
?>
