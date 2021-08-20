<?php

$host = 'localhost';
$user = 'root';
$password = '';
$db = 'factura';

$conection = mysqli_connect($host,$user,$password,$db);



if(!$conection){
	echo "Error en la conexion";
}

?>