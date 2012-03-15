#!/usr/bin/env php
<?php
$addr = 'localhost';
$port = 9011;
$sock = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP); //Can create the socket
$sock_data = socket_connect($sock, $addr, $port); //Can connect to the socket


foreach(range(0,10) as $idx){
	$msg_struct = array(
				'timestamp' => time(),
				'hostname' => 'dummy',
				'class' => 'thisone',
				'method' => 'method1'
			);

	$msg = json_encode($msg_struct);
	
	
	socket_write($sock, $msg, strlen($msg)); //Send data
}

socket_close($sock); //Close socket