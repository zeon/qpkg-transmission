<?php
/************************************************************************

	Status Checking

	**********************************************
	- File:			check.php
	- Date:			Oct 11th, 2010
	- Version:		1.0
	- Author:		AdNovea (Laurent)
	- Modified by:	Andy Chuo (QNAPAndy)
	- Description:  Start/Stop/Check the Transmission 

*************************************************************************/
	
	define("RUNNING",	TRANSMISSION_RUNNING);
	define("STOPPED",	TRANSMISSION_NOT_RUNNING);

	$frontend_name = $_GET['frontend_name'];
	$name = $_POST['name'];

	// Stop or Restart application (doesn't always work !!!)
	if ($_GET['restart'] == 1) exec(WRITE_HTTP."transmission=start".WRITE_LOG);
	if ($_GET['restart'] == 2) exec(WRITE_HTTP."transmission=stop".WRITE_LOG);
	if ($_GET['frontend_name'] != NULL) exec(WRITE_HTTP."change_frontend=".$frontend_name."".WRITE_LOG);
	if (isset($_GET['restart'])) sleep(7);

	// Check if transmission.pid exists and if Transmission is running
	if (file_exists(TRANSMISSION_PID_FILE)) $is_running = RUNNING; else $is_running = STOPPED;
?>
 
