<?php
	session_start();
	include "../conexion.php";
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	
	<?php include "includes/scripts.php"; ?>

	<title>Lista de clientes</title>
</head>
<body>
			<?php include "includes/header.php";?>
	<section id="container">

		<?php 

			$busqueda = strtolower($_REQUEST['busqueda']);
			if(empty($busqueda))
			{
				header("location: lista_clientes.php");
				mysqli_close($conection);
			}
		?>

		<h1>Lista de Clientes</h1>
		<a href="registro_cliente.php" class="btn_new">Crear usuario</a>

		<form action="buscar_cliente.php" method="get" class="form_search">
			<input type="text" name="busqueda" id="busqueda" 
			placeholder="Buscar" value="<?php echo $busqueda; ?>">
			<input type="submit" value="Buscar" 
			class="btn_search">
		</form>

		<table>
			<tr>
				<th>ID</th>
				<th>Nit</th>
				<th>Nombre</th>
				<th>Teléfono</th>
				<th>Dirección</th>
				<th>Acciones</th>
			</tr>

			<?php
			//paginador

			$sql_registe = mysqli_query($conection, "SELECT COUNT(*) as total_registro FROM cliente
										 WHERE (idcliente LIKE '%$busqueda%' OR
										 		 nit LIKE '%$busqueda%' OR
										 		 nombre LIKE '%$busqueda%' OR
										 		 telefono LIKE '%$busqueda%' OR
										 		 direccion LIKE '%$busqueda%'
										 		)
										 AND estatus = 1 " );

			$result_register = mysqli_fetch_array($sql_registe);
			$total_registro = $result_register['total_registro'];

			$por_pagina = 3;

			if(empty($_GET['pagina'])) //SI el valor pasado por el metodo GEt no existe la pagina va a ser 1
			{
				$pagina = 1;
			}else{
				$pagina = $_GET['pagina'];
			}

			$desde = ($pagina - 1) * $por_pagina;
			$total_paginas = ceil($total_registro / $por_pagina);

			 $query = mysqli_query($conection, "SELECT * FROM cliente WHERE 
			 			(idcliente LIKE '%$busqueda%' OR
						nit LIKE '%$busqueda%' OR
						nombre LIKE '%$busqueda%' OR
						telefono LIKE '%$busqueda%' OR
						direccion LIKE '%$busqueda%' )
						AND 
			 	estatus = 1 ORDER BY idcliente ASC LIMIT $desde,$por_pagina");

			 
			 mysqli_close($conection);
			 $result = mysqli_num_rows($query);
			 if($result > 0){

			 	while($data = mysqli_fetch_array($query))  {

			?>

			<tr>
			<td><?php echo $data['idcliente'];?></td>
			<td><?php echo $data['nit'];?></td>
			<td><?php echo $data['nombre'];?></td>
			<td><?php echo $data['telefono'];?></td>
			<td><?php echo $data['direccion'];?></td>
			<td>
				<a class="link_edit" href="editar_cliente.php?id=<?php echo $data['idcliente'];?>">Editar</a>

				<!-- lo que hace es ocultar el boton de eliminar en el super administrador quien tiene el el id que es igual a 1 -->
				<?php if($_SESSION['rol'] != 1 || $_SESSION['rol'] == 2 ){?>
				<a class="link_delete" href="eliminar_confirmar_cliente.php?id=<?php echo $data['idcliente'];?>">Eliminar</a>

			<?php } ?>

			</td>


			<?php
			 	}
			 }
			?>

		</table>

<?php 
	if($total_registro != 0)
	{
 ?>


		<div class="paginador">
			<ul>
				<?php 
					if($pagina != 1)//Si pagina no es igual a uno, se muestran estos primeros botones, de lo contrario desaparecen
					{
					?>
				<li><a href="?pagina=<?php echo 1;?>&busqueda=<?php echo $busqueda; ?>">|<</a></li>
				<li><a href="?pagina=<?php echo $pagina-1; ?>&busqueda=<?php echo $busqueda; ?>"><<</a></li>
			 <?php 
			 		}
			 	for($i=1; $i <= $total_paginas; $i++){

			 		if($i == $pagina)
			 		{
			 			 echo '<li class="pageSelected">'.$i.'</a></li>';
			 		}else{
			 			echo '<li><a href="?pagina='.$i.'&busqueda='.$busqueda.'">'.$i.'</a></li>';
			 		}
			 		
			 	}

			 	if($pagina != $total_paginas)
			 	{
			  ?>
				<li><a href="?pagina=<?php echo $pagina + 1;?> &busqueda=<?php echo $busqueda; ?>">>></a></li>
				<li><a href="?pagina=<?php echo $total_paginas;?>&busqueda=<?php echo $busqueda; ?>">>|</a></li>
			<?php } ?>
			</ul>
		</div>
<?php } ?>

	</section>


	<?php include "includes/footer.php"; ?>
</body>
</html>