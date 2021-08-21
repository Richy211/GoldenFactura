<?php
	include 'plantilla.php';
	/* require 'class/class.php';  */

	/* $tra=new Trabajo();
	$datos=$tra->get_detalle();
	$presu=$tra->get_presupuesto(); */
	
	$pdf = new PDF();
	$pdf->AliasNbPages();
	$pdf->AddPage();

	$pdf->SetFillColor(255,255, 255);
	$pdf->Rect(0,0,220,40, 'F');


	$pdf->SetFont('Arial','b', 20);
	$pdf->SetY(20);
	$pdf->SetX(70);
	$pdf->SetTextColor(0,0,0);
	$pdf->write(5, 'GoldenClass');
	$pdf->Ln();

	$pdf->Ln();
	$pdf->SetFont('Arial','b',10);
	$pdf->SetX(60);
	$pdf->write(5, 'Salvador Reyes 150, Estacion Central');
	$pdf->Ln();
	
	$pdf->SetFont('Arial','b',10);
	$pdf->SetX(60);
	$pdf->write(5,'Rut:15432543-6');
	$pdf->Ln();

	$pdf->SetFont('Arial','b',10);
	$pdf->SetX(60);
	$pdf->write(5,'Telefono:987987987');
	$pdf->Ln();

	$pdf->SetFont('Arial','b',10);
	$pdf->SetX(60);
	$pdf->write(5,'Email:nadiavergara@goldenclass.com');
	$pdf->Ln();
	

	$pdf->SetFont('Arial','b',10);
	$pdf->SetY(30);
	$pdf->Setx(150);
	$pdf->write(5, 'Detalle del Envio: ');
	$pdf->Ln();
	$pdf->Setx(150);
	$pdf->write(5, 'Fecha: ');
	$pdf->Ln();
	$pdf->Setx(150);
	$pdf->write(5, 'Hora: ');
	$pdf->Ln();
	$pdf->Setx(150);
	$pdf->write(5, 'Vendedor: ');
	$pdf->Ln();
	$pdf->Ln(20);

	$pdf->SetTextColor(0,0,0);
	$pdf->SetY(60);
	$pdf->Image('img/logoGolden_ok.png',20,30,17,17,'png');


	

	$pdf->SetTextColor(255,255,255);
	$pdf->SetFillColor(79,78,77);
	$pdf->SetFont('Arial','B',12);
	
	$pdf->Cell(60,10,'MATERIAL',1,0,'C',1);
	$pdf->Cell(60,10,'TERMINACIONES',1,0,'C',1);
	$pdf->Cell(20,10,'M2',1,0,'C',1);
	$pdf->Cell(20,10,'Cant',1,0,'C',1);
	$pdf->Cell(20,10,'Total',1,1,'C',1);


	$pdf->SetFont('Arial','',10);

	$total =0;

	
	$pdf->SetTextColor(78,79,77);
	$pdf->SetFillColor(232,232,232);

		$pdf->Cell(60,6,1,0,'C');
		$pdf->Cell(60,6,1,0,'C');
		$pdf->Cell(20,6,1,0,'C');
		$pdf->Cell(20,6,1,0,'C');
		$pdf->Cell(20,6,1,1,'C');
		// $pdf->Ln();




	$pdf->Ln(30);

	$pdf->Cell(140,20,'',0,0,'C')/**/;
	$pdf->Cell(20,10, 'IVA',0,0,'C');
	$pdf->Cell(20, 10,0,0,'C');

	$pdf->Ln();

	$pdf->SetTextColor(255,255,255);
	$pdf->SetFillColor(79,78,77);
	$pdf->Cell(140,10,'',0,0,'C',1);
	$pdf->Cell(20,10, 'Total',0,0,'C',1);
	$pdf->Cell(20, 10,0,0,'C',1);



	$pdf->Output();
?>