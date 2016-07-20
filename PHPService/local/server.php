<?php
	ini_set('soap.wsdl_cache_enabled', '0');
	include_once('service.php');
	$server=new SoapServer('soap.wsdl',array('soap_version' => SOAP_1_2));
	$server->setClass("service");
	$server->handle();
?>