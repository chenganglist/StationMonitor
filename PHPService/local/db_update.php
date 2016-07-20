<?php

$db = new SQLite3 ( 'history.db' );	// 连接sqlite3数据库
if (! $db)
{
	return "Error";
} else
{
	$in_UserName="root";
	$in_Password="roow";
	$fsuId="51012413300001";
	
	$q1=$db->exec ( "update FTPINFO set UserName='$in_UserName' where FSUID='$fsuId'" );	//更新UserName
	$q2=$db->exec ( "update FTPINFO set Password='$in_Password' where FSUID='$fsuId'" );	//更新Password
	
	echo $q1."  ".$q2."<br>";

	$result = $db->query ( "select * from FTPINFO where FSUID='$fsuId'" );	//查询更新后的数据
	$row = $result->fetchArray ( SQLITE3_ASSOC );
	
	echo $row ['UserName']."<br>";
	echo $row ['Password']."<br>";
	
	$res1=$row ['UserName'] == $in_UserName?1:0;	//判断UserName是否更新成功
	$res2=$row ['Password'] == $in_Password?1:0;	//判断Password是否更新成功
	
	if ($res1 && $res2)	//如果全部都更新成功
		echo "Yes";
	else
		echo "No";
}

?>