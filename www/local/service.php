<?php
	class service
	{
		public function sqlite3( $sql )
		{
 			$db = new SQLite3('history.db');
 			$result = "";
 			if(!$db)
 			{
 				return $db->lastErrorMsg();
 			}else
 			{
 				$results = $db->query( $sql );
 				$strings = "";
	 			while ($row = $results->fetchArray()) 
	 			{
				    $string=$row[0]."&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp".$row[1];
				    $strings = $strings."<br />".$string;
				}
			
				$db->close();
				return $sql."<br />".$strings;
			}
		}
	}
?>