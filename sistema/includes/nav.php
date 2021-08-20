<nav>
			<ul>
				<li><a href="index.php">Inicio</a></li>
				<li class="principal">

					<?php 
						if($_SESSION['rol'] == 1){
					 ?>

					<a href="#">Usuarios</a>
					<ul>
						<li><a href="registro_usuario.php">Nuevo Usuario</a></li>
						<li><a href="lista_usuarios.php">Lista de Usuarios</a></li>
					</ul>
				</li>

					<?php } ?>


				<li class="principal">
					<a href="#">Clientes</a>
					<ul>
						<li><a href="registro_cliente.php">Nuevo Cliente</a></li>
						<li><a href="lista_clientes.php">Lista de Clientes</a></li>
					</ul>
				</li>

				<?php 
					if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){
				 ?>
				<li class="principal">
					<a href="#">Proveedores</a>
					<ul>
						<li><a href="registro_proveedor.php">Nuevo Proveedor</a></li>
						<li><a href="lista_proveedor.php">Lista de Proveedores</a></li>
					</ul>
				</li>
				<?php } ?>
				
				<li class="principal">
					<a href="#"><i class="fa fa-building"></i>Productos</a>
					<ul>
						<?php 
							if($_SESSION['rol'] == 1 || $_SESSION['rol'] == 2){						 ?>
						<li><a href="registro_producto.php"> <i class="fa fa-plus"></i>Nuevo Producto</a></li>
							<?php } ?>
						<li><a href="lista_producto.php"> <i class="fa fa-cube"></i>Lista de Productos</a></li>
					</ul>
				</li>
				<li class="principal">
					<a href="#">Ventas</a>
					<ul>
						<li><a href="nueva_venta.php">Nueva Venta</a></li>
						<li><a href="ventas.php">Ventas</a></li>
					</ul>
				</li>
			</ul>
		</nav>