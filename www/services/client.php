<?php
	header("Content-type: text/html; charset=utf-8");
	ini_set('soap.wsdl_cache_enabled', '0');
	$client=new SoapClient("soap.wsdl");
	echo("<br />");
	$query = "SELECT MeasureVal,Explaination FROM TSemaphore";
//	$query = "SELECT * FROM TSemaphore";
	echo $client->sqlite3($query);
	
// 	$db = new SQLite3('history.db');
	
// 	$results = $db->query('SELECT * FROM TSemaphore');
// 	while ($row = $results->fetchArray()) {
// 		echo $row['Id'];
// 		echo("<br />");
// 	}
	
?>