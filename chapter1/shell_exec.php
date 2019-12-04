<?php
	
	$output = shell_exec('bash /data/web/default/kill.sh');
	echo "<pre>$output</pre>";