<?php
/************************************************************************

	Main menu page

	**********************************************
	- File:			index.php
	- Date:			Sep 8th, 2010
	- Version:		1.0
	- Author:		AdNovea (Laurent)
	- Modified by:	Andy Chuo (QNAPAndy)
	- Description:  PMS Admin main page

*************************************************************************/

	require(".config/conf.php");
	add_language_list("index");
	include('.config/header.php');

	// Check applications status and Start/Stop servers
	include('.config/check.php');

	// Display sections
	load_language("menu");	// Load common language strings
	set_js_vars();

	// Top panel pulldown for PMS admin center
	echo "
	<div id='header'>
		<div class='meat'>
			<h1><span>Transmission</span></h1>
			<div id='tagline'><span>A Fast, Easy, and Free BitTorrent Client</span></div>
			<div id='tagline2'></div>
			<div id='gearshift'></div>
		</div>
	</div>
	<div style='display: table; height: 500px; overflow: hidden; margin: auto;'>
		<div style='display: table-cell; vertical-align: middle;'>
			<div class='wrapper floatholder'>
				<div class='cssParsedBox' id='iconimg'>$is_running</div>
				<div id='main'>";					
					echo "					
					<div id='accordion'>
						<h3 class='toggler'>
							<table cellspacing='0' border='0'>
								<tr align='left'>
									<td align='left' style='padding-left: 15px;'><img border='0' src='images/arrow.gif' alt=''></td>
									<td width='80'>&nbsp;"._MENU_APP_STARTER."</td>
								</tr>
							</table>
						</h3>
						<div class='element'>
							<table cellspacing='0' border='0' style='margin-left: 10px; width: 275px;'>
								<tr>
									<td width='10'></td>
									<td valign='top' align='center'>						 
										<a href='?lid=$lid&amp;restart=1'><img border='0' src='images/start.png' alt='start pms' width='40'></a>
									</td>
									<td valign='top' align='center'>	
										<a href='?lid=$lid&amp;restart=2'><img border='0' src='images/stop.png' alt='stop pms' width='40'></a>
									</td>
									<td width='0'></td>										
								</tr>
								<tr>
									<td width='10'></td>								
									<td valign='top' align='center'>						 
										<span>"._MENU_START_TRANSMISSION."</span>
									</td>
									<td valign='top' align='center'>	
										<span>"._MENU_STOP_TRANSMISSION."</span>
									</td>
									<td width='10'></td>										
								</tr>
								<tr height='8'></tr>
							</table>
						</div>";											
						echo "
						<h3 class='toggler'>
							<table cellspacing='0' border='0'>
								<tr align='left'>
									<td align='left' style='padding-left: 15px;'><img border='0' src='images/arrow.gif' alt=''></td>
									<td width='190'>&nbsp;"._MENU_CONFIG_EDITOR."</td>
								</tr>
							</table>
						</h3>
						<div class='element'>
							<table cellspacing='0' border='0' style='margin-left: 10px; width: 275px;'>
								<tr>
									<td width='10'></td>
									<td align='left' style='padding-left: 15px;'>
										<a href='.config/edit.php?lid=$lid&amp;cfg=transmission_conf&amp;file=conf/settings.json&amp;action=save' rev='$lb_size' rel='lightbox[conf1]'><img border='0' src='images/document_edit.png' alt='' width='40'></a><br>
									</td>
								</tr>
								<tr>
									<td width='10'></td>
									<td align='left'>						 
										<span>"._MENU_SETTINGS_JSON."</span>
									</td>
								</tr>
								<tr height='8'></tr>
							</table>
						</div>";
						echo "
						<h3 class='toggler'>
							<table cellspacing='0' border='0'>
								<tr align='left'>
									<td align='left' style='padding-left: 15px;'><img border='0' src='images/arrow.gif' alt=''></td>
									<td width='190'>&nbsp;"._MENU_UTILITIES."</td>
								</tr>
							</table>
						</h3>
						<div class='element'>
							<table cellspacing='0' border='0' style='margin-left: 10px; width: 275px;'>
								<tr>
									<td align='center'>
										<a href='.config/edit.php?lid=$lid&amp;cfg=email_notify&amp;file=scripts/email_notifier/config&amp;action=save' rev='$lb_size' rel='lightbox[conf2]'><img border='0' src='images/email.png' alt='' width='40'></a><br>
									</td>
									<td align='center'>
										<a href='.config/edit.php?lid=$lid&amp;cfg=max_running_torrents&amp;file=scripts/max-running-torrents/config&amp;action=save' rev='$lb_size' rel='lightbox[conf3]'><img border='0' src='images/max_jobs.png' alt='' width='40'></a><br>
									</td>
									<td align='center'>
										<a style='cursor: pointer;' onclick=\"javascript:  jQuery('#dialog_frontend').dialog('open');\"><img border='0' src='images/frontend.png' alt='' width='40'></a><br>
									</td>
									<td align='center'>
										<a style='cursor: pointer;' onclick=\"javascript: jQuery('input:radio[name=frontend_name]').filter('[value=".CUR_FRONTEND."]').attr('checked','checked'); jQuery('#dialog_frontend_changer').dialog('open');\"><img border='0' src='images/frontend_changer.png' alt='' width='40'></a><br>
									</td>										
								</tr>
								<tr>
									<td align='center'>						 
										<span>"._MENU_EMAIL_NOTIFIER."</span>
									</td>
									<td align='center'>							 
										<span>"._MENU_MAX_RUNNING_JOBS."</span>
									</td>
									<td align='center'>								 
										<span>"._MENU_DOWNLOADS."</span>
									</td>	
									<td align='center'>						 
										<span>"._MENU_FRONTEND_CHANGER."</span>
									</td>									
								</tr>
								<tr height='5'></tr>
							</table>
						</div>";						
						echo "
						<h3 class='toggler'>
							<table cellspacing='0' border='0'>
								<tr align='left'>
									<td align='left' style='padding-left: 15px;'><img border='0' src='images/arrow.gif' alt=''></td>
									<td width='190'>&nbsp;"._MENU_LOG_VIEWER."</td>
								</tr>
							</table>
						</h3>
						<div class='element'>
							<table cellspacing='0' border='0' style='margin-left: 10px; width: 275px;'>
								<tr>
									<td width='5'></td>	
									<td align='center' width='89'>
										<a style='cursor: pointer;' onclick=\"javascript: jQuery('#dialog_console').dialog('open'); TimerRun = true; TimerSet = false; loadFile(1);\">
											<img border='0' src='images/console.png' width='40'><br>
										</a>
									</td>										
									<td width='260'></td>		
								</tr>									
								<tr>
									<td width='5'></td>	
									<td align='center' width='89'>						 
										<span>"._MENU_LOG_CONSOLE."</span>
									</td>
									<td></td>
								</tr>
								<tr height='8'></tr>
							</table>
						</div>
					</div> <!-- accordion -->
				</div> <!-- main -->				
			</div> <!-- wrapper floatholder -->
		</div>
	</div>
	<div id='footer'><a href='docs/README' rev='$lb_size' rel='lightbox[xdove-gpl]'>"._COPYRIGHTS."</a></div>
	<div id='dialog_console' title='Log Console [".TRANSMISSION_DEBUG_LOG_NAME."]'>
		<div class='contentdiv'>
			<div id='console' style='width: 765px; height: 380px;'></div>
			<form method='post' name='input' target='_blank' action='logs/transmission.log'>
				<small> 
					<input type='submit' value='Download log'/>
				</small>
			</form>
			
		</div>
	</div>
	<div id='dialog_frontend' title='Frontend Downloads'>
		<div id='frontend_logo'><img src='images/logo2.png' alt='Transmission Logo' /></div>
		<h2 class='dialog_heading'>Transmission Remote GUI</h2>
		<div class='dialog_message'>
			<p>Transmission Remote GUI is a cross platform, fast and feature rich  front-end to control the Transmission torrent daemon remotely. It provide many more funcationalities then the built-in web front-end and is available for download from the links below. Choose the operating system you intend to use it on.</p>
			<br /><p>version 2.1.1</p><br />
			<div id='download_link'>
				<a href='http://transmisson-remote-gui.googlecode.com/files/transgui-2.1.1-setup.exe'>Windows&nbsp;&nbsp;</a>|
				<a href='http://transmisson-remote-gui.googlecode.com/files/transgui-2.1.1.dmg'>Mac OS X&nbsp;&nbsp;</a>|
				<a href='http://transmisson-remote-gui.googlecode.com/files/transgui-2.1.1-i386-linux.zip'>Linux i386&nbsp;&nbsp;</a>|
				<a href='http://transmisson-remote-gui.googlecode.com/files/transgui-2.1.1-x86_64-linux.zip'>Linux x86_64</a>
			</div>
		</div>
		<hr style='width:95%; margin-bottom:20px;'>
		<div id='frontend_logo'><img src='images/welcomefinish.png' alt='Transmission Logo' /></div>
		<h2 class='dialog_heading'>Transmission Remote dotnet</h2>
		<div class='dialog_message'>
			<p>Transmission-remote-dotnet is a Windows remote client to the RPC interface of transmission-daemon, which is part of the Transmission BitTorrent client. The application is quite like uTorrent in appearance and currently supports almost all the RPC specification.</p>
			<br /><p>version 3.23beta</p><br />
			<div id='download_link'>
				<a href='http://transmission-remote-dotnet.googlecode.com/files/transmission-remote-dotnet-3.23beta-installer.exe'>Windows</a>
			</div>
		</div>
		<hr style='width:95%; margin-bottom:20px;'>
		<div id='frontend_logo'><img src='images/logo3.png' alt='Transdroid Logo' /></div>
		<h2 class='dialog_heading'>Transdroid - Remote torrent client for Android</h2>
		<div class='dialog_message'>				
			<p>Transdroid is an Android remote client for your torrent application running on a server or home computer. Currently Transmission, uTorrent, Bittorrent, Deluge, Vuze and rTorrent are supported. It can show the active torrents, pause, resume or remove them and new torrents can be added via URL, RSS feed or using the integrated search.</p>
			<br /><p>version 0.21.0</p><br />
			<div id='download_link'>
				<a href='http://transdroid.googlecode.com/files/transdroid-0.21.0.apk'>Android</a>
			</div>
			<img src='images/transdroid_qrcode.png' alt='Transdroid QR Code' style='float: left; margin: 10px 0 ; clear: both;'/>
			<br />
			<br />
		</div>
		
	</div>
	<div id='dialog_frontend_changer' title='Frontend Changer'>
		<form name='testing' action=''>
			<div id='radio' style='float: left'>
				<input type='radio' id='radio1' name='frontend_name' value='default' />
				<label for='radio1'>Default</label>
				<input type='radio' id='radio2' name='frontend_name' value='gearbox' />
				<label for='radio2'>Gearbox</label>
				<input type='radio' id='radio3' name='frontend_name' value='kettu' />
				<label for='radio3'>Kettu</label>			
			</div>	
			<input id='button' value='Apply' type='submit' style='height:20px; width:50px; margin: 5px 0 5px 5px'; font-size: 10px;/>	
			<div id='toggler'>
				<div id='default' class='ui-widget-content ui-corner-all' style='margin:20px 0; padding: 10px;'>
					<b>Transmission Default Web Frontend</b><br /><br />
					<p>
						This is the default Transmission web frontend.
					</p>
				</div>
				<div id='gearbox' class='ui-widget-content ui-corner-all' style='margin:20px 0; padding: 10px;'>
					<b>Gearbox</b><br /><br />
					<p>
						A simple web gui for Transmission.
					</p>
				</div>
				<div id='kettu' class='ui-widget-content ui-corner-all' style='margin:20px 0; padding: 10px;'>
					<b>Kettu</b><br /><br />
					<p>
						Rewrite of the Transmission Web Client with jQuery, Sammy and Mustache .
					</p>
				</div>
			</div>	
		</form>
	</div>
  ";
	include('.config/footer.php');

?>

