<?php
	session_start();
	if($_SESSION['rol'] != 1)
	{
		header("location: ./");
	}

	include "../conexion.php";
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	
	<?php include "includes/scripts.php"; ?>

	<title>Sistema de Ventas</title>


	   <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
       <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
     rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
     crossorigin="anonymous">


</head>
<body>
			<?php include "includes/header.php";?>
	<section id="container">

		<h1> <i class="fa fa-users"></i> Lista de Usuarios</h1>
		<a href="registro_usuario.php" class="btn_new"> <i class="fa fa-plus"></i> Crear usuario</a>

		<form action="buscar_usuario.php" method="get" 
		class="form_search">
			<input type="text" name="busqueda" id="busqueda" 
			placeholder="Buscar">
			<input type="submit" value="Buscar" 
			class="btn_search">
		</form>

		<table>
			<tr>
				<th>ID</th>
				<th>Nombre</th>
				<th>Correo</th>
				<th>Usuario</th>
				<th>Rol</th>
				<th>Acciones</th>
			</tr>

			<?php
			//paginador
			$sql_registe = mysqli_query($conection,"SELECT count(*) as total_registro FROM usuario WHERE estatus = 1");
			$result_register = mysqli_fetch_array($sql_registe);
			$total_registro = $result_register['total_registro'];

			$por_pagina = 4;

			if(empty($_GET['pagina'])) //SI el valor pasado por el metodo GEt no existe la pagina va a ser 1
			{
				$pagina = 1;
			}else{
				$pagina = $_GET['pagina'];
			}

			$desde = ($pagina - 1) * $por_pagina;
			$total_paginas = ceil($total_registro / $por_pagina);

			 $query = mysqli_query($conection, "SELECT u.idusuario, u.nombre, u.correo, u.usuario, r.rol 
			 	FROM usuario u INNER JOIN rol r ON u.rol = r.idrol 
			 	WHERE estatus = 1 
			 	ORDER BY u.idusuario ASC LIMIT $desde,$por_pagina");

			 mysqli_close($conection);
			 $result = mysqli_num_rows($query);
			 if($result > 0){

			 	while($data = mysqli_fetch_array($query))  {

			?>

			<tr>
			<td><?php echo $data['idusuario'];?></td>
			<td><?php echo $data['nombre'];?></td>
			<td><?php echo $data['correo'];?></td>
			<td><?php echo $data['usuario'];?></td>
			<td><?php echo $data['rol'];?></td>
			<td>
				<a class="link_edit" href="editar_usuarios.php?id=<?php echo $data['idusuario'];?>"><i class="fa fa-edit"></i>Editar</a>	
					|| 	
				<!-- lo que hace es ocultar el boton de eliminar en el super administrador quien tiene el el id que es igual a 1 -->
				<?php if($data['idusuario'] != 1 ){?>
				<a class="link_delete" href="eliminar_confirmar_usuario.php?id=<?php echo $data['idusuario'];?>"> 
					<i class="fa fa-trash"></i>Eliminar</a>

			<?php } ?>
			</td>


			<?php
			 	}
			 }
			?>

		</table>
		<div class="paginador">
			<ul>
				<?php 
					if($pagina != 1)//Si pagina no es igual a uno, se muestran estos primeros botones, de lo contrario desaparecen
					{
					?>
				<li><a href="?pagina=<?php echo 1;?>">|<</a></li>
				<li><a href="?pagina=<?php echo $pagina-1; ?>"><<</a></li>
			 <?php 
			 		}
			 	for($i=1; $i <= $total_paginas; $i++){

			 		if($i == $pagina)
			 		{
			 			 echo '<li class="pageSelected">'.$i.'</a></li>';
			 		}else{
			 			echo '<li><a href="?pagina='.$i.'">'.$i.'</a></li>';
			 		}
			 		
			 	}

			 	if($pagina != $total_paginas)
			 	{
			  ?>
				<li><a href="?pagina=<?php echo $pagina + 1;?>">>></a></li>
				<li><a href="?pagina=<?php echo $total_paginas;?>">>|</a></li>
			<?php } ?>
			</ul>
		</div>


	</section>


	<?php include "includes/footer.php"; ?>
</body>
</html>