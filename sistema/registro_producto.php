<?php
session_start();

if($_SESSION['rol'] != 1 and $_SESSION['rol'] != 2)
{
	header("location: ./");
}

include "../conexion.php";


	if(!empty($_POST))
	{

		/*print_r($_FILES);
		exit;
*/
	$alert='';

	if(empty($_POST['proveedor']) || empty($_POST['producto']) ||  empty($_POST['precio']) || empty($_POST['cantidad']))
	{
		$alert='<p class="msg_error">Todos los campos son obligatorios.</p>'; 
	}else{
		
		$proveedor	= $_POST['proveedor'];
		$producto 	= $_POST['producto'];
		$precio 	= $_POST['precio'];
		$cantidad 	= $_POST['cantidad'];
		$usuario_id = $_SESSION['idUser'];

		$foto = $_FILES['foto']['name'];

		if($_FILES['foto']['type'] == "image/jpeg")
		{
			copy($_FILES['foto']['tmp_name'], 'img/uploads/'.$foto);
		}
		
			$query_insert = mysqli_query($conection, "INSERT INTO producto(proveedor,descripcion,precio,existencia,usuario_id,foto)
				VALUES('$proveedor','$producto','$precio','$cantidad','$usuario_id','$foto')");

			if($query_insert){
				// if($nombre_foto != ''){
				// 	move_uploaded_file($url_temp,$src);
				$alert='<p class="msg_save">Producto guardado correctamente.</p>';
				}else{
				$alert='<p class="msg_error">Error al guardar el producto.</p>';
			}
	}

}
?>

<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8">
	   <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
       <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
     rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
     crossorigin="anonymous">





<script></script>

	<?php include "includes/scripts.php"; ?>

	<title>Registro Producto</title>

</head>
<body>
			<?php include "includes/header.php";?>

	<section id="container">

		<div class="form_register">
			<h1><i class="fa fa-cubes"></i> Registro Producto</h1>
			<hr>
			<div class="alert"><p><?php echo isset($alert) ? $alert : ''; ?></p></div>

			<form action="" method="post" enctype="multipart/form-data">

				<label for="proveedor">Proveedor</label>

				<?php 
					$query_proveedor = mysqli_query($conection,"SELECT codproveedor, proveedor FROM proveedor WHERE estatus = 1  ORDER BY proveedor ASC");
					$result_proveedor = mysqli_num_rows($query_proveedor);
					mysqli_close($conection);
				 ?>

				<select name="proveedor" id="proveedor">
					<?php 
						if($result_proveedor > 0){
							while($proveedor = mysqli_fetch_array($query_proveedor)){
								?>
									<option value="<?php echo $proveedor['codproveedor'];?>"> <?php echo $proveedor['proveedor']; ?></option>
								<?php 

							}
						}
						 ?>
				</select>

				<label for="producto">Producto</label>
				<input type="text" name="producto" id="producto" placeholder="Nombre del producto">

				<label for="precio">Precio</label>
				<input type="number" name="precio" id="precio" placeholder="Precio del producto">

				<label for="cantidad">Cantidad</label>
				<input type="number" name="cantidad" id="cantidad" placeholder="Cantidad del producto">

				<div class="photo">
						<label for="foto">Foto</label>
					        <!-- <div class="prevPhoto">
					        <span class="delPhoto notBlock">X</span>
					        <label for="foto"></label>
					        </div>
					        <div class="upimg"> -->
					        <input type="file" name="foto" id="foto">
					        <!-- </div> -->
					        <div id="form_alert"></div>
				</div>

				<button type="submit"  class="btn_save"><i class="fa fa-save fa-lg"></i> Guardar Producto </button>


			</form>
		</div>
	</section>


	<?php include "includes/footer.php"; ?>

	<script
  src="https://code.jquery.com/jquery-3.6.0.min.js"
  integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
  crossorigin="anonymous"></script>

  <script src="js/app.js"></script>

</body>
</html>