<?php
session_start();
if($_SESSION['rol'] != 1)
{
	header("location: ./");
}
include "../conexion.php";

if(!empty($_POST))
{
	if($_POST['idusuario'] == 1){ //esto es para protegerse de ser eliminado al inspeccionar elemento en el boton  y querer cambiar el id para elimianr el superadministrador.
		header("location: lista_usuarios.php");
		mysqli_close($conection);
		exit;
	}

	$idusuario = $_POST['idusuario'];

	//$query_delete = mysqli_query($conection,"DELETE FROM usuario WHERE idusuario = $idusuario ");
	$query_delete = mysqli_query($conection,"UPDATE usuario SET  estatus = 0 WHERE idusuario = $idusuario");
	mysqli_close($conection);
	if($query_delete){
		header("location: lista_usuarios.php");
	}else{
		echo "Error al eliminar";
	}
}


if(empty($_REQUEST['id']) || $_REQUEST['id'] == 1)
{
	header("location:lista_usuarios.php");
	mysqli_close($conection);
}else{
	

	$idusuario = $_REQUEST['id'];

	$query= mysqli_query($conection,"SELECT u.nombre,u.usuario,r.rol
		FROM usuario u
		INNER JOIN 
		rol r
		ON u.rol = r.idrol
		WHERE u.idusuario = $idusuario ");

	mysqli_close($conection);
	$result = mysqli_num_rows($query);

	if($result > 0){
		while($data = mysqli_fetch_array($query)){
			$nombre  = $data['nombre'];
			$usuario = $data['usuario'];
			$rol     = $data['rol'];
		}
	}else{
		header("location: lista_usuarios.php");
	}

}

?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	
	<?php include "includes/scripts.php"; ?>

	<title>Eliminar Usuario</title>

	<link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
     <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
     rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
     crossorigin="anonymous">
</head>
<body>
			<?php include "includes/header.php";?>
	<section id="container">
		<div class="data_delete">
			<i class="fa fa-user-times" style="color: #E52F2B; font-size: 50px"></i>
			<h2>  ¿ Esta seguro de eliminar el siguiente registro ?</h2>
			<p>Nombre: <span><?php echo $nombre; ?></span>
			<p>Usuario: <span><?php echo $usuario; ?></span>
			<p>Tipo Usuario: <span><?php echo $rol; ?></span>
			</p>

			<form action="" method="post">
				<input type="hidden" name="idusuario" value="<?php echo $idusuario; ?>">
				<a href="lista_usuarios.php" class="btn_cancel"> <i class="fa fa-ban"></i> Cancelar</a>
				<!-- <input type="submit" value="aceptar" class="btn_ok"> -->
				<button type="submit" class="btn_ok"> <i class="fa fa-trash"></i> Eliminar</button>
			</form>
		</div>


	</section>


	<?php include "includes/footer.php"; ?>
</body>
</html>