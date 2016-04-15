<?php
class FSUService
{
	public function invoke($xmlData)
	{
		$xmlData_doc = simplexml_load_string ( $xmlData ); // 把输入xml字符串转为simplexml对象
		$code_xml_str = $xmlData_doc->PK_Type->Code->asXML (); // 获取Code节点的内容，字符串
		
		$code = substr ( $code_xml_str, 6, 4 ); // 默认取<code>1001</code>的中间4位，第6个字符后取4位
		if (substr ( $code, 3, 1 ) == '<') // 处理<code>401</code>的情况，通过上述步骤获取了4013<，在这里要去掉最后一个字符<
			$code = substr ( $code, 0, 3 );
		
		if ($code == '401') // code为401是用户请求监控点数据
		{
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				$devices_arr = array (); // 一位数组 存放所有设备的ID，比如51012410600001、51012410700001
				$TSemaphore_arr = array (); // 二维数组， 存放所有设备的所有监控点的ID，比如0118102001、0106022001
				                            // $TSemaphore_arr[i][j]=0118102001表示第i个设备第j个监控点是0118102001
				                            
				// 如果Device ID号为999999999999,则返回所有设备所有监控点的值
				if (substr ( $xml_in_doc->Info->DeviceList->Device ['Code']->asXML (), 7, 14 ) == '99999999999999')
				{
					
					$result = $db->query ( "SELECT distinct DeviceID FROM TSemaphore" ); // 从数据库中获取所有的设备ID
					
					$i = 0;
					while ( $row = $result->fetchArray ( SQLITE3_ASSOC ) )
					{
						$devices_arr [$i] = $row ['DeviceID']; // 设备ID加入$devices_arr中
						
						$result1 = $db->query ( "SELECT * FROM TSemaphore where DeviceID='$devices_arr[$i]'" ); // 以设备ID为搜索条件查询此设备所有监控点的ID
						$j = 0;
						while ( $row1 = $result1->fetchArray ( SQLITE3_ASSOC ) )
						{
							
							$TSemaphore_arr [$i] [$j ++] = $row1 ['Id']; // 从数据库查询监控点ID加入$TSemaphore_arrr中
						}
						
						$i ++;
					}
				} else
				{
					$i = 0;
					foreach ( $xml_in_doc->Info->DeviceList->Device as $in_device )
					{
						
						preg_match_all ( '#"(.*?)"#i', $in_device ['Id']->asXML (), $in_device_matches ); // 去掉冒号，因为$in_device ['Id']->asXML ()直接返回"51012411800001"
						$devices_arr [$i] = $in_device_matches [1] [0]; // 设备ID加入$devices_arr中
						                                                
						// 如果ID号为9999999999,则返回该设备所有监控点的值
						if (substr ( $in_device->ID [0]->asXML (), 4, 10 ) == '9999999999')
						{
							
							$result = $db->query ( "SELECT * FROM TSemaphore where DeviceID='$devices_arr[$i]'" ); // 以设备ID为搜索条件查询此设备所有监控点的ID
							$j = 0;
							
							while ( $row = $result->fetchArray ( SQLITE3_ASSOC ) )
							{
								// echo $row['ID']."<br>";
								$TSemaphore_arr [$i] [$j ++] = $row ['Id']; // 从数据库查询监控点ID加入$TSemaphore_arrr中
							}
						} else
						{
							
							$j = 0;
							foreach ( $xml_in_doc->Info->DeviceList->Device [$i]->ID as $in_id )
							{
								$TSemaphore_arr [$i] [$j] = substr ( $in_id->asXML (), 4, 10 ); // 提取出xml中监控点ID再加入$TSemaphore_arrr中
								$j ++;
							}
						}
						
						$i ++;
					}
				}
				
				// print_r($devices_arr);
				// echo "<br>";
				// print_r($TSemaphore_arr);
				// echo "<br>";
				
				// 生成xml文件
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
    <PK_Type>
        <Name>GET_DATA_ACK</Name>
        <Code>402</Code>
    </PK_Type>
    <Info>
        <FsuId/>
		<FsuCode/>
        <Result/>
        <Values>
            <DeviceList>
            </DeviceList>
        </Values>
    </Info>
</Response>
XML;
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				
				$i = 0;
				foreach ( $devices_arr as $data_device ) // 依次遍历$devices_arr每一个设备
				{
					
					$xml_out_doc->Info->Values->DeviceList->addChild ( "Device", "" ); // 添加一个名为Device的新节点
					$xml_out_doc->Info->Values->DeviceList->Device [$i]->addAttribute ( "Code", $data_device ); // Device节点添加Code属性
					$xml_out_doc->Info->Values->DeviceList->Device [$i]->addAttribute ( "Id", $data_device ); // Device节点添加Id属性
					
					for($j = 0; $j < count ( $TSemaphore_arr [$i] ); $j ++) // 遍历设备$devices_arr[i]下的所有监控点
					{
						
						// echo $TSemaphore_arr [$i] [$j] . "<br>";
						
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->addChild ( "TSemaphore", null ); // 添加一个名为TSemaphore的新节点
						
						$TSemaphore_value = $TSemaphore_arr [$i] [$j];
						
						$result = $db->query ( "SELECT * FROM TSemaphore where DeviceID='$devices_arr[$i]' and ID='$TSemaphore_value'" ); // 从数据库中查询此监控点的信息
						$row = $result->fetchArray ( SQLITE3_ASSOC );
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$j]->addAttribute ( "Status", $row ['Status'] ); // 为TSemaphore添加Status属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$j]->addAttribute ( "SetupVal", sprintf("%.1f", $row ['SetupVal'])); // 为TSemaphore添加SetupVal属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$j]->addAttribute ( "MeasuredVal", sprintf("%.1f",$row ['MeasureVal'])); // 为TSemaphore添加MeasuredVal属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$j]->addAttribute ( "Id", $TSemaphore_value ); // 为TSemaphore添加Id属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$j]->addAttribute ( "Type", $row ['Type'] ); // 为TSemaphore添加Type属性
					}
					
					$i ++;
				}
				
				$xml_out_doc->Info->Result = 1; // 设置返回结果
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				
				$db->close (); // 关闭数据
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		
		if ($code == '403') // code为403是用户请求监控点历史数据
		{
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把字符串$xmlData转为simplexml对象
				$devices_arr = array (); // 一位数组 存放所有设备的ID，比如51012410600001、51012410700001
				$TSemaphore_arr = array (); // 二维数组， 存放所有设备的所有监控点的ID，比如0118102001、0106022001
				                            // $TSemaphore_arr[i][j]=0118102001表示第i个设备第j个监控点是0118102001
				                            
				// 如果Device ID号为999999999999,则返回所有设备所有监控点的值
				if (substr ( $xml_in_doc->Info->DeviceList->Device ['Code']->asXML (), 7, 14 ) == '99999999999999')
				{
					
					$result = $db->query ( "SELECT distinct DeviceID FROM TSemaphore" ); // 从数据库中获取所有的设备ID
					
					$i = 0;
					while ( $row = $result->fetchArray ( SQLITE3_ASSOC ) )
					{
						$devices_arr [$i] = $row ['DeviceID']; // 设备ID加入$devices_arr中
						
						$result1 = $db->query ( "SELECT * FROM TSemaphore where DeviceID='$devices_arr[$i]'" ); // 以设备ID为搜索条件查询此设备所有监控点的ID
						$j = 0;
						while ( $row1 = $result1->fetchArray ( SQLITE3_ASSOC ) )
						{
							
							$TSemaphore_arr [$i] [$j ++] = $row1 ['Id']; // 从数据库查询监控点ID加入$TSemaphore_arrr中
						}
						
						$i ++;
					}
				} else
				{
					$i = 0;
					foreach ( $xml_in_doc->Info->DeviceList->Device as $in_device )
					{
						
						preg_match_all ( '#"(.*?)"#i', $in_device ['Id']->asXML (), $in_device_matches ); // 去掉冒号，因为$in_device ['Id']->asXML ()直接返回"51012411800001"
						$devices_arr [$i] = $in_device_matches [1] [0]; // 设备ID加入$devices_arr中
						                                                
						// 如果ID号为9999999999,则返回该设备所有监控点的值
						if (substr ( $in_device->ID [0]->asXML (), 4, 10 ) == '9999999999')
						{
							
							$result = $db->query ( "SELECT * FROM TSemaphore where DeviceID='$devices_arr[$i]'" ); // 以设备ID为搜索条件查询此设备所有监控点的ID
							$j = 0;
							
							while ( $row = $result->fetchArray ( SQLITE3_ASSOC ) )
							{
								// echo $row['ID']."<br>";
								$TSemaphore_arr [$i] [$j ++] = $row ['Id']; // 从数据库查询监控点ID加入$TSemaphore_arrr中
							}
						} else
						{
							
							$j = 0;
							foreach ( $xml_in_doc->Info->DeviceList->Device [$i]->ID as $in_id )
							{
								$TSemaphore_arr [$i] [$j] = substr ( $in_id->asXML (), 4, 10 ); // 提取出xml中监控点ID再加入$TSemaphore_arrr中
								$j ++;
							}
						}
						
						$i ++;
					}
				}
				
				$start_time = substr ( $xml_in_doc->Info->StartTime->asXML (), 11, 19 ); // 获取查询开始时间
				$end_time = substr ( $xml_in_doc->Info->EndTime->asXML (), 9, 19 ); // 获取查询结束时间
				                                                                    
				// print_r($devices_arr);
				                                                                    // echo "<br>";
				                                                                    // print_r($TSemaphore_arr);
				                                                                    // echo "<br>";
				                                                                    
				// 生成xml文件
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
    <PK_Type>
        <Name>GET_HISDATA_ACK</Name>
        <Code>404</Code>
    </PK_Type>
    <Info>
        <FsuId/>
		<FsuCode/>
        <Result/>
        <Values>
            <DeviceList>
            </DeviceList>
        </Values>
    </Info>
</Response>
XML;
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				
				$i = 0;
				foreach ( $devices_arr as $data_device ) // 依次遍历$devices_arr每一个设备
				{
					
					$xml_out_doc->Info->Values->DeviceList->addChild ( "Device", "" ); // 添加一个名为Device的新节点
					$xml_out_doc->Info->Values->DeviceList->Device [$i]->addAttribute ( "Code", $data_device ); // Device节点添加Code属性
					$xml_out_doc->Info->Values->DeviceList->Device [$i]->addAttribute ( "Id", $data_device ); // Device节点添加Id属性
					
					$k = 0;
					for($j = 0; $j < count ( $TSemaphore_arr [$i] ); $j ++) // 遍历设备$devices_arr[i]下的所有监控点
					{
						
						$TSemaphore_value = $TSemaphore_arr [$i] [$j];
						$result = $db->query ( "SELECT * FROM TSemaphore_history where DeviceID='$devices_arr[$i]' and ID='$TSemaphore_value' and (Time between '$start_time' and '$end_time')" );
						// 从数据库中查询此监控点在开始时间到结束时间这个范围里所偶数据
						
						while ( $row = $result->fetchArray () )
						{
							$xml_out_doc->Info->Values->DeviceList->Device [$i]->addChild ( "TSemaphore", null ); // 添加一个名为TSemaphore的新节点
							$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$k]->addAttribute ( "Status", $row ['Status'] ); // 为TSemaphore添加Status属性
							$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$k]->addAttribute ( "SetupVal", $row ['SetupVal'] ); // 为TSemaphore添加SetupVal属性
							$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$k]->addAttribute ( "MeasuredVal", $row ['MeasureVal'] ); // 为TSemaphore添加MeasuredVal属性
							$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$k]->addAttribute ( "Id", $TSemaphore_value ); // 为TSemaphore添加Id属性
							$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$k]->addAttribute ( "Type", $row ['Type'] ); // 为TSemaphore添加Type属性
							$xml_out_doc->Info->Values->DeviceList->Device [$i]->TSemaphore [$k]->addAttribute ( "RecordTime", $row ['Time'] ); // 为TSemaphore添加Time属性
							$k ++;
						}
					}
					
					$i ++;
				}
				
				$xml_out_doc->Info->Result = 1; // 设置返回结果
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				
				$db->close (); // 关闭数据
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 */
		if ($code == '1001') // code为1001是用户请求写监控点的设置值
		{
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				
				$devices_arr = array (); // 一位数组 存放所有设备的ID，比如51012410600001、51012410700001
				$TSemaphore_id_arr = array (); // 二维数组， 存放所有设备的所有监控点的ID，比如0118102001、0106022001
				                               // $TSemaphore_arr[i][j]=0118102001表示第i个设备第j个监控点是0118102001
				$SET_POINT_TThreshold_val_arr = array (); // 一位数组 存放所有设置数据，比如$SET_POINT_TSemaphore_val_arr['0118102001']表示0118102001的设置值
				
				$i = 0;
				foreach ( $xml_in_doc->Info->Value->DeviceList->Device as $in_device ) // 从输入的文件中循环读取Device节点
				{
					preg_match_all ( '#"(.*?)"#i', $in_device ['Id']->asXML (), $matches ); // 去掉冒号，因为$in_device ['Id']->asXML ()直接返回"51012411800001"
					$devices_arr [$i] = $matches [1] [0]; // 设备ID加入$devices_arr中
					
					$ii = 0;
					foreach ( $xml_in_doc->Info->Value->DeviceList->Device [$i]->TSemaphore as $in_TThreshold ) // 从Device【$i]父节点循环读取ID字节点
					{
						preg_match_all ( '#"(.*?)"#i', $in_TThreshold ['Id']->asXML (), $matches ); // 去掉冒号，因为$in_TSemaphore['Id']->asXML ()直接返回"0106017001"
						$in_TThreshold_id = $matches [1] [0];
						
						$TSemaphore_id_arr [$i] [$ii ++] = $in_TThreshold_id; // 监控点ID加入$in_TSemaphore_id中
						
						preg_match_all ( '#"(.*?)"#i', $in_TThreshold ['SetupVal']->asXML (), $matches ); // 去掉冒号，因为$in_TSemaphore ['SetupVal']->asXML ()直接返回"20.0"
						$SET_POINT_TThreshold_val_arr [$in_TThreshold_id] = $matches [1] [0]; // 监控点ID为$in_TSemaphore_id的设置值加入$SET_POINT_TSemaphore_val_arr中
					}
					
					$i ++;
				}
				
				// print_r($devices_arr);
				// echo "<br>";
				// print_r($TSemaphore_id_arr);
				// echo "<br>";
				// print_r($SET_POINT_TSemaphore_val_arr);
				
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
	<PK_Type>
		<Name>SET_POINT_ACK</Name>
		<Code>1002</Code>
	</PK_Type>
	<Info>
		<FsuId/>
		<FsuCode/>
		<Result/>
		<DeviceList>
		</DeviceList>
	</Info>
</Response>
XML;
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				                                                   
				// 修改数据库中的数据
				
				for($i = 0; $i < count ( $devices_arr ); $i ++) // 依次遍历$devices_arr每一个设备
				{
					$xml_out_doc->Info->DeviceList->addChild ( "Device", "" ); // 添加一个名为Device的新节点
					$xml_out_doc->Info->DeviceList->Device [$i]->addAttribute ( "Code", $devices_arr [$i] ); // Device节点添加Code属性
					$xml_out_doc->Info->DeviceList->Device [$i]->addAttribute ( "Id", $devices_arr [$i] ); // Device节点添加Id属性
					$xml_out_doc->Info->DeviceList->Device [$i]->addChild ( "SuccessList", null ); // 添加一个名为SuccessList的新节点
					$xml_out_doc->Info->DeviceList->Device [$i]->addChild ( "FailList", null ); // 添加一个名为FailList的新节点
					
					for($j = 0; $j < count ( $TSemaphore_id_arr [$i] ); $j ++) // 遍历设备$devices_arr[i]下的所有监控点
					{
						
						// echo $TSemaphore_id_arr[$i][$j]."<br>";
						$TSemaphore_id = $TSemaphore_id_arr [$i] [$j]; // 从$TSemaphore_id_arr取出第i个设备的第j监控点的ID
						$SetupVal = $SET_POINT_TThreshold_val_arr [$TSemaphore_id]; // 从$SET_POINT_TSemaphore_val_arr取出监控点的ID为$TSemaphore_id的设置值
						                                                            
						// $result=$db->exec("update TSemaphore set SetupVal=$SetupVal where ID='$TSemaphore_id'");
						                                                            
						// 预留的处理
						                                                            // if($TSemaphore_id=='0106202001') //均充控制
						                                                            // {
						                                                            
						// }
						                                                            // else if($in_TSemaphore_id=='0106310001') //直流输出电压过低设定值
						                                                            // {
						                                                            
						// }
						                                                            // else if($in_TSemaphore_id=='0106311001') //直流输出电压过高设定值
						                                                            // {
						                                                            
						// }
						                                                            // else if($in_TSemaphore_id=='0115201001') //远程开机
						                                                            // {
						                                                            
						// }
						                                                            // else if($in_TSemaphore_id=='0115202001') //远程关机
						                                                            // {
						                                                            
						// }
						                                                            // else if($in_TSemaphore_id=='0115301001') //运行温度设定
						{
						}
						// el1se if($in_TSemaphore_id=='0117201001') //远程开门
						// {
						
						// }
						
						$db->exec ( "update TSemaphore set SetupVal=$SetupVal where ID='$TSemaphore_id' and DeviceID='$devices_arr[$i]' " ); // 更新数据中监控点的ID为$TSemaphore_id的设置值
						$result = $db->query ( "select * from TSemaphore where ID='$TSemaphore_id'" ); // 查询更新后的监控点的ID为$TSemaphore_id的设置值
						$row = $result->fetchArray ( SQLITE3_ASSOC );
						
						if ($row ['SetupVal'] == $SetupVal) // 如果更新成功
						{
							// echo "SuccessList".$read_TSemaphore_id."<br>";
							$xml_out_doc->Info->DeviceList->Device [$i]->SuccessList->addChild ( "ID", $TSemaphore_id ); // SuccessList节点下添加内容为$TSemaphore_id的ID节点
						} else // 如果更新失败
						{
							
							// echo "FailList".$read_TSemaphore_id."<br>";
							$xml_out_doc->Info->DeviceList->Device [$i]->FailList->addChild ( "ID", $TSemaphore_id ); // FailList节点下添加内容为$TSemaphore_id的ID节点
						}
					}
				}
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				$xml_out_doc->Info->Result = 1; // 设置返回xml的FsuCode
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		
		if ($code == '1901') // code为1901是用户请求监控点门限数据
		{
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				$devices_arr = array (); // 一位数组 存放所有设备的ID，比如51012410600001、51012410700001
				$TThreshold_arr = array (); // 二维数组， 存放所有设备的所有监控点的ID，比如0118102001、0106022001
				                            // $TSemaphore_arr[i][j]=0118102001表示第i个设备第j个监控点是0118102001
				                            
				// 如果Device ID号为999999999999,则返回所有设备所有监控点的值
				if (substr ( $xml_in_doc->Info->DeviceList->Device ['Code']->asXML (), 7, 14 ) == '99999999999999')
				{
					
					$result = $db->query ( "SELECT distinct DeviceID FROM TSemaphore " ); // 从数据库中获取所有的设备ID
					
					$i = 0;
					while ( $row = $result->fetchArray ( SQLITE3_ASSOC ) )
					{
						$devices_arr [$i] = $row ['DeviceID']; // 设备ID加入$devices_arr中
						
						$result1 = $db->query ( "SELECT * FROM TSemaphore where DeviceID='" . $devices_arr [$i] . "'" ); // 以设备ID为搜索条件查询此设备所有监控点的ID
						$j = 0;
						while ( $row1 = $result1->fetchArray ( SQLITE3_ASSOC ) )
						{
							// echo $row['ID']."<br>";
							$TThreshold_arr [$i] [$j ++] = $row1 ['Id']; // 从数据库查询监控点ID加入$TThreshold_arr
						}
						
						$i ++;
					}
				} else
				{
					
					$i = 0;
					foreach ( $xml_in_doc->Info->DeviceList->Device as $in_device )
					{
						preg_match_all ( '#"(.*?)"#i', $in_device ['Id']->asXML (), $in_device_matches ); // 去掉冒号，因为$in_device ['Id']->asXML ()直接返回"51012411800001"
						$devices_arr [$i] = $in_device_matches [1] [0]; // 设备ID加入$devices_arr中
						                                                
						// 如果ID号为9999999999,则返回该设备所有监控点的值
						if ($in_device->ID [0] == null)
						{
							return "ID为空";
						} else if (substr ( $in_device->ID [0]->asXML (), 4, 10 ) == '9999999999')
						{
							
							$result = $db->query ( "SELECT * FROM TSemaphore where DeviceID='" . $devices_arr [$i] . "'" ); // 以设备ID为搜索条件查询此设备所有监控点的ID
							$j = 0;
							
							while ( $row = $result->fetchArray ( SQLITE3_ASSOC ) )
							{
								// echo $row['ID']."<br>";
								$TThreshold_arr [$i] [$j ++] = $row ['Id']; // 从数据库查询监控点ID加入$TThreshold_arr
							}
						} else
						{
							
							$j = 0;
							foreach ( $xml_in_doc->Info->DeviceList->Device [$i]->ID as $in_id )
							{
								$TThreshold_arr [$i] [$j] = substr ( $in_id->asXML (), 4, 10 ); // 提取出xml中监控点ID再加入$TThreshold_arr中
								$j ++;
							}
						}
						
						$i ++;
					}
				}
				// print_r($devices_arr);
				// echo "<br>";
				// print_r($TThreshold_arr);
				// echo "<br>";
				
				// 生成xml文件
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
<PK_Type>
    <Name>GET_THRESHOLD_ACK</Name>
    <Code>1902</Code>
</PK_Type>
<Info>
    <FsuId/>
	<FsuCode/>
    <Result/>
    <Values>
        <DeviceList>
        </DeviceList>
    </Values>
</Info>
</Response>
XML;
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				
				$i = 0;
				foreach ( $devices_arr as $data_device ) // 依次遍历$devices_arr每一个设备
				{
					
					$xml_out_doc->Info->Values->DeviceList->addChild ( "Device", "" ); // 添加一个名为Device的新节点
					$xml_out_doc->Info->Values->DeviceList->Device [$i]->addAttribute ( "Code", $data_device ); // Device节点添加Code属性
					$xml_out_doc->Info->Values->DeviceList->Device [$i]->addAttribute ( "Id", $data_device ); // Device节点添加Id属性
					
					for($j = 0; $j < count ( $TThreshold_arr [$i] ); $j ++) // 遍历设备$devices_arr[i]下的所有监控点
					{
						// echo $TSemaphore_arr[$i][$j]."<br>";
						
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->addChild ( "TThreshold", "" ); // 添加一个名为TThreshold的新节点
						
						$TThreshold_value = $TThreshold_arr [$i] [$j];
						$result = $db->query ( "SELECT * FROM TSemaphore where DeviceID='$devices_arr[$i]' and ID='$TThreshold_value'" ); // 从数据库中查询此监控点的信息
						$row = $result->fetchArray ( SQLITE3_ASSOC );
						
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TThreshold [$j]->addAttribute ( "Type", $row ['Type'] ); // 为TThreshold添加Type属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TThreshold [$j]->addAttribute ( "Id", $TThreshold_arr [$i] [$j] ); // 为TThreshold添加Id属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TThreshold [$j]->addAttribute ( "Threshold", $row ['Threshold'] ); // 为TThreshold添加Threshold属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TThreshold [$j]->addAttribute ( "AbsoluteVal", $row ['AbsoluteVal'] ); // 为TThreshold添加Threshold属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TThreshold [$j]->addAttribute ( "RelativeVal", $row['RelativeVal'] ); // 为TThreshold添加RelativeVal属性
						$xml_out_doc->Info->Values->DeviceList->Device [$i]->TThreshold [$j]->addAttribute ( "Status", $row ['Status'] ); // 为TThreshold添加Status属性
					}
					
					$i ++;
				}
				
				$xml_out_doc->Info->Result = 1; // 设置返回结果
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				$db->close (); // 关闭数据
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		
		if ($code == '2001') // code为2001是用户请求写监控点门限数据
		{
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				
				$devices_arr = array (); // 一位数组 存放所有设备的ID，比如51012410600001、51012410700001
				$TThreshold_id_arr = array (); // 二维数组， 存放所有设备的所有监控点的ID，比如0118102001、0106022001
				                               // $TSemaphore_arr[i][j]=0118102001表示第i个设备第j个监控点是0118102001
				$SET_POINT_TThreshold_val_arr = array (); // 一位数组 存放所有设置数据，比如$SET_POINT_TThreshold_val_arr['0118102001']表示0118102001的设置值
				
				$i = 0;
				foreach ( $xml_in_doc->Info->Value->DeviceList->Device as $in_device ) // 从输入的文件中循环读取Device节点
				{
					preg_match_all ( '#"(.*?)"#i', $in_device ['Id']->asXML (), $matches ); // 去掉冒号，因为$in_device ['Id']->asXML ()直接返回"51012411800001"
					$devices_arr [$i] = $matches [1] [0]; // 设备ID加入$devices_arr中
					
					$ii = 0;
					foreach ( $xml_in_doc->Info->Value->DeviceList->Device [$i]->TThreshold as $in_TThreshold ) // 从Device[$i]父节点循环读取ID字节点
					{
						preg_match_all ( '#"(.*?)"#i', $in_TThreshold ['Id']->asXML (), $matches ); // 去掉冒号，因为$in_TThreshold['Id']->asXML ()直接返回"0106017001"
						$in_TThreshold_id = $matches [1] [0];
						
						$TThreshold_id_arr [$i] [$ii ++] = $in_TThreshold_id; // 监控点ID加入$TThreshold_id_arr中
						                                                      
						
						preg_match_all ( '#"(.*?)"#i', $in_TThreshold ['Threshold']->asXML (), $matches ); // 去掉冒号，因为$in_TThreshold ['Threshold']->asXML ()直接返回"30.0"
						$SET_POINT_TThreshold_val_arr [$in_TThreshold_id] = $matches [1] [0]; // 监控点ID为$in_TThreshold_id的设置值加入$SET_POINT_TThreshold_val_arr中
					}
					
					$i ++;
				}
				
				// print_r($devices_arr);
				// echo "<br>";
				// print_r($TThreshold_id_arr);
				// echo "<br>";
				// print_r($SET_POINT_TSemaphore_val_arr);
				
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
	<PK_Type>
		<Name>SET_THRESHOLD_ACK</Name>
		<Code>2002</Code>
	</PK_Type>
	<Info>
		<FsuId/>
		<FsuCode/>
		<Result/>
		<DeviceList>
		</DeviceList>
	</Info>
</Response>
XML;
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				                                                   
				// 修改数据库中的数据
				
				for($i = 0; $i < count ( $devices_arr ); $i ++) // 依次遍历$devices_arr每一个设备
				{
					$xml_out_doc->Info->DeviceList->addChild ( "Device", "" ); // 添加一个名为Device的新节点
					$xml_out_doc->Info->DeviceList->Device [$i]->addAttribute ( "Code", $devices_arr [$i] ); // Device节点添加Code属性
					$xml_out_doc->Info->DeviceList->Device [$i]->addAttribute ( "Id", $devices_arr [$i] ); // Device节点添加Id属性
					$xml_out_doc->Info->DeviceList->Device [$i]->addChild ( "SuccessList", null ); // 添加一个名为SuccessList的新节点
					$xml_out_doc->Info->DeviceList->Device [$i]->addChild ( "FailList", null ); // 添加一个名为FailList的新节点
					
					for($j = 0; $j < count ( $TThreshold_id_arr [$i] ); $j ++) // 遍历设备$devices_arr[i]下的所有监控点
					{
						
						// echo $TSemaphore_id_arr[$i][$j]."<br>";
						$TThreshold_id = $TThreshold_id_arr [$i] [$j]; // 从 $TThreshold_id_arr取出第i个设备的第j监控点的ID
						$SetupVal = $SET_POINT_TThreshold_val_arr [$TThreshold_id]; // 从$SET_POINT_TThreshold_val_arr取出监控点的ID为$TThreshold_id的设置值
						
						$db->exec ( "update TSemaphore set Threshold=$SetupVal where Id='$TThreshold_id' and DeviceID='$devices_arr[$i]'" ); // 更新数据中监控点的ID为$TThreshold_id的设置值
						$result = $db->query ( "select * from TSemaphore where Id='$TThreshold_id'" ); // 查询更新后的监控点的ID为$TThreshold_id的设置值
						$row = $result->fetchArray ( SQLITE3_ASSOC );
						
						if ($row ['Threshold'] == $SetupVal) // 如果更新成功
						{
							// echo "SuccessList".$read_TSemaphore_id."<br>";
							$xml_out_doc->Info->DeviceList->Device [$i]->SuccessList->addChild ( "Id", $TThreshold_id ); // SuccessList节点下添加内容为$TThreshold_id的ID节点
						} else // 如果更新失败
						{
							
							// echo "FailList".$read_TSemaphore_id."<br>";
							$xml_out_doc->Info->DeviceList->Device [$i]->FailList->addChild ( "Id", $TThreshold_id ); // FailList节点下添加内容为$TThreshold_id的ID节点
						}
					}
				}
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				$xml_out_doc->Info->Result = 1; // 设置返回xml的FsuCode
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		if ($code == '1501') // code为1501是用户获取FSU的注册 信息
		{
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				$fsu_id = substr ( $xml_in_doc->Info->FsuId->asXML (), 7, 14 ); // 从输入文件中获取FsuId
				
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
	<PK_Type>
		<Name>GET_LOGININFO_ACK</Name>
		<Code>1502</Code>
	</PK_Type>
	<Info>
		<FsuId/>
		<FsuCode/>
		<IPSecUser></IPSecUser>
		<IPSecPWD></IPSecPWD>
		<IPSecIP></IPSecIP>
		<SCIP></SCIP>
		<DeviceList>
		</DeviceList>
		<Result></Result>
	</Info>
</Response>
XML;
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				                                                   
				// 查询数据库中的数据
				$result = $db->query ( "SELECT * from FSULOGININFO where FsuId=$fsu_id" ); // 在数据库中查询Fsu的注册信息
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				
				$xml_out_doc->Info->IPSecUser = $row ['IPSecUser']; // 从数据库读取IPSecUser，并写入xml中
				$xml_out_doc->Info->IPSecPWD = $row ['IPSecPWD']; // 从数据库读取IPSecPWD，并写入xml中
				$xml_out_doc->Info->IPSecIP = $row ['IPSecIP']; // 从数据库读取IPSecIP，并写入xml中
				$xml_out_doc->Info->SCIP = $row ['SCIP']; // 从数据库读取SCIP，并写入xml中
				
				$strs = explode ( ',', $row ['DeviceID'] ); // 从数据库读取DeviceID，并写入xml中
				for($i = 0; $i < count ( $strs ); $i ++)
				{
					$xml_out_doc->Info->DeviceList->addChild ( "Device" ); // 添加一个名为Device的新节点
					$xml_out_doc->Info->DeviceList->Device [$i]->addAttribute ( "Code", $strs [$i] ); // Device节点添加Code属性
					$xml_out_doc->Info->DeviceList->Device [$i]->addAttribute ( "Id", $strs [$i] ); // Device节点添加Id属性
				}
				
				$xml_out_doc->Info->Result = 1; // 设置返回xml的结果
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		
		if ($code == '1503') // code为1503是用户设置FSU的注册 信息
		{
			
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				$fsu_id = substr ( $xml_in_doc->Info->FsuId->asXML (), 7, 14 ); // 从输入文件中获取FsuId
				
				$in_IPSecUser = $xml_in_doc->Info->IPSecUser; // 获取请求文件中的IPSecUser
				$in_IPSecPWD = $xml_in_doc->Info->IPSecPWD; // 获取请求文件中的IPSecPWD
				$in_IPSecIP = $xml_in_doc->Info->IPSecIP; // 获取请求文件中的IPSecIP
				$in_SCIP = $xml_in_doc->Info->SCIP; // 获取请求文件中的IPSecUser
				$in_DeviceID_str = "";
				$DeviceID_list=array();
				
				$i = 0;
				foreach ( $xml_in_doc->Info->DeviceList->Device as $in_Device ) // 循环遍历请求文件中的Device
				{
					preg_match_all ( '#"(.*?)"#i', $in_Device ['Id']->asXML (), $in_device_matches ); // 去掉冒号，因为$in_Device ['Id']->asXML ()直接返回"51012410600001"
					$devices_id_value = $in_device_matches [1] [0];
					
					$DeviceID_list[$i]=$devices_id_value;
					
					if ($i != 0)
						$in_DeviceID_str = $in_DeviceID_str . "," . $devices_id_value;
					else
						$in_DeviceID_str = $in_DeviceID_str . $devices_id_value;
					$i ++;
				}

				
$out_xml =<<<XML
<?xml version="1.0" encoding="utf-8"?>
 <Response>
 	<PK_Type>
 		<Name>SET_LOGININFO_ACK</Name>
 		<Code>1504</Code>
 	</PK_Type>
 	<Info>
 		<FsuId/>
 		<FsuCode/>
 		<Result/>
 	</Info>
 </Response>
XML;
				
 				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				
				$db->exec ( "update FSULOGININFO set IPSecUser='$in_IPSecUser' where FSUID=$fsu_id" ); // 更新IPSecUser
				$db->exec ( "update FSULOGININFO set IPSecPWD='$in_IPSecPWD' where FSUID=$fsu_id" ); // 更新IPSecPWD
				$db->exec ( "update FSULOGININFO set IPSecIP='$in_IPSecIP' where FSUID=$fsu_id" ); // 更新IPSecIP
				$db->exec ( "update FSULOGININFO set SCIP='$in_SCIP' where FSUID=$fsu_id" ); // 更新SCIP
				$db->exec ( "update FSULOGININFO set DeviceID='$in_DeviceID_str' where FSUID=$fsu_id" ); // 更新DeviceID
				
				$result = $db->query ( "select * from FSULOGININFO where FSUID=$fsu_id" ); // 查询更新后的数据
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				
				
				
				$res1 = $row ['IPSecUser'] == $in_IPSecUser ? 1 : 0; // 如果IPSecUser更新成功
				$res2 = $row ['IPSecPWD'] == $in_IPSecPWD ? 1 : 0; // 如果IPSecPWD更新成功
				$res3 = $row ['IPSecIP'] == $in_IPSecIP ? 1 : 0; // 如果IPSecIP更新成功
				$res4 = $row ['SCIP'] == $in_SCIP ? 1 : 0; // 如果SCIP更新成功
				$res5 = $row ['DeviceID'] == $in_DeviceID_str ? 1 : 0; // 如果DeviceID更新成功
				
				
				
				$result= $db->query ( "SELECT distinct DeviceID FROM TSemaphore" ); //在TSemaphore数据表中查询原有的DeviceID

				$res6=0;
				
				for($i=0;$i<count($DeviceID_list);$i++)
				{
					$db->exec ( "update FSULOGININFO set IPSecUser='$in_IPSecUser' where FSUID=$fsu_id" );
					
				}
		
				
				if ($res1 && $res2 && $res3 && $res4 && $res5) // 如果全部都更新成功
					$xml_out_doc->Info->Result = 1;
				else
					$xml_out_doc->Info->Result = 0;
				
				
				$db->close (); // 关闭数据库

				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		
		if ($code == '1601') // code为1503是用户获取FSU的用户、密码
		{
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				$fsu_id = substr ( $xml_in_doc->Info->FsuId->asXML (), 7, 14 ); // 从输入文件中获取FsuId
				
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
	<PK_Type>
		<Name>GET_FTP_ACK</Name>
		<Code>1602</Code>
	</PK_Type>
	<Info>
		<FsuId/>
		<FsuCode/>
		<UserName/>
		<Password/>
		<Result/>
	</Info>
</Response>
XML;
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				                                                   
				// 查询数据库中的数据
				$result = $db->query ( "SELECT * from FTPINFO where FsuId=$fsu_id" ); // 在数据库中查询Fsu的注册信息
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				
				$xml_out_doc->Info->UserName = $row ['UserName']; // 从数据库读取UserName，并写入xml中
				$xml_out_doc->Info->Password = $row ['Password']; // 从数据库读取Password，并写入xml中
				$xml_out_doc->Info->Result = 1; // 设置返回xml的结果
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				
				$db->close ();
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		
		if ($code == '1603') // code为1603是用户设置FSU的FTP用户、密码
		{
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
				$fsu_id = substr ( $xml_in_doc->Info->FsuId->asXML (), 7, 14 ); // 从输入文件中获取FsuId
				                                                                
				// 获取请求文件中的数据
				$in_UserName = $xml_in_doc->Info->UserName; // 获取请求文件中的UserName
				$in_Password = $xml_in_doc->Info->Password; // 获取请求文件中的Password
				
				$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
	<PK_Type>
		<Name>SET_FTP_ACK</Name>
		<Code>1604</Code>
	</PK_Type>
	<Info>
		<FsuId/>
		<FsuCode/>
		<Result/>
	</Info>
</Response>
XML;
				
				$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
				
				$db->exec ( "update FTPINFO set UserName='$in_UserName' where FSUID='$fsu_id'" ); // 更新UserName
				$db->exec ( "update FTPINFO set Password='$in_Password' where FSUID='$fsu_id'" ); // 更新Password
				
				$result = $db->query ( "select * from FTPINFO where FSUID='$fsu_id'" ); // 查询更新后的数据
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				
				$res1 = $row ['UserName'] == $in_UserName ? 1 : 0; // 判断UserName是否更新成功
				$res2 = $row ['Password'] == $in_Password ? 1 : 0; // 判断Password是否更新成功
				
				if ($res1 && $res2) // 如果全部都更新成功
					$xml_out_doc->Info->Result = 1;
				else
					$xml_out_doc->Info->Result = 0;
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				
				$db->close (); // 关闭数据库
				$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
			}
		}
		
		/**
		 * *
		 */
		
		if ($code == '1301') // code为1301是时间同步
		{
			
			$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
			
			if ($xml_in_doc->Info->Time->Years == null || $xml_in_doc->Info->Time->Month == null || $xml_in_doc->Info->Time->Day == null || $xml_in_doc->Info->Time->Hour == null || $xml_in_doc->Info->Time->Minute == null || $xml_in_doc->Info->Time->Second == null) // 如果有一个时间属性为 null
			{
				$res = 0;
			} else
			{
				$year = substr ( $xml_in_doc->Info->Time->Years->asXML (), 7, 4 ); // 获取请求文件中的Year
				$month = substr ( $xml_in_doc->Info->Time->Month->asXML (), 7, 2 ); // 获取请求文件中的Month
				$day = substr ( $xml_in_doc->Info->Time->Day->asXML (), 5, 2 ); // 获取请求文件中的Day
				$hour = substr ( $xml_in_doc->Info->Time->Hour->asXML (), 6, 2 ); // 获取请求文件中的Hour
				$minute = substr ( $xml_in_doc->Info->Time->Minute->asXML (), 8, 2 ); // 获取请求文件中的Minute
				$second = substr ( $xml_in_doc->Info->Time->Second->asXML (), 8, 2 ); // 获取请求文件中的Second
				
				$time = $month . $day . $hour . $minute . $year . "." . $second; // 时间格式
				$output = shell_exec ( "sudo date $time" ); // linux执行命令
				$res = 1;
			}
			// $sys_year_month_day = shell_exec ( "date +%y%m%d" );
			// $set_year_month_day = substr ( $year, 2, 2 ) . $month . $day;
			
			$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
	<PK_Type>
		<Name>TIME_CHECK_ACK</Name>
		<Code>1302</Code>
	</PK_Type>
	<Info>
		<Result></Result>
	</Info>
</Response>
XML;
			$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
			if ($res == 1) // 判断更改时间是否成功
				$xml_out_doc->Info->Result = 1;
			else
				$xml_out_doc->Info->Result = 0;
			
			$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
		}
		
		/**
		 * *
		 */
		
		if ($code == '1701') // code为1701是用户获取FSU的状态信息
		{
			$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
			
			$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
    <PK_Type>
        <Name>GET_FSUINFO_ACK</Name>
        <Code>1702</Code>
    </PK_Type>
    <Info>
        <FsuId/>
		<FsuCode/>
        <TFSUStatus>
            <CPUUsage/>
            <MEMUsage/>
        </TFSUStatus>
        <Result/>
    </Info>
</Response>
XML;
			
			$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
			$top_mem = shell_exec ( "sudo top -b -n 1|grep 'Mem'" ); // shell命令获取内存情况
			                                                         // echo $top_mem."<br>";
			$start = "KiB Mem: ";
			$end = " total, ";
			
			// 获取内存总数量
			$total_mem = substr ( $top_mem, strlen ( $start ) + strpos ( $top_mem, $start ), (strlen ( $top_mem ) - strpos ( $top_mem, $end )) * (- 1) );
			// echo $total_mem."<br>";
			
			$start = " total, ";
			$end = " used";
			
			// 获取内存已使用量
			$used_mem = substr ( $top_mem, strlen ( $start ) + strpos ( $top_mem, $start ), (strlen ( $top_mem ) - strpos ( $top_mem, $end )) * (- 1) );
			// echo $used_mem."<br>";
			
			// 获取内存使用率
			$mem_rate_value = ( string ) (( float ) $used_mem / ( float ) $total_mem);
			// echo substr($cpu_rate_value,0,6)."<br>";
			$xml_out_doc->Info->TFSUStatus->MEMUsage = substr ( $mem_rate_value, 0, 6 ); // 把内存使用率写入输出文件,保留4位
			
			$top_cpu = shell_exec ( "sudo top -b -n 1|grep '%Cpu'" ); // shell命令获取CPU情况
			$start = "%Cpu(s):";
			$end = "us";
			
			// 获取CPU使用率
			$cpu = substr ( $top_cpu, strlen ( $start ) + strpos ( $top_cpu, $start ), (strlen ( $top_cpu ) - strpos ( $top_cpu, $end )) * (- 1) );
			
			// echo $top_cpu."<br>";
			$cpu_rate = ( string ) (0.01 * ( float ) $cpu); // 把CPU使用率写入输出文件,保留4位
			if (strlen ( $cpu_rate ) == 4)
			{
				// echo $cpu_rate."00";
				$xml_out_doc->Info->TFSUStatus->CPUUsage = $cpu_rate . "00";
			} elseif (strlen ( $cpu_rate ) == 5)
			{
				// echo $cpu_rate."0";
				$xml_out_doc->Info->TFSUStatus->CPUUsage = $cpu_rate . "0";
			}
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
				
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
				$xml_out_doc->Info->Result=1;
			}
			
			
			$invokeReturn = $xml_out_doc->asXML (); // simplexml对象转为字符串并赋值给$invokeReturn
		}
		
		/**
		 * *
		 */
		
		if ($code == '1801') // code为1801是重启FSU
		{
			
			$xml_in_doc = simplexml_load_string ( $xmlData ); // 把xml字符串转为simplexml对象
			
			$out_xml = <<<XML
<?xml version='1.0' encoding='utf-8'?>
<Response>
    <PK_Type>
        <Name>SET_FSUREBOOT_ACK</Name>
        <Code>1802</Code>
    </PK_Type>
    <Info>
        <FsuId/>
		<FsuCode/>
        <Result/>
    </Info>
</Response>
XML;
			
			$xml_out_doc = simplexml_load_string ( $out_xml ); // 把上面的xml字符串转为simplexml对象
			
			$db = new SQLite3 ( 'history.db' ); // 连接sqlite3数据库
			if (! $db)
			{
				return "Error";
			} else
			{
			
				$result = $db->query ( "SELECT * FROM FSUINFO" );
				$row = $result->fetchArray ( SQLITE3_ASSOC );
				$xml_out_doc->Info->FsuId = $row ['FsuId']; // 设置返回xml的FsuID
				$xml_out_doc->Info->FsuCode = $row ['FsuCode']; // 设置返回xml的FsuCode
			}
			
			$xml_out_doc->Info->Result = 1;
			
			pclose ( popen ( "sudo shutdown -r 1 &", "r" ) ); // shell执行重启命令
			
			return $xml_out_doc->asXML ();
		}
		
		/**
		 * *
		 */
		
		return $invokeReturn;
	}
}

$server = new SoapServer ( 'FSUService.wsdl', array (
		'soap_version' => SOAP_1_2 
) );
$server->setClass ( "FSUService" );
$server->handle ();

?>