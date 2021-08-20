<?php
session_start();
if($_SESSION['rol'] != 1 and $_SESSION['rol'] !=2)
{
	header("location: ./");
}
include "../conexion.php";

if(!empty($_POST))
{
	if(empty($_POST['idproveedor']))
	{
		header("location: lista_proveedor.php");
		mysqli_close($conection);
	}

	$idproveedor = $_POST['idproveedor'];

	//$query_delete = mysqli_query($conection,"DELETE FROM usuario WHERE idusuario = $idusuario ");
	$query_delete = mysqli_query($conection,"UPDATE proveedor SET  estatus = 0 WHERE codproveedor = $idproveedor");
	mysqli_close($conection);
	if($query_delete){
		header("location: lista_proveedor.php");
	}else{
		echo "Error al eliminar";
	}
}

if(empty($_REQUEST['id']))
{
	header("location:lista_proveedor.php");
	mysqli_close($conection);
}else{
	

	$idproveedor = $_REQUEST['id'];

	$query= mysqli_query($conection,"SELECT * FROM proveedor WHERE codproveedor = $idproveedor ");

	mysqli_close($conection);
	$result = mysqli_num_rows($query);

	if($result > 0){
		while($data = mysqli_fetch_array($query)){
			$proveedor 	= $data['proveedor'];
		}
	}else{
		header("location: lista_proveedor.php");
	}

}

?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	
	<?php include "includes/scripts.php"; ?>

	<title>Eliminar Cliente</title>
	<link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
     <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
     rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
     crossorigin="anonymous">

</head>
<body>
			<?php include "includes/header.php";?>
	<section id="container">
		<div class="data_delete">

			<i class="fa fa-building"  style="color: #e66262; font-size: 50px"></i>
			<br><br>
			<h2>¿ Esta seguro de eliminar el siguiente registro ?</h2>
			<p>Nombre del proveedor: <span><?php echo $proveedor; ?></span>
		
			<form action="" method="post">
				<input type="hidden" name="idproveedor" value="<?php echo $idproveedor; ?>">
				<a href="lista_proveedor.php" class="btn_cancel"> <i class="fa fa-ban"></i>Cancelar</a>
				<button type="submit" class="btn_ok"><i class="fa fa-trash"></i> Eliminar</button>
			</form>
		</div>


	</section>


	<?php include "includes/footer.php"; ?>
</body>
</html>