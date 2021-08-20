 <?php 
  	
  
  	if(!empty($_SESSION['active']))
  	{
  		header('location: ../');
  	}

 ?> 
<header>

	 <link href="https://fonts.googleapis.com/css?family=Lato&display=swap" rel="stylesheet">
       <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"
     rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" 
     crossorigin="anonymous">
		<div class="header">
			
			<h1>Sistema Facturación</h1>
			<div class="optionsBar">
				<p>Santiago, <?php echo fechaC(); ?></p>
				<span>|</span>
				<span class="user"><?php  echo $_SESSION['user'].' - '.$_SESSION['rol'].'-'.$_SESSION['email'];?></span>
				<img class="photouser" src="img/user.png" alt="Usuario">
				<a href="salir.php"><img class="close" src="img/salir.png" alt="Salir del sistema" title="Salir"></a>
			</div>
		</div>
		<?php include "nav.php"; ?>
	</header>

	<div class="modal">
		<div class="bodyModal">
			
		</div>
	</div>