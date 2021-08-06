
<?php include "../conexion.php"; ?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
<?php include "includes/scripts.php";?>
	<title>Lista de usuarios</title>
</head>
<body>
	<?php include "includes/header.php";?>
	<section id="container">

		<h1>Lista de Usuarios</h1>
		<a href="registro_usuario.php" class="btn_new">Crear usuario</a>
		<table>
			<tr>
				<th>Id</th>
				<th>Nombre</th>
				<th>Correo</th>
				<th>Usuario</th>
				<th>Rol</th>
				<th>Acciones</th>
			</tr>

<?php 

	$query = mysqli_query($conection, "SELECT u.idusuario, u.nombre, u.correo, u.usuario, r.rol 
						FROM usuario u INNER JOIN rol r ON u.rol = r.idrol WHERE estatus = 1  ORDER BY idusuario ASC");

	$result = mysqli_num_rows($query);
	if($result > 0){

		while($data = mysqli_fetch_array($query)){
?>

			<tr>
				<td><?php echo $data['idusuario']; ?></td>
				<td><?php echo $data['nombre']; ?></td>
				<td><?php echo $data['correo']; ?></td>
				<td><?php echo $data['usuario']; ?></td>
				<td><?php echo $data['rol']; ?></td>
				<td>
					<a class="link_edit" href="editar_usuario.php?id=<?php echo $data['idusuario'];?>">Editar</a>
					||

					<!-- Se crea esta proteccion para que los que no son el admin o id = 1 no se muester el boton de borrar -->
					<?php if($data["idusuario"] != 1) {?>

					<a class="link_delete" href="eliminar_confirmar_usuario.php?id=<?php echo $data['idusuario'];?>">Eliminar</a>

					<?php } ?>

				</td>
			</tr>

			<?php
		}
	}

 ?>

		</table>

		<div class="paginador">
			<ul>
				<li><a href=""> |< </a> </li>
				<li> <a href=""> << </a></li>
				<li class="pageSelected"> 1 </a></li>
				<li><a href=""> 2 </a></li>
				<li><a href=""> 3 </a></li>
				<li><a href=""> 4 </a></li>
				<li><a href=""> 5 </a></li>
				<li><a href=""> >> </a></li>
				<li><a href=""> >| </a></li>
			</ul>
		</div>
		
	</section>
</body>
</html>