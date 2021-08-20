-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 25-04-2021 a las 03:31:48
-- Versión del servidor: 10.4.11-MariaDB
-- Versión de PHP: 7.4.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `factura`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_producto` (`n_cantidad` INT, `n_precio` DECIMAL(10,2), `codigo` INT)  BEGIN
    	DECLARE nueva_existencia int;
        DECLARE nuevo_total decimal(10,2);
        DECLARE nuevo_precio decimal(10,2);
        
        DECLARE cant_actual int;
        DECLARE pre_actual decimal(10,2);
        
        DECLARE actual_existencia int;
        DECLARE actual_precio decimal(10,2);
        
        SELECT precio,existencia INTO actual_precio,actual_existencia FROM producto WHERE codproducto = codigo;
        
        SET nueva_existencia = actual_existencia + n_cantidad;
        SET nuevo_total = (actual_existencia * actual_precio) + (n_cantidad * n_precio);
        SET nuevo_precio = nuevo_total / nueva_existencia;
        
        UPDATE producto SET existencia = nueva_existencia, precio = nuevo_precio WHERE codproducto = codigo;
        
        SELECT nueva_existencia,nuevo_precio;
        
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detalle_temp` (IN `codigo` INT, IN `cantidad` INT, IN `token_user` VARCHAR(50))  BEGIN
    	
        DECLARE precio_actual decimal(10,2);
        SELECT precio INTO  precio_actual FROM producto WHERE codproducto = codigo;
        
        INSERT INTO detalle_temp(token_user,codproducto,cantidad,precio_venta) VALUES(token_user,codigo,cantidad,precio_actual);
        
        SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp tmp
        INNER JOIN producto p 
        ON tmp.codproducto = p.codproducto 
        WHERE tmp.token_user = token_user; 
        
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `anular_factura` (IN `no_factura` INT)  BEGIN
    DECLARE existe_factura int;
    DECLARE registros int;
    DECLARE a int;
    
    DECLARE cod_producto int;
    DECLARE cant_producto int;
    DECLARE existencia_actual int;
    DECLARE nueva_existencia int;
    
    SET existe_factura = (SELECT COUNT(*) FROM factura WHERE nofactura = no_factura and estatus = 1);
    	
      IF existe_factura > 0 THEN
           CREATE TEMPORARY TABLE tbl_tmp (
           id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
           cod_prod BIGINT,
           cant_prod int);
           
           SET a = 1;
           
           SET registros = (SELECT COUNT(*) FROM detallefactura WHERE nofactura = no_factura);
            
            IF registros > 0 THEN 
              INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detallefactura WHERE nofactura = no_factura;
               
               WHILE a <= registros DO 
               		SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id= a;
                    SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = cod_producto; 
                    SET nueva_existencia = existencia_actual + cant_producto;
                    UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;
                          
                    SET a=a+1;
                          
  			   END WHILE;  
               
                  UPDATE factura SET estatus = 2 WHERE nofactura = no_factura;     
                  DROP TABLE tbl_tmp;
                  SELECT * FROM factura WHERE nofactura = no_factura;
                                    
            END IF;
            
          
        ELSE 
          SELECT 0 factura;
        END IF;
                          
                          
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `dataDashboard` ()  BEGIN
    	DECLARE usuarios int;
        DECLARE clientes int;
        DECLARE proveedores int;
        DECLARE productos int;
        DECLARE ventas int;
        
        SELECT COUNT(*) INTO usuarios FROM usuario WHERE estatus != 10;
        SELECT COUNT(*) INTO clientes FROM cliente WHERE estatus != 10;
        SELECT COUNT(*) INTO proveedores FROM proveedor WHERE estatus != 10;
        SELECT COUNT(*) INTO productos FROM producto WHERE estatus != 10;
        SELECT COUNT(*) INTO ventas FROM factura WHERE fecha > CURDATE() AND estatus != 10;
        
        SELECT usuarios,clientes,proveedores,productos,ventas;
        
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detalle_temp` (`id_detalle` INT, `token` VARCHAR(50))  BEGIN 
    	DELETE FROM detalle_temp WHERE correlativo = id_detalle;
        
        SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp tmp
        INNER JOIN producto p
        ON tmp.codproducto = p.codproducto 
        WHERE tmp.token_user = token;
        END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `procesar_venta` (`cod_usuario` INT, `cod_cliente` INT, `token` VARCHAR(50))  BEGIN

        	DECLARE factura INT;

           

        	DECLARE registros INT;

            DECLARE total DECIMAL(10,2);

            

            DECLARE nueva_existencia int;

            DECLARE existencia_actual int;

            

            DECLARE tmp_cod_producto int;

            DECLARE tmp_cant_producto int;

            DECLARE a INT;

            SET a = 1;

            

            CREATE TEMPORARY TABLE tbl_tmp_tokenuser (

                	id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,

                	cod_prod BIGINT,

                	cant_prod int);

             SET registros = (SELECT COUNT(*) FROM detalle_temp WHERE token_user = token);

             

             IF registros > 0 THEN 

             	INSERT INTO tbl_tmp_tokenuser(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp WHERE token_user = token;

                

                INSERT INTO factura(usuario,codcliente) VALUES(cod_usuario,cod_cliente);

                SET factura = LAST_INSERT_ID();

                

                INSERT INTO detallefactura(nofactura,codproducto,cantidad,precio_venta) SELECT (factura) as nofactura, codproducto,cantidad,precio_venta 				FROM detalle_temp WHERE token_user = token; 

                

                WHILE a <= registros DO

                	SELECT cod_prod,cant_prod INTO tmp_cod_producto,tmp_cant_producto FROM tbl_tmp_tokenuser WHERE id = a;

                    SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = tmp_cod_producto;

                    

                    SET nueva_existencia = existencia_actual - tmp_cant_producto;

                    UPDATE producto SET existencia = nueva_existencia WHERE codproducto = tmp_cod_producto;

                    

                    SET a=a+1;

                    

                

                END WHILE; 

                

                SET total = (SELECT SUM(cantidad * precio_venta) FROM detalle_temp WHERE token_user = token);

                UPDATE factura SET totalfactura = total WHERE nofactura = factura;

                DELETE FROM detalle_temp WHERE token_user = token;

                TRUNCATE TABLE tbl_tmp_tokenuser;

                SELECT * FROM factura WHERE nofactura = factura;

             ELSE
             SELECT 0;
             END IF;
             END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idcliente` int(11) NOT NULL,
  `nit` int(11) DEFAULT NULL,
  `nombre` varchar(80) DEFAULT NULL,
  `telefono` int(11) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `dateadd` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idcliente`, `nit`, `nombre`, `telefono`, `direccion`, `dateadd`, `usuario_id`, `estatus`) VALUES
(1, 12345678, 'Willian Wallace', 987523, 'Las Hualtatas', '2021-02-18 19:47:33', 1, 1),
(2, 213221, 'Marta Contreras', 98754334, 'Maria Correa 4', '2021-02-18 19:50:26', 1, 1),
(3, 0, 'Elena Hernandez', 934563463, 'Los Platanos 2111', '2021-02-18 19:53:17', 4, 1),
(4, 0, 'Marta Contreras Cardenas', 98754334, 'Maria Correa 4', '2021-02-19 17:14:43', 1, 1),
(5, 0, 'Marta Contreras', 98754334, 'Maria Correa 4', '2021-02-19 17:18:44', 1, 1),
(6, 0, 'Juan Mora', 2147483647, 'EL CLarinete 796', '2021-02-19 17:21:10', 1, 0),
(7, 0, 'Juan Mora', 2147483647, 'EL CLarinete 796', '2021-02-19 17:24:42', 1, 0),
(8, 0, 'Elena Hernandez', 934563463, 'Los Platanos 2111', '2021-02-20 16:25:17', 4, 1),
(9, 0, 'Pilar Cifuentes', 984711846, 'Los Olimpos', '2021-03-16 17:51:12', 1, 1),
(10, 0, 'Richy', 984943630, 'Los Platanos', '2021-03-16 17:53:55', 1, 1),
(11, 4563634, 'Kalo José', 98452345, 'Chiporrito 254', '2021-03-16 17:57:05', 1, 1),
(12, 5432523, 'Juana Millas', 2147483647, 'El Clarinete 794', '2021-03-16 17:58:54', 1, 1),
(13, 343434, 'Julio Pineda', 54235234, 'Guatemala Ciudad', '2021-03-16 18:10:40', 1, 1),
(14, 343434, 'Julio Pineda', 54235234, 'Guatemala Ciudad', '2021-03-16 18:10:45', 1, 1),
(15, 343434, 'Julio Pineda', 54235234, 'Guatemala Ciudad', '2021-03-16 18:10:59', 1, 1),
(16, 56787, 'Juan Gabriel', 6969696, 'Mexico', '2021-03-16 18:13:41', 1, 1),
(17, 10283545, 'Ricardo Llanos ', 984943630, 'El Olimpo 2541', '2021-03-16 18:15:04', 1, 1),
(18, 46546435, 'Pamela Jiles', 54256754, 'El Congreso 234', '2021-03-16 18:35:17', 1, 1),
(19, 321432, '431423', 41321423, '41321424123', '2021-03-18 21:09:21', 1, 1),
(20, 234235345, 'Chamelo', 985432, 'Los bananos 24543', '2021-03-23 23:32:11', 1, 1),
(21, 123456789, 'Juanito Perez', 99999, 'Los cahuines 65', '2021-03-27 18:55:36', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `id` bigint(20) NOT NULL,
  `nit` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `razon_social` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `telefono` bigint(20) NOT NULL,
  `email` varchar(200) COLLATE utf8_spanish_ci NOT NULL,
  `direccion` text COLLATE utf8_spanish_ci NOT NULL,
  `iva` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id`, `nit`, `nombre`, `razon_social`, `telefono`, `email`, `direccion`, `iva`) VALUES
(1, '565363', 'Pc Servicios', '', 65346346, 'info@abelosh.com', 'calzada la Paz, Guatemala', '19.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallefactura`
--

CREATE TABLE `detallefactura` (
  `correlativo` bigint(11) NOT NULL,
  `nofactura` bigint(11) DEFAULT NULL,
  `codproducto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_venta` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `detallefactura`
--

INSERT INTO `detallefactura` (`correlativo`, `nofactura`, `codproducto`, `cantidad`, `precio_venta`) VALUES
(2, 1, 23, 2, '25000.00'),
(3, 1, 27, 1, '75000.00'),
(4, 2, 24, 1, '45000.00'),
(5, 2, 23, 1, '25000.00'),
(6, 2, 24, 2, '45000.00'),
(7, 3, 29, 2, '80000.00'),
(8, 3, 30, 1, '140000.00'),
(9, 3, 28, 1, '56000.00'),
(10, 4, 24, 1, '45000.00'),
(11, 5, 23, 1, '25000.00'),
(12, 6, 23, 1, '25000.00'),
(13, 6, 24, 1, '45000.00'),
(15, 7, 23, 1, '25000.00'),
(16, 8, 24, 1, '45000.00'),
(17, 9, 24, 1, '45000.00'),
(18, 10, 28, 1, '56000.00'),
(19, 11, 29, 1, '80000.00'),
(20, 12, 23, 1, '25000.00'),
(21, 12, 28, 1, '56000.00'),
(23, 13, 28, 1, '56000.00'),
(24, 14, 29, 1, '80000.00'),
(25, 15, 28, 1, '56000.00'),
(26, 16, 23, 1, '25000.00'),
(27, 17, 23, 1, '25000.00'),
(28, 18, 23, 1, '25000.00'),
(29, 18, 24, 1, '45000.00'),
(31, 19, 23, 1, '25000.00'),
(32, 20, 23, 1, '25000.00'),
(33, 21, 23, 1, '25000.00'),
(34, 22, 28, 1, '56000.00'),
(35, 23, 23, 1, '25000.00'),
(36, 24, 23, 1, '25000.00'),
(37, 24, 29, 1, '80000.00'),
(39, 25, 28, 1, '56000.00'),
(40, 26, 23, 1, '25000.00'),
(41, 27, 23, 1, '25000.00'),
(42, 28, 23, 1, '25000.00'),
(43, 29, 23, 1, '25000.00'),
(44, 30, 23, 1, '25000.00'),
(45, 31, 23, 1, '25000.00'),
(46, 32, 29, 1, '80000.00'),
(47, 33, 29, 1, '80000.00'),
(48, 33, 28, 1, '56000.00'),
(50, 34, 23, 1, '25000.00'),
(51, 35, 29, 1, '80000.00'),
(52, 36, 23, 1, '25000.00'),
(53, 37, 23, 1, '25000.00'),
(54, 38, 23, 1, '25000.00'),
(55, 39, 23, 1, '25000.00'),
(56, 40, 23, 1, '25000.00'),
(57, 41, 28, 1, '56000.00'),
(58, 42, 23, 1, '25000.00'),
(59, 43, 23, 1, '25000.00'),
(60, 44, 23, 1, '25000.00'),
(61, 45, 23, 1, '25000.00'),
(62, 46, 23, 1, '25000.00'),
(63, 47, 23, 1, '25000.00'),
(64, 48, 23, 1, '25000.00'),
(65, 49, 23, 1, '25000.00'),
(66, 50, 23, 1, '25000.00'),
(67, 51, 23, 1, '25000.00'),
(68, 52, 23, 1, '25000.00'),
(69, 53, 23, 1, '25000.00'),
(70, 54, 23, 1, '25000.00'),
(71, 55, 23, 1, '25000.00'),
(72, 56, 23, 1, '25000.00'),
(73, 57, 23, 1, '25000.00'),
(74, 58, 23, 1, '25000.00'),
(75, 59, 23, 1, '25000.00'),
(76, 60, 23, 1, '25000.00'),
(77, 61, 23, 1, '25000.00'),
(78, 62, 32, 1, '120000.00'),
(79, 63, 32, 1, '120000.00'),
(80, 64, 23, 1, '25000.00'),
(81, 65, 32, 1, '120000.00'),
(82, 66, 32, 1, '120000.00'),
(83, 67, 23, 1, '25000.00'),
(84, 67, 32, 1, '120000.00'),
(86, 68, 32, 1, '120000.00'),
(87, 69, 32, 1, '120000.00'),
(88, 70, 32, 1, '120000.00'),
(89, 71, 32, 1, '120000.00'),
(90, 72, 32, 1, '120000.00'),
(91, 73, 30, 1, '140000.00'),
(92, 74, 30, 1, '140000.00'),
(93, 75, 30, 1, '140000.00'),
(94, 76, 30, 1, '140000.00'),
(95, 77, 30, 1, '140000.00'),
(96, 78, 30, 1, '140000.00'),
(97, 79, 30, 1, '140000.00'),
(98, 80, 24, 1, '45000.00'),
(99, 81, 32, 1, '120000.00'),
(100, 82, 23, 2, '25000.00'),
(101, 82, 24, 1, '45000.00'),
(102, 83, 23, 1, '25000.00'),
(103, 83, 24, 1, '45000.00'),
(105, 84, 23, 1, '25000.00'),
(106, 84, 24, 1, '45000.00'),
(108, 85, 24, 2, '45000.00'),
(109, 86, 23, 1, '25000.00'),
(110, 87, 23, 1, '25000.00'),
(111, 87, 24, 1, '45000.00'),
(113, 88, 23, 1, '25000.00'),
(114, 89, 23, 2, '25000.00'),
(115, 90, 24, 1, '45000.00'),
(116, 91, 24, 1, '45000.00'),
(117, 92, 24, 1, '45000.00'),
(118, 93, 24, 1, '45000.00'),
(119, 94, 23, 1, '25000.00'),
(120, 94, 24, 2, '45000.00'),
(121, 95, 23, 1, '25000.00'),
(122, 95, 24, 1, '45000.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_temp`
--

CREATE TABLE `detalle_temp` (
  `correlativo` int(11) NOT NULL,
  `token_user` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `codproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detalle_temp`
--

INSERT INTO `detalle_temp` (`correlativo`, `token_user`, `codproducto`, `cantidad`, `precio_venta`) VALUES
(92, 'd41d8cd98f00b204e9800998ecf8427e', 23, 1, '25000.00'),
(93, 'd41d8cd98f00b204e9800998ecf8427e', 23, 1, '25000.00'),
(94, 'd41d8cd98f00b204e9800998ecf8427e', 28, 1, '56000.00'),
(95, 'd41d8cd98f00b204e9800998ecf8427e', 32, 1, '120000.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--

CREATE TABLE `entradas` (
  `correlativo` int(11) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `entradas`
--

INSERT INTO `entradas` (`correlativo`, `codproducto`, `fecha`, `cantidad`, `precio`, `usuario_id`) VALUES
(42, 23, '2021-03-08 10:56:11', 2, '25000.00', 1),
(43, 24, '2021-03-08 10:58:24', 2, '45000.00', 1),
(44, 25, '2021-03-08 11:48:27', 1, '45000.00', 1),
(45, 26, '2021-03-08 11:53:39', 2, '35000.00', 1),
(46, 27, '2021-03-08 11:54:08', 1, '75000.00', 1),
(47, 28, '2021-03-08 11:54:45', 1, '56000.00', 1),
(48, 29, '2021-03-08 11:55:25', 2, '80000.00', 1),
(49, 30, '2021-03-08 11:55:54', 1, '140000.00', 1),
(50, 31, '2021-03-08 11:56:22', 3, '15000.00', 1),
(51, 32, '2021-03-08 12:02:38', 1, '120000.00', 1),
(52, 34, '2021-03-08 21:57:20', 3, '12500.00', 1),
(53, 25, '2021-03-09 09:27:28', 5, '5000.00', 1),
(54, 35, '2021-03-09 15:45:12', 1, '50600.00', 1),
(55, 36, '2021-03-10 22:28:13', 3, '25000.00', 1),
(56, 37, '2021-03-10 22:31:01', 3, '23000.00', 1),
(57, 38, '2021-03-12 16:36:59', 4, '12500.00', 1),
(58, 39, '2021-03-12 16:37:47', 5, '13000.00', 1),
(59, 40, '2021-03-23 23:30:06', 20, '26000.00', 1),
(60, 41, '2021-04-23 15:56:44', 50, '45500.00', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `nofactura` bigint(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) DEFAULT NULL,
  `codcliente` int(11) DEFAULT NULL,
  `totalfactura` decimal(10,2) DEFAULT NULL,
  `estatus` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`nofactura`, `fecha`, `usuario`, `codcliente`, `totalfactura`, `estatus`) VALUES
(1, '2021-03-27 18:06:08', 1, 2, '125000.00', 1),
(2, '2021-03-28 17:18:25', 1, 1, '160000.00', 2),
(3, '2021-03-28 17:23:29', 1, 1, '356000.00', 1),
(4, '2021-03-31 16:03:32', 1, 1, '45000.00', 2),
(5, '2021-03-31 16:34:53', 1, 1, '25000.00', 2),
(6, '2021-03-31 17:19:25', 1, 1, '70000.00', 1),
(7, '2021-03-31 17:22:43', 1, 1, '25000.00', 1),
(8, '2021-03-31 17:38:19', 1, 1, '45000.00', 1),
(9, '2021-03-31 17:41:25', 1, 1, '45000.00', 1),
(10, '2021-03-31 17:42:35', 1, 1, '56000.00', 1),
(11, '2021-03-31 17:44:03', 1, 1, '80000.00', 1),
(12, '2021-03-31 17:47:34', 1, 1, '81000.00', 1),
(13, '2021-03-31 17:52:42', 1, 1, '56000.00', 1),
(14, '2021-03-31 17:53:39', 1, 1, '80000.00', 1),
(15, '2021-03-31 17:55:18', 1, 1, '56000.00', 1),
(16, '2021-03-31 17:56:15', 1, 1, '25000.00', 1),
(17, '2021-03-31 18:04:20', 1, 1, '25000.00', 1),
(18, '2021-03-31 18:05:38', 1, 1, '70000.00', 1),
(19, '2021-03-31 18:07:16', 1, 1, '25000.00', 1),
(20, '2021-03-31 18:08:17', 1, 1, '25000.00', 1),
(21, '2021-03-31 18:15:08', 1, 1, '25000.00', 1),
(22, '2021-03-31 18:32:42', 1, 1, '56000.00', 1),
(23, '2021-03-31 18:33:11', 1, 1, '25000.00', 1),
(24, '2021-03-31 18:34:36', 1, 1, '105000.00', 1),
(25, '2021-03-31 18:36:48', 1, 1, '56000.00', 2),
(26, '2021-03-31 18:37:26', 1, 1, '25000.00', 1),
(27, '2021-03-31 18:38:38', 1, 1, '25000.00', 1),
(28, '2021-03-31 18:39:57', 1, 1, '25000.00', 1),
(29, '2021-03-31 18:41:50', 1, 1, '25000.00', 1),
(30, '2021-03-31 18:45:17', 1, 1, '25000.00', 2),
(31, '2021-03-31 18:46:33', 1, 1, '25000.00', 1),
(32, '2021-03-31 18:49:53', 1, 1, '80000.00', 1),
(33, '2021-03-31 18:50:23', 1, 1, '136000.00', 1),
(34, '2021-03-31 18:55:14', 1, 1, '25000.00', 1),
(35, '2021-03-31 18:55:40', 1, 1, '80000.00', 2),
(36, '2021-03-31 18:56:48', 1, 1, '25000.00', 1),
(37, '2021-03-31 18:57:16', 1, 1, '25000.00', 1),
(38, '2021-03-31 18:57:59', 1, 1, '25000.00', 1),
(39, '2021-04-01 15:15:35', 1, 1, '25000.00', 1),
(40, '2021-04-01 15:17:12', 1, 1, '25000.00', 1),
(41, '2021-04-01 15:20:13', 1, 1, '56000.00', 1),
(42, '2021-04-01 15:25:23', 1, 1, '25000.00', 1),
(43, '2021-04-01 15:26:03', 1, 1, '25000.00', 1),
(44, '2021-04-01 15:28:15', 1, 1, '25000.00', 1),
(45, '2021-04-01 15:29:51', 1, 1, '25000.00', 1),
(46, '2021-04-01 15:32:55', 1, 1, '25000.00', 1),
(47, '2021-04-01 15:33:27', 1, 1, '25000.00', 1),
(48, '2021-04-01 15:45:57', 1, 1, '25000.00', 1),
(49, '2021-04-01 15:50:12', 1, 1, '25000.00', 1),
(50, '2021-04-01 16:02:32', 1, 1, '25000.00', 1),
(51, '2021-04-01 16:04:23', 1, 1, '25000.00', 1),
(52, '2021-04-01 16:05:55', 1, 1, '25000.00', 1),
(53, '2021-04-01 16:12:00', 1, 1, '25000.00', 1),
(54, '2021-04-01 16:15:54', 1, 1, '25000.00', 1),
(55, '2021-04-01 16:27:58', 1, 1, '25000.00', 1),
(56, '2021-04-01 16:30:27', 1, 1, '25000.00', 1),
(57, '2021-04-01 16:31:00', 1, 1, '25000.00', 1),
(58, '2021-04-01 16:33:48', 1, 1, '25000.00', 1),
(59, '2021-04-01 16:34:35', 1, 1, '25000.00', 1),
(60, '2021-04-01 16:38:26', 1, 1, '25000.00', 1),
(61, '2021-04-01 16:42:06', 1, 1, '25000.00', 1),
(62, '2021-04-01 16:42:57', 1, 1, '120000.00', 1),
(63, '2021-04-01 16:53:07', 1, 1, '120000.00', 1),
(64, '2021-04-01 17:11:11', 1, 1, '25000.00', 1),
(65, '2021-04-01 17:12:09', 1, 1, '120000.00', 1),
(66, '2021-04-01 17:14:43', 1, 1, '120000.00', 1),
(67, '2021-04-01 17:15:21', 1, 1, '145000.00', 1),
(68, '2021-04-01 17:16:10', 1, 1, '120000.00', 1),
(69, '2021-04-01 17:20:26', 1, 1, '120000.00', 1),
(70, '2021-04-01 17:23:33', 1, 1, '120000.00', 1),
(71, '2021-04-01 17:51:11', 1, 1, '120000.00', 1),
(72, '2021-04-01 17:53:35', 1, 1, '120000.00', 1),
(73, '2021-04-01 18:06:44', 1, 1, '140000.00', 1),
(74, '2021-04-01 18:11:09', 1, 1, '140000.00', 1),
(75, '2021-04-01 18:22:10', 1, 1, '140000.00', 1),
(76, '2021-04-01 18:26:50', 1, 1, '140000.00', 1),
(77, '2021-04-01 18:34:39', 1, 1, '140000.00', 1),
(78, '2021-04-01 18:50:38', 1, 1, '140000.00', 1),
(79, '2021-04-01 19:17:39', 1, 1, '140000.00', 1),
(80, '2021-04-02 18:44:02', 1, 1, '45000.00', 2),
(81, '2021-04-09 18:03:41', 1, 1, '120000.00', 2),
(82, '2021-04-12 18:47:53', 1, 1, '95000.00', 2),
(83, '2021-04-13 20:43:11', 1, 1, '70000.00', 1),
(84, '2021-04-13 21:13:35', 1, 1, '70000.00', 1),
(85, '2021-04-13 21:15:07', 1, 1, '90000.00', 1),
(86, '2021-04-13 21:20:00', 1, 1, '25000.00', 1),
(87, '2021-04-13 21:31:01', 1, 1, '70000.00', 1),
(88, '2021-04-13 21:32:06', 1, 1, '25000.00', 1),
(89, '2021-04-13 21:36:05', 1, 1, '50000.00', 2),
(90, '2021-04-13 22:02:42', 1, 1, '45000.00', 2),
(91, '2021-04-13 22:07:36', 1, 1, '45000.00', 2),
(92, '2021-04-13 22:08:04', 1, 1, '45000.00', 2),
(93, '2021-04-13 23:07:41', 1, 1, '45000.00', 2),
(94, '2021-04-14 18:43:03', 1, 1, '115000.00', 2),
(95, '2021-04-19 18:41:24', 1, 1, '70000.00', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `codproducto` int(11) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `proveedor` int(11) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `existencia` int(11) DEFAULT NULL,
  `dateadd` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT 1,
  `foto` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codproducto`, `descripcion`, `proveedor`, `precio`, `existencia`, `dateadd`, `usuario_id`, `estatus`, `foto`) VALUES
(23, 'Mallas', 18, '25000.00', 5, '2021-03-08 10:56:11', 1, 1, 'mallas.jpg'),
(24, 'Mancuernas', 18, '45000.00', 5, '2021-03-08 10:58:24', 1, 1, 'mancuernas.jpg'),
(25, 'Disco Duro SSD', 19, '11666.67', 6, '2021-03-08 11:48:27', 1, 0, 'discoDuroSSD.jpg'),
(26, 'Disipador ', 11, '35000.00', 2, '2021-03-08 11:53:39', 1, 0, 'disipador.jpg'),
(27, 'Pantalla', 5, '75000.00', 8, '2021-03-08 11:54:08', 1, 0, 'pantalla.jpg'),
(28, 'Tarjeta gräfica', 11, '56000.00', 1, '2021-03-08 11:54:45', 1, 1, 'tarjeta.jpg'),
(29, 'Memoria', 5, '80000.00', 1, '2021-03-08 11:55:25', 1, 1, 'memoria.jpg'),
(30, 'Placa Madre', 8, '140000.00', 0, '2021-03-08 11:55:54', 1, 1, 'placaMadre.jpg'),
(31, 'Lapiz Digital', 1, '15000.00', 3, '2021-03-08 11:56:22', 1, 0, 'lapizdigital.jpg'),
(32, 'Tarjeta Gamer', 18, '120000.00', 0, '2021-03-08 12:02:38', 1, 1, 'tarjeta.jpg'),
(34, 'Petos deportivos', 18, '12500.00', 3, '2021-03-08 21:57:20', 1, 1, 'petos.jpg'),
(35, 'Reloj de Dama Citysen', 2, '50600.00', 10, '2021-03-09 15:45:12', 1, 0, ''),
(36, 'Balon de futbol', 18, '25000.00', 3, '2021-03-10 22:28:13', 1, 0, 'balos.png'),
(37, 'Balon deportivo', 18, '23000.00', 3, '2021-03-10 22:31:01', 1, 1, 'balonFutbol.jpg'),
(38, 'Malla roja', 18, '12500.00', 4, '2021-03-12 16:36:59', 1, 1, 'mallaRoja.jpg'),
(39, 'Malla blanca', 18, '13000.00', 5, '2021-03-12 16:37:47', 1, 1, 'mallaBlanca.jpg.jpg'),
(40, 'Bototos', 12, '26000.00', 20, '2021-03-23 23:30:06', 1, 0, 'bototos.jpg'),
(41, 'Zapatos de seguridad', 12, '45500.00', 50, '2021-04-23 15:56:44', 1, 0, 'bototos.jpg');

--
-- Disparadores `producto`
--
DELIMITER $$
CREATE TRIGGER `entradas_A_I` AFTER INSERT ON `producto` FOR EACH ROW BEGIN
    	INSERT INTO entradas(codproducto,cantidad,precio,usuario_id)
        VALUES(new.codproducto,new.existencia,new.precio,new.usuario_id);
        END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `codproveedor` int(11) NOT NULL,
  `proveedor` varchar(100) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `telefono` bigint(11) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `dateadd` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) NOT NULL,
  `estatus` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`codproveedor`, `proveedor`, `contacto`, `telefono`, `direccion`, `dateadd`, `usuario_id`, `estatus`) VALUES
(1, 'BIC', 'Claudia Rosales', 789877889, 'Avenida las Americas', '2021-02-21 19:18:07', 0, 1),
(2, 'CASIO', 'Jorge Herrera', 12121212, 'Calzada Las Flores', '2021-02-21 19:18:07', 0, 1),
(3, 'Omega 5', 'Julio Estrada Omega', 982877489, 'Avenida Elena Zona 4, Guatemala', '2021-02-21 19:18:07', 0, 1),
(4, 'Dell Compani', 'Roberto Estrada', 2147483647, 'Guatemala, Guatemala', '2021-02-21 19:18:07', 0, 0),
(5, 'Olimpia S.A', 'Elena Franco Morales', 564535676, '5ta. Avenida Zona 4 Ciudad', '2021-02-21 19:18:07', 0, 1),
(6, 'Oster', 'Fernando Guerra', 78987678, 'Calzada La Paz, Guatemala', '2021-02-21 19:18:07', 0, 1),
(7, 'ACELTECSA S.A', 'Ruben PÃ©rez', 789879889, 'Colonia las Victorias', '2021-02-21 19:18:07', 0, 1),
(8, 'Sony', 'Julieta Contreras', 89476787, 'Antigua Guatemala', '2021-02-21 19:18:07', 0, 1),
(9, 'VAIO', 'Felix Arnoldo Rojas', 476378276, 'Avenida las Americas Zona 13', '2021-02-21 19:18:07', 0, 1),
(10, 'SUMAR', 'Oscar Maldonado', 788376787, 'Colonia San Jose, Zona 5 Guatemala', '2021-02-21 19:18:07', 0, 1),
(11, 'HP', 'Angel Cardona', 2147483647, '5ta. calle zona 4 Guatemala', '2021-02-21 19:18:07', 0, 1),
(12, 'GoldenClass', 'Nadia Vergara', 9453254, 'Salvador Reyes 65', '2021-02-21 19:50:32', 0, 1),
(13, 'GoldenClass', 'Nadia Vergara', 9453254, 'Salvador Reyes 65', '2021-02-21 19:51:05', 1, 0),
(14, 'Zonacolor', 'Carlos Jadue', 95634653, 'Av Vicuña Mackenna 86', '2021-02-21 19:52:06', 1, 1),
(15, 'Ripley', 'Andres Vragas', 45523523, 'Las hualtatas 345', '2021-02-21 20:05:44', 1, 1),
(16, 'Ripley', 'Andres Vragas', 45523523, 'Las hualtatas 345', '2021-02-21 20:08:54', 1, 0),
(17, 'PHP', 'Angel Cardona', 78987876, '5ta calle zona 4 g', '2021-02-21 21:02:24', 16, 1),
(18, 'Falabella', 'Javier Espinoza', 96536346, 'El Alerce 3564', '2021-02-27 21:39:28', 1, 1),
(19, 'ACER', 'Rodrigo Arenales', 987989873, 'Calzada Buena Vista', '2021-03-01 19:47:09', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `idrol` int(11) NOT NULL,
  `rol` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`idrol`, `rol`) VALUES
(1, 'Administador'),
(2, 'Supervisor'),
(3, 'Vendedor');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `usuario` varchar(15) DEFAULT NULL,
  `clave` varchar(100) DEFAULT NULL,
  `rol` int(11) DEFAULT NULL,
  `estatus` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `correo`, `usuario`, `clave`, `rol`, `estatus`) VALUES
(1, 'Ricardo', 'rllanos@rllanosprogramador.com', 'admin', '23451069c7506461fe6889b48a2e8f32', 1, 1),
(4, 'Julio Pérez', 'juanito@gmail.com', 'Julio', 'c027636003b468821081e281758e35ff', 2, 1),
(5, 'Julio Martinez', 'julioperes@gmail.com', 'julio perez', '123', 3, 1),
(9, 'Rodolfo Andres Gomez', 'rodolfoandres@gmail.com', 'Rodolfop', '2e92962c0b6996add9517e4242ea9bdc', 3, 0),
(10, 'Andrea Tessa', 'Andreatesa@gmail.com', 'Andreita', '7813d1590d28a7dd372ad54b5d29d033', 3, 1),
(11, 'Mon Laferte M', 'montlaferte@gmail.com', 'MontLaferte', '7813d1590d28a7dd372ad54b5d29d033', 3, 1),
(14, 'Henry Carlos', 'hernry@gmail.com', 'henry', 'b59c67bf196a4758191e42f76670ceba', 3, 1),
(15, 'Pilar Cifuentes', 'pilar@gmail.com', 'Pilar', 'fea9c11c4ad9a395a636ed944a28b51a', 3, 1),
(16, 'Kalo Jose', 'kalo@gmail.com', 'kalo', '765d5fb115a9f6a3e0b23b80a5b2e4c4', 2, 1),
(17, 'Pedro Urdemales', 'pedro@gmail.com', 'PedroU', '2be9bd7a3434f7038ca27d1918de58bd', 3, 0),
(18, 'rewrweq', 'wqerrqwe@gmail.com', 'ewrqrewqew', '3d2172418ce305c7d16d4b05597c6a59', 2, 0),
(19, 'Carlos Diaz', 'carlitos@gmail.com', 'Carlos', '7b9dc501afe4ee11c56a4831e20cee71', 3, 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idcliente`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `codproducto` (`codproducto`),
  ADD KEY `nofactura` (`nofactura`);

--
-- Indices de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `detalle_temp_ibfk_1` (`token_user`),
  ADD KEY `detalle_temp_ibfk_2` (`codproducto`);

--
-- Indices de la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `codproducto` (`codproducto`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`nofactura`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `codcliente` (`codcliente`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`codproducto`),
  ADD KEY `proveedor` (`proveedor`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`codproveedor`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`idrol`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idusuario`),
  ADD KEY `rol` (`rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idcliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  MODIFY `correlativo` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=123;

--
-- AUTO_INCREMENT de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=137;

--
-- AUTO_INCREMENT de la tabla `entradas`
--
ALTER TABLE `entradas`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `nofactura` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `codproducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `codproveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `idrol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detallefactura`
--
ALTER TABLE `detallefactura`
  ADD CONSTRAINT `detallefactura_ibfk_1` FOREIGN KEY (`nofactura`) REFERENCES `factura` (`nofactura`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detallefactura_ibfk_2` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD CONSTRAINT `detalle_temp_ibfk_2` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD CONSTRAINT `entradas_ibfk_1` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `factura_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `factura_ibfk_2` FOREIGN KEY (`codcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`proveedor`) REFERENCES `proveedor` (`codproveedor`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`rol`) REFERENCES `rol` (`idrol`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
