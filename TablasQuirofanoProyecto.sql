
     -- CREATE TABLE

CREATE DATABASE if NOT EXISTS BloqueQuirurgico;
USE BloqueQuirurgico;

DROP TABLE if EXISTS panelTecnico;
DROP TABLE if EXISTS lampara;
DROP TABLE if EXISTS columnaquirurgica;
DROP TABLE if EXISTS Mediciones;
DROP TABLE if EXISTS revision;
DROP TABLE if EXISTS equipamientoElectromedico;
DROP TABLE if EXISTS ingenieroBiomedico;
DROP TABLE if EXISTS normativaClimatizacion;
DROP TABLE if EXISTS normativaElectricidad;
DROP TABLE if EXISTS empresa;
DROP TABLE if EXISTS revisionAuxiliar;



CREATE TABLE if NOT EXISTS empresa (
cif VARCHAR(10) PRIMARY KEY UNIQUE,
nombreEmpresa VARCHAR(20) NOT null,
direccionWeb VARCHAR(50),
pais VARCHAR(20),
direccion VARCHAR(100),
telefono VARCHAR(14) );


CREATE TABLE if NOT EXISTS normativaElectricidad (
fechaNormativaElectricidad INT PRIMARY KEY,
nivelLuxMaxima INT,
nivelLuxMinima INT,
periodicidadRevisionDias INT,
CONSTRAINT intervalosConSentido CHECK (nivelLuxMaxima>nivelLuxMinima));


CREATE TABLE if NOT EXISTS normativaClimatizacion (
fechaNormativaClimatizacion INT PRIMARY KEY,
caudalAireMinimo INT,
caudalAireMaximo INT,
gradosMaximos INT,
gradosMinimos INT,
porcentajeHumedadMaximo INT,
porcentajeHumedadMinimo INT,
periodicidadRevisionDias INT ,
CONSTRAINT intervalosConSentido2 CHECK 
(caudalAireMaximo>caudalAireMinimo AND gradosMaximos>gradosMinimos AND porcentajeHumedadMaximo>porcentajeHumedadMinimo));


CREATE TABLE if NOT EXISTS ingenieroBiomedico (
dni VARCHAR(9) PRIMARY KEY UNIQUE,
numeroSeguridadSocial VARCHAR(15) UNIQUE,
nombre VARCHAR(50) NOT NULL,
apellidos VARCHAR(50) NOT NULL,
titulacion VARCHAR(30),
fechaNacimiento DATE,
codigoPostal VARCHAR(5) ,
telefono VARCHAR(14),
correoElectronico VARCHAR(60),
cif VARCHAR(9) ,
FOREIGN KEY (cif) REFERENCES empresa (cif) );



CREATE TABLE if NOT EXISTS equipamientoElectromedico (
codigoProducto VARCHAR(4) PRIMARY KEY UNIQUE,
-- CONSTRAINT restriccionCodigoP CHECK (codigoProducto),
pesoEnKg INT NOT null,
nombreEquipo VARCHAR(20),
fechaFinVidaUtil DATE NOT null, 
periodicidadDias INT NOT null,
precio DECIMAL(8,2) NOT null,
fechaAdquisicion DATE NOT null,
dni VARCHAR(9) ,
FOREIGN KEY (dni) REFERENCES ingenieroBiomedico (dni) );

-- Rgela de negocio: el estado de las revisiones tiene que ir entre 0 y 10.

CREATE TABLE if NOT EXISTS revision (
oid_r INT AUTO_INCREMENT PRIMARY KEY,
estado DECIMAL(3,1),
CONSTRAINT calificacionEstado CHECK (estado<=10 AND estado>=0),
fechaRevision DATE DEFAULT NOW(),
fechaProximaRevision DATE,
CONSTRAINT fechasConSentido1 CHECK (fechaProximaRevision>=fechaRevision),
codigoProducto VARCHAR(20) ,
fechaNormativaElectricidad INT,
fechaNormativaClimatizacion INT,
FOREIGN KEY (codigoProducto) REFERENCES equipamientoElectromedico (codigoProducto),
FOREIGN KEY (fechaNormativaElectricidad) REFERENCES normativaElectricidad (fechaNormativaElectricidad),
FOREIGN KEY (fechaNormativaClimatizacion) REFERENCES normativaClimatizacion (fechaNormativaClimatizacion) );

#PODRIA CREAR TRES TABLAS QUE HEREDEN DE REVISION, UNA POR CADA EQUIPO PARA ELIMINAR NULOS.


CREATE TABLE if NOT EXISTS Mediciones (
oid_M INT AUTO_INCREMENT PRIMARY KEY,
oid_r INT,
luz INT,
temperaturas INT,
voltaje INT,
presionGas INT,
mensajeEvaluacion VARCHAR(50),
FOREIGN KEY (oid_r) REFERENCES revision (oid_r) );



CREATE TABLE if NOT EXISTS columnaquirurgica (
oid_c INT AUTO_INCREMENT UNIQUE,
voltiosMaximos INT,
voltiosMinimos INT,
gradosMaximos INT,
gradosMinimos INT,
alturaMetros INT,
codigoProducto VARCHAR(20),
FOREIGN KEY (codigoProducto) REFERENCES equipamientoElectromedico (codigoProducto),
CONSTRAINT intervalosConSentido3 CHECK 
(voltiosMaximos>voltiosMinimos AND gradosMaximos>gradosMinimos) );


CREATE TABLE if NOT EXISTS lampara (
oid_l INT AUTO_INCREMENT UNIQUE,
valorLuxMaximo INT,
valorLuxMinimo INT,
gradosMaximos INT,
gradosMinimos INT,
numeroLeds INT,
codigoProducto VARCHAR(20),
FOREIGN KEY (codigoProducto) REFERENCES equipamientoElectromedico (codigoProducto), 
CONSTRAINT intervalosConSentido4 CHECK 
(valorLuxMaximo>valorLuxMinimo AND gradosMaximos>gradosMinimos));


CREATE TABLE if NOT EXISTS paneltecnico (
oid_p INT AUTO_INCREMENT UNIQUE,
valorLuxMaximo INT,
valorLuxMinimo INT,
presionGasMaximoBar INT,
presionGasMinimoBar INT,
codigoProducto VARCHAR(20),
FOREIGN KEY (codigoProducto) REFERENCES equipamientoElectromedico (codigoProducto),
CONSTRAINT intervalosConSentido5 CHECK 
(valorLuxMaximo>valorLuxMinimo AND presionGasMaximoBar>presionGasMinimoBar) );


CREATE TABLE if NOT EXISTS revisionauxiliar (
codigoProducto VARCHAR(20),
estado DECIMAL (3,1),
CONSTRAINT calificacionEstado CHECK (estado<=10 AND estado>=0),
fechaRevision DATE DEFAULT NOW(),
fechaSiguienteRevision DATE,
motivo VARCHAR(200),
CONSTRAINT fechaConSentido CHECK (fechaSiguienteRevision>=fechaRevision));

-- INSERT

-- INSERT

INSERT INTO empresa(cif, nombreEmpresa, direccionWeb, pais, direccion, telefono) 
VALUES ('A28063485', 'Dräger', 'www.dräger.com', 'Alemania','Revalstrabe', 902116424),
('A04818239', 'Carburos Medica', 'www.carburosmedica.com', 'España',
'C. de la Red Tres 1', 932902600),
('A08993735', 'Novaclinic', 'www.novaclinic.com', 'España',
'Avda de la innovación, s/n Edificio Arena 3-Bajo', 900116424),
('A28006377', 'Siemens', 'www.siemens.com', 'Alemania',
 'Nonnendammallee 104', 915148000);

INSERT INTO normativaElectricidad(nivelLuxMaxima, nivelLuxMinima, fechaNormativaElectricidad, 
periodicidadRevisionDias)
VALUES (2700, 1000, 2016, 14),
(2700, 1000, 2017, 7),
(2700, 1000, 2018, 14);

INSERT INTO normativaClimatizacion(caudalAireMinimo, caudalAireMaximo, gradosMaximos, gradosMinimos, porcentajeHumedadMinimo,
PorcentajeHumedadMaximo, fechaNormativaClimatizacion, periodicidadRevisionDias)
VALUES (2700, 3500, 23, 19, 48, 50, 2012, 20),
(2830, 4000, 24, 19, 47, 50, 2013, 22),
(2830, 3980, 23, 19, 48, 56, 2014, 25);

INSERT INTO IngenieroBiomedico(dni, numeroSeguridadSocial, nombre, apellidos, titulacion, fechaNacimiento,
codigoPostal, telefono, correoElectronico, cif) 
VALUES ('32536784Z', '746283492837', 'Maria José', 'Navarrete Inglés', 'Ingeniería Médica', '1990-02-22',
41928, 672687946, 'maríanavaing@gmail.es', 'A28063485'),
('60245603V', '432873912391', 'Pedro', 'Ramírez Jímenez', 'Ingeniería de la Salud', '1992-05-8', 41015, 645957442,
'pedro_ramirez@gmail.com', 'A04818239'),
('45678314C', '837462938413', 'Miguel', 'Torres Monge', 'Ingeniería de la Salud', '1994-1-15', 41089, 655344785,
'miguelitotorres23@gmail.com', 'A08993735'),
('56734268Y', '384754857384', 'Pepe', 'Manzano Olivo', 'Ingeniería Médica', '1992-09-26',
41920, 672687946, 'pipon@gmail.com', 'A28006377'),
('82746372J', '782468857287', 'Rosa', 'Melinda Giménez', 'Ingeniería Médica', '1991-05-2',
41929, 672836152, 'rositameli91@gmail.com', 'A08993735');

INSERT INTO equipamientoElectromedico(codigoProducto, pesoEnKg, nombreEquipo, fechaFinVidaUtil,
periodicidadDias, precio, fechaAdquisicion, dni)
VALUES 
('L089', 130, 'Lámpara', '2024-11-13', 60, 
4370, '2011-5-13', '60245603V'),
('L090', 120, 'Lámpara', '2029-2-11', 60, 
5000, '2021-10-29', '45678314C'),
('C127',1300, 'Columna Quirúrgica', '2025-11-12', 20,
19000.0, '2012-5-12', '32536784Z'),
('C128',1200, 'Columna Quirúrgica', '2028-1-8', 20,
17500.0, '2021-10-9', '56734268Y'),
('P100', 290, 'Panel Técnico', '2021-12-3', 90, 
335000, '2012-7-15','32536784Z'),
('P101', 318, 'Panel Técnico', '2022-6-23', 90, 
320000, '2021-9-28','82746372J');




INSERT INTO revision(oid_r, estado,  fechaRevision, fechaProximaRevision, codigoProducto,
fechaNormativaElectricidad, fechaNormativaClimatizacion)
VALUES 
(1, 9.6, '2021-1-1', '2021-1-14', NULL, 2018, NULL),
(2, 5.6, '2021-1-2', '2021-3-31','P100', NULL, NULL),
(3, 9.3, '2021-1-4', '2021-1-29', NULL, NULL, 2014),
(4, 9.7, '2021-1-14', '2021-1-28', NULL, 2018, NULL),
(5, 6.5, '2021-1-16', '2021-2-5','C127', NULL, NULL),
(6, 9.8, '2021-1-28', '2021-2-11', NULL, 2018, NULL),
(7, 9.5, '2021-1-29', '2021-2-23', NULL, NULL, 2014),
(8, 6.3, '2021-2-5', '2021-2-25','C127', NULL, NULL),
(9, 9.8, '2021-2-11', '2021-2-25', NULL, 2018, NULL),
(10, 5.4, '2021-2-12', '2021-4-13','L089', NULL, NULL),
(11, 9.2, '2021-2-23', '2021-3-20', NULL, NULL, 2014),
(12, 6.3, '2021-2-25', '2021-3-17','C127', NULL, NULL),
(13, 9.5, '2021-2-25', '2021-3-12', NULL, 2018, NULL),
(14, 9.4, '2021-3-12', '2021-3-26', NULL, 2018, NULL),
(15, 6.1, '2021-3-17', '2021-4-8','C127', NULL, NULL),
(16, 9.4, '2021-3-20', '2021-4-14', NULL, NULL, 2014),
(17, 9.6, '2021-3-26', '2021-4-9', NULL, 2018, NULL),
(18, 5.3, '2021-3-31', '2021-6-30','P100', NULL, NULL),
(19, 6, '2021-4-8', '2021-4-28','C127', NULL, NULL),
(20, 9.7, '2021-4-9', '2021-4-23', NULL, 2018, NULL),
(21, 6.2, '2021-4-13', DATE_ADD(fechaRevision,INTERVAL 60 DAY),'L089', NULL, NULL),
(22, 8.7, '2021-4-14', '2021-5-9', NULL, NULL, 2014),
(23, 9, '2021-4-23', '2021-5-7', NULL, 2018, NULL),
(24, 5.8, '2021-4-28', '2021-5-18','C127', NULL, NULL),
(25, 9.2, '2021-5-7', '2021-5-21', NULL, 2018, NULL),
(26, 8.9, '2021-5-9', '2021-6-3', NULL, NULL, 2014),
(27, 5.6, '2021-5-18', '2021-6-7','C127', NULL, NULL),
(28, 9.1, '2021-5-21', '2021-6-4', NULL, 2018, NULL),
(29, 8.8, '2021-6-3', '2021-6-28', NULL, NULL, 2014),
(30, 9.5, '2021-6-4', '2021-6-18', NULL, 2018, NULL),
(31, 5.8, '2021-6-7', '2021-6-27','C127', NULL, NULL),
(32, 6, '2021-6-12', '2021-8-11','L089', NULL, NULL),
(33, 9.4, '2021-6-18', '2021-7-2', NULL, 2018, NULL),
(34, 5.6, '2021-6-27', '2021-7-17','C127', NULL, NULL),
(35, 8.7, '2021-6-28', '2021-7-23', NULL, NULL, 2014),
(36, 5.3, '2021-6-30', '2021-9-28','P100', NULL, NULL),
(37, 9.1, '2021-7-2', '2021-7-16', NULL, 2018, NULL),
(38, 8.9, '2021-7-16', '2021-7-30', NULL, 2018, NULL),
(39, 5, '2021-7-17', '2021-8-6','C127', NULL, NULL),
(40, 8.9, '2021-7-23', '2021-8-17', NULL, NULL, 2014),
(41, 9, '2021-7-30', '2021-8-14', NULL, 2018, NULL),
(42, 5.2, '2021-8-10', '2021-8-30','C127', NULL, NULL),
(43, 5.4, '2021-8-11', '2021-10-10','L089', NULL, NULL),
(44, 9.2, '2021-8-14', '2021-8-28', NULL, 2018, NULL),
(45, 8.7, '2021-8-17', '2021-9-11', NULL, NULL, 2014),
(46, 8.8, '2021-8-28', '2021-9-11', NULL, 2018, NULL),
(47, 5.4, '2021-8-30', '2021-9-19','C127', NULL, NULL),
(48, 8.6, '2021-9-11', '2021-9-25', NULL, 2018, NULL),
(49, 8.7, '2021-9-11', '2021-10-6', NULL, NULL, 2014),
(50, 5, '2021-9-19', '2021-10-9','C127', NULL, NULL),
(51, 9.3, '2021-9-25', '2021-10-9', NULL, 2018, NULL),
(52, 9.5, '2021-9-28', '2021-12-27','P101', NULL, NULL),
(53, 8.8, '2021-10-6', '2021-10-31', NULL, NULL, 2014),
(54, 8.9, '2021-10-9', '2021-10-23', NULL, 2018, NULL),
(55, 9.9, '2021-10-10', '2021-12-9','L090', NULL, NULL),
(56, 9, '2021-10-23', '2021-11-4', NULL, 2018, NULL),
(57, 9.8, '2021-10-12', '2021-10-30','C128', NULL, NULL),
(58, 9.5, '2021-10-30', '2021-11-19','C128', NULL, NULL),
(59, 9.2, '2021-10-31', '2021-11-25', NULL, NULL, 2014),
(60, 9.1, '2021-11-4', '2021-11-18', NULL, 2018, NULL),
(61, 9, '2021-11-25', '2021-12-20', NULL, NULL, 2014),
(62, 8.4, '2021-11-18', '2021-12-2', NULL, 2018, NULL),
(63, 9.4, '2021-11-19', '2021-12-9','C128', NULL, NULL),
(64, 9, '2021-12-2', '2021-12-16', NULL, 2018, NULL),
(65, 9.4, '2021-12-9', '2021-12-29','C128', NULL, NULL),
(66, 9.9, '2021-12-9', '2022-2-7','L090', NULL, NULL),
(67, 8.5, '2021-12-16', '2021-12-30', NULL, 2018, NULL),
(68, 9.1, '2021-12-20', '2022-1-14', NULL, NULL, 2014),
(69, 9.4, '2021-12-27', '2022-2-28','P101', NULL, NULL),
(70, 9.4, '2021-12-29', '2022-1-18','C128', NULL, NULL),
(71, 8.4, '2021-12-30', '2022-1-13', NULL, 2018, NULL);


INSERT INTO columnaQuirurgica(codigoProducto,
voltiosMinimos, voltiosMaximos,
gradosMinimos, gradosMaximos,alturaMetros)
VALUES ('C127',20, 60, -5, 50, 2.2),
('C128',22, 75, -10, 58, 1.2);


INSERT INTO lampara(valorLuxMaximo, valorLuxMinimo, gradosMaximos, gradosMinimos, numeroLeds, codigoProducto) 
VALUES (1200.00, 400.00, 55, 5, 48, 'L089'),
(1600.00, 400.00, 60, 10, 14, 'L090');


INSERT INTO panelTecnico(valorLuxMaximo, valorLuxMinimo, presionGasMaximoBar, presionGasMinimoBar, codigoProducto) 
VALUES(7000, 1000, 10, 5, 'P100'),
(5000, 1000, 10, 5, 'P101');



INSERT INTO revisionauxiliar(codigoProducto, estado, FechaRevision, fechaSiguienteRevision, motivo)
VALUES ('C127', 4 , '2021-10-9', '2021-10-29', 'Alto desgaste del equipo debido al uso' ),
('L089', 3.5 , '2021-10-10', '2021-12-9', 'Alto desgaste del equipo debido al uso' ),
('P100', 4.2 , '2021-9-28', '2021-12-27', 'Alto desgaste del equipo debido al uso' );


