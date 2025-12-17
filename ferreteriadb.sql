-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-11-2025 a las 07:59:12
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ferreteriadb`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `idCategoria` int(11) NOT NULL,
  `nombreCategoria` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`idCategoria`, `nombreCategoria`, `descripcion`) VALUES
(1, 'HERRAMIENTAS', 'Conjunto de herramientas manuales y eléctricas para trabajos de reparación, ensamblaje y mantenimiento en general.'),
(2, 'CONSTRUCCIÓN', 'Materiales y accesorios usados en obras civiles, remodelaciones y estructuras como cemento, ladrillos y agregados.'),
(3, 'FONTANERÍA', 'Productos y accesorios para instalaciones de agua potable, desagüe y gas: tuberías, conexiones, accesorios y válvulas.'),
(4, 'ELECTRICIDAD', 'Equipos, cables, interruptores y componentes esenciales para instalaciones eléctricas residenciales y comerciales.'),
(5, 'PINTURAS', 'Pinturas, esmaltes, aerosoles, rodillos y productos para el acabado, protección y decoración de superficies.'),
(6, 'JARDINERÍA', 'Artículos y herramientas para el cuidado del jardín, plantas y áreas verdes, incluyendo mangueras y fertilizantes.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalletransacciones`
--

CREATE TABLE `detalletransacciones` (
  `idTransaccion` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL CHECK (`cantidad` > 0),
  `precioUnitario` decimal(10,2) NOT NULL CHECK (`precioUnitario` >= 0),
  `subtotal` decimal(10,2) GENERATED ALWAYS AS (`cantidad` * `precioUnitario`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalletransacciones`
--

INSERT INTO `detalletransacciones` (`idTransaccion`, `idProducto`, `cantidad`, `precioUnitario`) VALUES
(1, 1, 2, 10.00),
(2, 2, 4, 25.00),
(3, 2, 2, 25.00),
(11, 3, 4, 22.00),
(12, 2, 2, 25.00),
(13, 3, 2, 22.00),
(14, 3, 1, 22.00),
(16, 3, 4, 22.00),
(25, 1, 2, 10.00),
(26, 1, 2, 10.00),
(27, 1, 4, 10.00),
(28, 1, 5, 10.00),
(29, 1, 22, 10.00),
(30, 1, 6, 10.00),
(30, 2, 1, 25.00),
(30, 3, 1, 22.00),
(31, 2, 1, 25.00),
(32, 2, 2, 25.00),
(33, 2, 1, 25.00),
(34, 2, 4, 25.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `operaciones`
--

CREATE TABLE `operaciones` (
  `idOperacion` int(11) NOT NULL,
  `nombreOperacion` varchar(50) NOT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `operaciones`
--

INSERT INTO `operaciones` (`idOperacion`, `nombreOperacion`, `descripcion`) VALUES
(1, 'Compra', 'Operación de ingreso de productos al almacén'),
(2, 'Venta', 'Operación de salida y venta de productos al cliente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `idPersona` int(11) NOT NULL,
  `idTipoPersona` int(11) NOT NULL,
  `nombres` varchar(100) DEFAULT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `documento` varchar(15) DEFAULT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT 1,
  `fechaRegistro` datetime DEFAULT current_timestamp(),
  `razonSocial` varchar(150) DEFAULT NULL,
  `ruc` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`idPersona`, `idTipoPersona`, `nombres`, `apellidos`, `documento`, `telefono`, `correo`, `direccion`, `estado`, `fechaRegistro`, `razonSocial`, `ruc`) VALUES
(6, 1, 'Jose Manuel', 'Carrasco Millan', '74952459', '96791861s', 'cmillanjosemanu@uss.edu.pe', 'Orellana 690', 1, '2025-11-19 23:25:52', NULL, NULL),
(9, 2, 'Juan Pablo', 'Millan', '74952452', '967918614', 'manuelxi@gmail.com', 'a lado de una casa', 1, '2025-11-20 02:14:38', NULL, NULL),
(11, 3, NULL, NULL, NULL, '967918612', 'pacasmayo@gmail.com', 'Cal. la Colonia Nro. 150', 1, '2025-11-21 01:32:28', 'CEMENTOS PACASMAYO S.A.A.', '20419387658'),
(12, 3, NULL, NULL, NULL, '967918421', 'sdaadsads@gmail.com', 'Av. Santiag Antunez de Mayolo Nro. S/n Z.I. Zona Industrial', 1, '2025-11-21 03:26:02', 'EMPRESA SIDERURGICA DEL PERU S.A.A.', '20402885549'),
(13, 3, NULL, NULL, NULL, '967918321', 'dasads@gmail.com', 'Car. Panamericana Sur Nro. 241 Panamericana Sur', 1, '2025-11-21 03:26:50', 'CORPORACION ACEROS AREQUIPA S.A.', '20370146994'),
(14, 1, 'admin', 'admin', '86732123', '967918321', 'admin@gmail.com', 'admin', 1, '2025-11-21 03:46:45', NULL, NULL),
(15, 2, 'hola', 'asda', '72422443', '967918634', 'sdadas@gmail.com', 'dsaasdd', 1, '2025-11-21 23:54:59', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `idProducto` int(11) NOT NULL,
  `idCategoria` int(11) NOT NULL,
  `nombreProducto` varchar(150) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `precioVenta` decimal(10,2) NOT NULL CHECK (`precioVenta` >= 0),
  `stock` int(11) DEFAULT 0 CHECK (`stock` >= 0),
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`idProducto`, `idCategoria`, `nombreProducto`, `descripcion`, `precioVenta`, `stock`, `estado`) VALUES
(1, 1, 'SIERRA DE MANO', 'xdd', 10.00, 17, 1),
(2, 2, 'Cemento', 'xd', 25.00, 12, 1),
(3, 2, 'Prueba', 'sdads', 22.00, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipopersona`
--

CREATE TABLE `tipopersona` (
  `idTipoPersona` int(11) NOT NULL,
  `nombreTipo` varchar(50) NOT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipopersona`
--

INSERT INTO `tipopersona` (`idTipoPersona`, `nombreTipo`, `descripcion`) VALUES
(1, 'Trabajador', 'Trabajador de la empresa (empleado interno)'),
(2, 'Cliente', 'Cliente de la ferretería'),
(3, 'Proveedor', 'Proveedor de productos y materiales');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transacciones`
--

CREATE TABLE `transacciones` (
  `idTransaccion` int(11) NOT NULL,
  `idOperacion` int(11) NOT NULL,
  `idPersona` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `fechaTransaccion` datetime DEFAULT current_timestamp(),
  `metodoPago` varchar(50) DEFAULT NULL,
  `total` decimal(10,2) DEFAULT 0.00 CHECK (`total` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `transacciones`
--

INSERT INTO `transacciones` (`idTransaccion`, `idOperacion`, `idPersona`, `idUsuario`, `fechaTransaccion`, `metodoPago`, `total`) VALUES
(1, 2, 9, 1, '2025-11-20 23:20:04', 'Efectivo', 20.00),
(2, 2, 9, 1, '2025-11-20 23:33:37', 'Efectivo', 100.00),
(3, 1, 11, 1, '2025-11-21 02:06:01', 'Transferencia', 50.00),
(11, 1, 13, 1, '2025-11-21 03:43:48', 'Transferencia', 88.00),
(12, 1, 11, 1, '2025-11-21 03:45:12', 'Efectivo', 50.00),
(13, 1, 12, 1, '2025-11-21 03:53:40', 'Transferencia', 44.00),
(14, 2, 9, 1, '2025-11-21 03:54:12', 'Efectivo', 22.00),
(16, 1, 12, 1, '2025-11-21 03:57:39', 'Efectivo', 88.00),
(25, 2, 9, 1, '2025-11-21 04:26:09', 'Efectivo', 20.00),
(26, 2, 9, 1, '2025-11-21 04:26:31', 'Efectivo', 20.00),
(27, 1, 13, 1, '2025-11-21 04:27:09', 'Transferencia', 40.00),
(28, 2, 9, 1, '2025-11-21 23:24:42', 'Tarjeta', 50.00),
(29, 1, 12, 1, '2025-11-21 23:26:26', 'Transferencia', 220.00),
(30, 2, 9, 1, '2025-11-21 23:33:33', 'Efectivo', 107.00),
(31, 2, 9, 1, '2025-11-22 00:05:56', 'Efectivo', 25.00),
(32, 2, 9, 1, '2025-11-22 00:19:48', 'Tarjeta', 50.00),
(33, 2, 15, 1, '2025-11-22 00:34:29', 'Tarjeta', 25.00),
(34, 2, 15, 2, '2025-11-22 01:32:39', 'Yape/Plin', 100.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `idUsuario` int(11) NOT NULL,
  `idPersona` int(11) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `rol` enum('Administrador','Vendedor') DEFAULT 'Vendedor',
  `estado` tinyint(1) DEFAULT 1,
  `fechaRegistro` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`idUsuario`, `idPersona`, `usuario`, `contrasena`, `rol`, `estado`, `fechaRegistro`) VALUES
(1, 6, 'cmillanjosemanu@uss.edu.pe', '$2a$10$kesAN/FMV4LfXl87TW4p7.UF9EDmbKE24pBU18IzbRW6TaUFQEG0W', 'Administrador', 1, '2025-11-19 23:25:52'),
(2, 14, 'admin', '$2a$10$VxH2qa9WmIdPaGjr84dz2uQ/jQMUIPwpjJPCxrxa2SjC9LDboBIxe', 'Administrador', 1, '2025-11-21 03:46:45');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`idCategoria`),
  ADD UNIQUE KEY `nombreCategoria` (`nombreCategoria`);

--
-- Indices de la tabla `detalletransacciones`
--
ALTER TABLE `detalletransacciones`
  ADD KEY `idTransaccion` (`idTransaccion`),
  ADD KEY `idProducto` (`idProducto`);

--
-- Indices de la tabla `operaciones`
--
ALTER TABLE `operaciones`
  ADD PRIMARY KEY (`idOperacion`),
  ADD UNIQUE KEY `nombreOperacion` (`nombreOperacion`);

--
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`idPersona`),
  ADD UNIQUE KEY `documento` (`documento`),
  ADD KEY `idTipoPersona` (`idTipoPersona`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`idProducto`),
  ADD KEY `idCategoria` (`idCategoria`);

--
-- Indices de la tabla `tipopersona`
--
ALTER TABLE `tipopersona`
  ADD PRIMARY KEY (`idTipoPersona`),
  ADD UNIQUE KEY `nombreTipo` (`nombreTipo`);

--
-- Indices de la tabla `transacciones`
--
ALTER TABLE `transacciones`
  ADD PRIMARY KEY (`idTransaccion`),
  ADD KEY `idOperacion` (`idOperacion`),
  ADD KEY `idPersona` (`idPersona`),
  ADD KEY `idUsuario` (`idUsuario`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`idUsuario`),
  ADD UNIQUE KEY `usuario` (`usuario`),
  ADD KEY `idPersona` (`idPersona`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `idCategoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `operaciones`
--
ALTER TABLE `operaciones`
  MODIFY `idOperacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `idPersona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `idProducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipopersona`
--
ALTER TABLE `tipopersona`
  MODIFY `idTipoPersona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `transacciones`
--
ALTER TABLE `transacciones`
  MODIFY `idTransaccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalletransacciones`
--
ALTER TABLE `detalletransacciones`
  ADD CONSTRAINT `detalletransacciones_ibfk_1` FOREIGN KEY (`idTransaccion`) REFERENCES `transacciones` (`idTransaccion`),
  ADD CONSTRAINT `detalletransacciones_ibfk_2` FOREIGN KEY (`idProducto`) REFERENCES `productos` (`idProducto`);

--
-- Filtros para la tabla `persona`
--
ALTER TABLE `persona`
  ADD CONSTRAINT `persona_ibfk_1` FOREIGN KEY (`idTipoPersona`) REFERENCES `tipopersona` (`idTipoPersona`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`idCategoria`) REFERENCES `categorias` (`idCategoria`);

--
-- Filtros para la tabla `transacciones`
--
ALTER TABLE `transacciones`
  ADD CONSTRAINT `transacciones_ibfk_1` FOREIGN KEY (`idOperacion`) REFERENCES `operaciones` (`idOperacion`),
  ADD CONSTRAINT `transacciones_ibfk_2` FOREIGN KEY (`idPersona`) REFERENCES `persona` (`idPersona`),
  ADD CONSTRAINT `transacciones_ibfk_3` FOREIGN KEY (`idUsuario`) REFERENCES `usuarios` (`idUsuario`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`idPersona`) REFERENCES `persona` (`idPersona`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
