<?php
session_start();

if($_SESSION['rol'] != 1 and $_SESSION['rol'] != 2)
{
	header("location: ./");
}

include "../conexion.php";

//VALIDAR PRODUCTO
if(empty($_REQUEST['id'])){
	header("location: lista_producto.php");//SI esta vacio el id redirecciona a listaproducto
}else{
	$id_producto = $_REQUEST['id'];
	if(!is_numeric($id_producto)){ //Si no es numerico redirecciona a listaa
		header("location: lista_producto.php");
	}

	$query_producto = mysqli_query($conection,"SELECT p.codproducto,p.descripcion,p.precio,p.foto,pr.codproveedor,pr.proveedor 
											 FROM producto p 
											 INNER JOIN proveedor pr
											 ON p.proveedor = pr.codproveedor 
											 WHERE p.codproducto = $id_producto AND p.estatus = 1");
	$result_producto = mysqli_num_rows($query_producto);

	if($result_producto > 0){
		$data_producto = mysqli_fetch_assoc($query_producto);
		print_r($data_producto);

		if($data_producto['foto'] != 'img_producto.png'){
			// $classRemove = '';
			$foto = '<img id="img" src="img/uploads/'.$data_producto['foto'].' alt="">';
		}
	}else{
		header("location: lista_producto.php");
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


	<?php include "includes/scripts.php"; ?>

	<title>Actualizar Producto</title>

</head>
<body>
			<?php include "includes/header.php";?>

	<section id="container">

		<div class="form_register">
			<h1><i class="fa fa-cubes"></i> Actualizar Producto</h1>
			<hr>
			<div class="alert"><p><?php echo isset($alert) ? $alert : ''; ?></p></div>

			<form action="" method="post" enctype="multipart/form-data">

				<input type="hidden" name="id" value="<?php echo $data_producto['codproducto'];?>">
			
				
				<label for="proveedor">Proveedor</label>

				<?php 
					$query_proveedor = mysqli_query($conection,"SELECT codproveedor, proveedor 
													FROM proveedor WHERE estatus = 1  ORDER BY proveedor ASC");
					$result_proveedor = mysqli_num_rows($query_proveedor);
					// mysqli_close($conection);
				 ?>

				<select name="proveedor" id="proveedor">
					<option value="<?php echo $data_producto['codproveedor']?>"> <?php echo $data_producto['proveedor']?> </option>

					<?php 
						if($result_proveedor > 0){
							while($proveedor = mysqli_fetch_array($query_proveedor)){
								?>
									<option value="<?php echo $proveedor['codproveedor'];?>" select > <?php echo $proveedor['proveedor']; ?></option>
								<?php 

							}
						}
						 ?>
						
	
				</select>

				<label for="producto">Producto</label>
				<input type="text" name="producto" id="producto" placeholder="Nombre del producto" value="<?php echo $data_producto['descripcion']?>">

				<label for="precio">Precio</label>
				<input type="number" name="precio" id="precio" placeholder="Precio del producto" value="<?php echo $data_producto['precio']?>">

				<div class="photo">
						<label for="foto">Foto</label>
					       
					        <img src="img/uploads/<?php echo $data_producto['foto'];?>" alt="">
					        <input type="file" name="foto" id="foto">
					       
					      
					         <div id="form_alert"></div> 
				</div>

				<button type="submit"  class="btn_save" name="modificarProductos" value="modificarProductos"><i class="fa fa-save fa-lg"></i> Actualizar Producto </button>

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