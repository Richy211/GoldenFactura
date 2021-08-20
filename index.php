<?php

	$alert = '';
	session_start();

	if(!empty($_SESSION['active']))
	{
		header('location: sistema/');
	}else{

	if(!empty($_POST))
	{
		if(empty($_POST['usuario']) || empty($_POST['clave']))
		{
			$alert =' Ingrese su usuario y su clave';

		}else{

			require_once "conexion.php";
			
			$user = mysqli_real_escape_string($conection,$_POST['usuario']);
			$pass = md5(mysqli_real_escape_string($conection,$_POST['clave']));

			// echo $pass;exit;

			$query = mysqli_query($conection, "SELECT u.idusuario,u.nombre,u.correo,u.usuario,r.idrol,r.rol
									 FROM usuario u
									 INNER JOIN rol r
									 ON u.rol = r.idrol
									 WHERE u.usuario = '$user' AND u.clave = '$pass'");
			mysqli_close($conection);
			$result = mysqli_num_rows($query);

			if($result > 0)
			{
				$data =mysqli_fetch_array($query);
				// print_r($data);
				session_start();
				// $_SESSION['active'] = true;
				$_SESSION['idUser'] = $data['idusuario'];
				$_SESSION['nombre'] = $data['nombre'];
				$_SESSION['email']  = $data['correo'];
				$_SESSION['user']   = $data['usuario'];
				$_SESSION['rol']    = $data['idrol'];
				$_SESSION['rol_name']    = $data['rol'];


				header('location: sistema/');
			}else{
				$alert = "El usuario o la clave son incorrectos";

				session_destroy();
			
			}
		}

	}
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Login | Sistema de Facturación</title>
	<link rel="stylesheet" href="css/estilos.css" type="text/css">
	<script type="text/javascript" src="js/functions.js"></script>
</head>
<body>
	<section id="container">
		
		<form action="" method="post">
			
			<h3>Iniciar Sesion</h3>
			<img src="img/login.png" alt="Login">

			<input type="text" name="usuario" placeholder="Usuario">
			<input type="password" name="clave" placeholder="Contraseña">
			<div class="alert"><?php echo isset($alert) ? $alert : ''; ?></div>
			<input type="submit" value="INGRESAR">

		</form>
	</section>
<!-- 	htmlcolorcodes.com/es -->
</body>
</html>