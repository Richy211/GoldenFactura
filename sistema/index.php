<?php 
	session_start();
 ?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	
	<?php 
	include "includes/scripts.php"; 
	include "../conexion.php";

	//Datos empresa
	$nit = '';
	$nombreEmpresa = '';
	$razonSocial = '';
	$telEmpresa = '';
	$emailEmpresa = '';
	$dirEmpresa = '';
	$iva = '';

	$query_empresa = mysqli_query($conection,"SELECT * FROM configuracion");
	$row_empresa = mysqli_num_rows($query_empresa);
	if($row_empresa > 0)
	{
		while ($arrInfoEmpresa = mysqli_fetch_assoc($query_empresa)){
			$nit = $arrInfoEmpresa['nit'];
			$nombreEmpresa = $arrInfoEmpresa['nombre'];
			$razonSocial = $arrInfoEmpresa['razon_social'];
			$telEmpresa = $arrInfoEmpresa['telefono'];
			$emailEmpresa = $arrInfoEmpresa['email'];
			$dirEmpresa = $arrInfoEmpresa['direccion'];
			$iva = $arrInfoEmpresa['iva'];
		}
	}

	$query_dash  = mysqli_query($conection,"CALL dataDashboard();");
	$result_dash = mysqli_num_rows($query_dash);
	if($result_dash > 0){
		$data_dash = mysqli_fetch_assoc($query_dash);
		mysqli_close($conection);
	} 

	//print_r($data_dash);

	?>

	<title>Sistema de Ventas</title>

		<link rel="stylesheet" href="css/style.css">
		   <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
       
       <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
     rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
     crossorigin="anonymous">


</head>
<body>
			<?php include "includes/header.php";?>
	<section id="container">

		<div class="container">
			<div class="divContainer">
				<h1 class="titlePanelControl">Panel de control</h1>
			

			<div class="dashboard">
				<?php 
					if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2)
					{

				 ?>
				<a href="lista_usuario.php">
					<i class="fa fa-users"></i>
					<p>
						<strong>Usuarios</strong><br>
						<span> <?php echo $data_dash['usuarios']; ?></span>
					</p>

				<?php } ?>
				</a>
				<a href="lista_clientes.php">
					<i class="fa fa-user"></i>
					<p>
						<strong>Clientes</strong><br>
						<span> <?php echo $data_dash['clientes']; ?></span>
					</p>
				</a>
				<?php 
					if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2)
					{

				 ?>
				<a href="lista_proveedor.php">
					<i class="fa fa-building"></i>
					<p>
						<strong>Proveedores</strong><br>
						<span> <?php echo $data_dash['proveedores']; ?></span>
					</p>
				</a>
			<?php } ?>


				<a href="lista_producto.php">
					<i class="fa fa-cubes"></i>
					<p>
						<strong>Productos</strong><br>
						<span><?php echo $data_dash['productos']; ?></span>
					</p>
				</a>
				<a href="ventas.php">
				
					<i class="fa fa-file"></i>
					<p>
						<strong>Ventas</strong><br>
						<span> <?php echo $data_dash['ventas']; ?></span>
					</p>
				</a>
			</div>

			</div>
		</div>


		<div class="divInfoSistema">
			
			<div>
				<h1 class="titlePanelControl">Configuración</h1>
			</div>

			<div class="containerPerfil">
				<div class="containerDataUser">
					<div class="logoUser">
						<img src="img/usuario.png" alt="">
					</div>

				<div class="divDataUser">
						<h4>Información Personal</h4>

					<div>
						<label>Nombre:</label> <span><?= $_SESSION['nombre']; ?></span>
					</div>

					<div>
						<label>Correo:</label> <span><?= $_SESSION['email']; ?></span>
					</div>
					<h4>Datos Usuarios</h4>

					<div>
						<label>Rol:</label> <span><?= $_SESSION['rol_name']; ?></span>
					</div>


					<div>
						<label>Usuario:</label> <span> <?= $_SESSION['user']; ?></span>
					</div>

					<h4>Cambiar Contraseña</h4>
					<form action="" method="post" name="frmChangePass" id="frmChangePass">
					<div>
						<input type="password" name="txtPassUser" id="txtPassUser" placeholder="Contraseña actual" required>
					</div>
					<div>
						<input class="newPass" type="password" name="txtNewPassUser" id="txtNewPassUser" placeholder=" Nueva Contraseña" required>
					</div>
					<div>
						<input class="newPass" type="password" name="txtPassConfirm" id="txtPassConfirm" placeholder=" Confirmar Contraseña" required>
					</div>

					<div class="alertChangePass" style="display: none;"></div>

					<div>
						<button type="submit" class="btn_save btn_ChangePass"><i class="fa fa-key"></i>Cambiar contraseña</button>
					</div>

					</form>
				</div>

				</div>

				<?php if($_SESSION['rol'] ==1 ){ ?>


				<div class="containerDataEmpresa">
						<div class="logoEmpresa">
							<img src="img/empresa1.png"  alt="">
						</div>
						<h4>Datos de la Empresa</h4>

						<form action="" method="post" name="frmEmpresa" id="frmEmpresa">
							<input type="hidden" name="action" value="updateDataEmpresa">
							<div>
								<label>Nit:</label><input type="text" name="txtNit" id="txtNit" 
								placeholder="Nit de la Empresa" value="<?= $nit; ?>" required>
							</div>
							<div>
								<label>Nombre:</label><input type="text" name="txtNombre" id="txtNombre" placeholder="Nombre de la empresa" 
								value="<?= $nombreEmpresa; ?>" required>
							</div>
							<div>
								<label>Razon Social:</label><input type="text" name="txtRSocial" id="txtRSocial" placeholder="Razon Social" 
								value="<?= $razonSocial; ?>">
							</div>
							<div>
								<label>Teléfono:</label><input type="text" name="txtTelEmpresa"   id="txtTelEmpresa" placeholder="Número de teléfono" 
								value="<?= $telEmpresa; ?>" required>
							</div>
							<div>
								<label>Correo electrónico: </label>
								<input type="email" name="txtEmailEmpresa" 
								id="txtEmailEmpresa" placeholder="Correo Electrónico" 
								value="<?= $emailEmpresa; ?>" required>
							</div>
							<div>
								<label>Dirección:</label><input type="text" name="txtDirEmpresa" id="txtDirEmpresa" placeholder="Dirección de la empresa" value="<?= $dirEmpresa; ?>" required>
							</div>
							<div>
								<label>IVA (%):</label> <input type="text" name="txtIva" id="txtIva" placeholder="Impuesto al valor agregado (IVA)" 
								value="<?= $iva; ?>" required>
							</div>

							<div class="alertFormEmpresa" style="display: none;"></div>

							<div>
								<button type="submit" class="btn_save frmEmpresa"><i class="fa fa-save"></i> Guardar datos</button>
							</div>

						</form>

				</div>

			<?php } ?>
			</div>
		
	</div>
	</section>


<script
  src="https://code.jquery.com/jquery-3.6.0.min.js"
  integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
  crossorigin="anonymous"></script>

  <script src="js/app.js"></script>

	<?php include "includes/footer.php"; ?>
</body>
</html>