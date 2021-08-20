<?php
	session_start();
	include "../conexion.php";
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	
	<?php include "includes/scripts.php"; ?>

	<title>Lista de Ventas</title>

		   <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
       <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
     rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
     crossorigin="anonymous">
</head>
<body>
			<?php include "includes/header.php";?>
	<section id="container">
	
		<h1><i class="fa fa-list-ol"></i> Lista de Ventas </h1>
		<a href="registro_cliente.php" class="btn_new"><i class="fa fa-plus"></i> Nueva venta</a>
		
			<form action="buscar_venta.php" method="get" class="form_search">
				<input type="text" name="busqueda" id="busqueda" placeholder="No. Factura">
				<input type="submit" value="Buscar" class="btn_search">
			</form>

		
		<div>	
			<h5>Buscar por Fecha</h5>
				<form action="buscar_venta.php" method="get" class="form_search_date">
					<label>De: </label>
					<input type="date" name="fecha_de" id="fecha_de" required>
					<label> A </label>
					<input type="date" name="fecha_a" name="fecha_a" id="fecha_a" required>
					<button type="submit" class="btn_view"> <i class="fa fa-search"></i></button>
				</form>
		</div>

		<table>
			<tr>
				<th>No</th>
				<th>Fecha/Hora</th>
				<th>Cliente</th>
				<th>Vendedor</th>
				<th>Estado</th>
				<th class="textright">Total Factura</th>
				<th class="textcenter">Acciones</th>
			</tr>

			<?php
			//paginador
			$sql_registe = mysqli_query($conection,"SELECT count(*) as total_registro FROM factura WHERE estatus != 10 ");
			$result_register = mysqli_fetch_array($sql_registe);
			$total_registro = $result_register['total_registro'];

			$por_pagina = 5;

			if(empty($_GET['pagina'])) //SI el valor pasado por el metodo GEt no existe la pagina va a ser 1
			{
				$pagina = 1;
			}else{
				$pagina = $_GET['pagina'];
			}

			$desde = ($pagina - 1) * $por_pagina;
			$total_paginas = ceil($total_registro / $por_pagina);

			 $query = mysqli_query($conection, "SELECT f.nofactura,f.fecha,f.totalfactura,
			 									f.codcliente,f.estatus,
			 									u.nombre as vendedor,
			 									cl.nombre as cliente
			 									FROM factura f
			 									INNER JOIN usuario u
			 									ON f.usuario = u.idusuario 
			 									INNER JOIN cliente cl 
			 									ON f.codcliente = cl.idcliente 
			 									WHERE f.estatus != 10 
			 									ORDER BY f.fecha 
			 									ASC LIMIT $desde,$por_pagina");
			 mysqli_close($conection);
			 $result = mysqli_num_rows($query);
			 if($result > 0){

			 	while($data = mysqli_fetch_array($query))  {
			 		if($data["estatus"] == 1){
			 			$estado = '<span class="pagada">Pagada</span>';
			 		}else{
			 			$estado = '<span class="anulada">Anulada</span>';
			 		}
			?>

			<tr>
			<td><?php echo $data['nofactura'];?></td>
			<td><?php echo $data['fecha'];?></td>
			<td><?php echo $data['cliente'];?></td>
			<td><?php echo $data['vendedor'];?></td>
			<td class="estado"><?php echo $estado; ?></td>
			<td class="textright totalfactura"><span> $. </span><?php echo $data["totalfactura"]; ?></td>

			<td>
				<div class="div_acciones">
					<div>
						<button class="btn_view view_factura" type="button" cl="<?php echo $data['codcliente']; ?>" f="<?php echo $data['nofactura'];?>">
						 <i class="fa fa-eye"></i></button>
					</div>

						<?php if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2 ){
								if($data["estatus"] == 1)
								{
						?>
									<div class="div_factura">
										<button class="btn_anular anular_factura" 
										fac="<?php echo $data['nofactura'];?>"> <i class='fa fa-ban'></i></button>
									</div>

						<?php }else{ ?>
									<div class="div_factura">
										<button  type="button" class="btn_anular inactive"> <i class='fa fa-ban'></i></button>
									</div>
						<?php  }	 
						}
						?>
				</div>
			</td>

		<?php }
	} ?>
		</tr>
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

	<script
  src="https://code.jquery.com/jquery-3.6.0.min.js"
  integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
  crossorigin="anonymous"></script>

  <script src="js/app.js"></script>
  
</body>
</html>