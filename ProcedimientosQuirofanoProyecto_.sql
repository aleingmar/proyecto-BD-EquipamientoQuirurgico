

/*
-- no se usan deberian borrarse

CREATE OR REPLACE VIEW paraRevisionDefectuosa3 AS 
SELECT row_number() OVER (ORDER BY r.fechaRevision desc) orden, r.estado, r.codigoProducto FROM revision r ;

SELECT row_number() OVER (ORDER BY codigoProducto,r.fechaRevision DESC) orden, r.fechaRevision, r.codigoProducto FROM revision r;

*/

-- ººººººººººººººººººººº  PROCEDIMIENTOS

-- PROCEDIMIENTO PARA INSERTAR REVISIONES: y que se calculen automaticamente la fecha de la proxima revision,
-- en función del equipo al que se le lleve a cabo la revisión, y su periodicidad de revision. 

DELIMITER //
CREATE OR REPLACE PROCEDURE

insertaRevision (
estado DECIMAL(3,1),
fechaRevision DATE,
codigoProducto VARCHAR(20) ,
fechaNormativaElectricidad INT,
fechaNormativaClimatizacion INT)

BEGIN

if (codigoProducto IS NOT NULL) then 
	SET fechaNormativaElectricidad= NULL;
	SET fechaNormativaClimatizacion= NULL;
END if;


INSERT INTO revision (estado,
fechaRevision,
fechaProximaRevision,
codigoProducto  ,
fechaNormativaElectricidad,
fechaNormativaClimatizacion) 

VALUES (estado, fechaRevision, 
DATE_ADD(fechaRevision, INTERVAL (SELECT e.periodicidadDias from  equipamientoelectromedico e 
WHERE codigoProducto= e.codigoProducto) DAY), 
codigoProducto , fechaNormativaElectricidad,
fechaNormativaClimatizacion); #aqui se ponen los parametros

END //
DELIMITER ;

-- PROCEDIMIENTO PARA INSERTAR EQUIPAMIENTO ELECTROMEDICO

DELIMITER //
CREATE OR REPLACE PROCEDURE
insertaEquipamientoElectromedico (codigoProducto VARCHAR(4),
pesoEnKg INT,
nombreEquipo VARCHAR(20),
fechaFinVidaUtil DATE, 
periodicidadDias INT,
precio DECIMAL(8,2),
fechaAdquisicion DATE,
dni VARCHAR(9))
BEGIN
INSERT INTO equipamientoelectromedico (codigoProducto,
pesoEnKg,
nombreEquipo,
fechaFinVidaUtil, 
periodicidadDias,
precio,
fechaAdquisicion,
dni)
VALUES (codigoProducto, pesoEnKg, nombreEquipo, fechaFinVidaUtil, 
periodicidadDias, precio, fechaAdquisicion,dni); #aqui se ponen los parametros
END //
DELIMITER ;

-- PROCEDIMIENTO PARA INSERTAR INGENIERO BIOMEDICO

DELIMITER //
CREATE OR REPLACE PROCEDURE
insertaIngenieroBiomedico (dni VARCHAR(9),
numeroSeguridadSocial VARCHAR(15),
nombre VARCHAR(50),
apellidos VARCHAR(50),
titulacion VARCHAR(30),
fechaNacimiento DATE,
codigoPostal VARCHAR(5),
telefono VARCHAR(14),
correoElectronico VARCHAR(60),
cif VARCHAR(9))
BEGIN
INSERT INTO ingenierobiomedico (dni,
numeroSeguridadSocial,
nombre,
apellidos,
titulacion,
fechaNacimiento,
codigoPostal,
telefono,
correoElectronico,
cif)
VALUES (dni, numeroSeguridadSocial, nombre, apellidos, titulacion,
 fechaNacimiento, codigoPostal, telefono, correoElectronico, cif);#aqui se ponen los parametros
END //
DELIMITER ;

-- PROCEDIMIENTO PARA INSERTAR EMPRESA

DELIMITER //
CREATE OR REPLACE PROCEDURE
insertaEmpresa (cif VARCHAR(10),
nombreEmpresa VARCHAR(20),
direccionWeb VARCHAR(50),
pais VARCHAR(20),
direccion VARCHAR(100),
telefono VARCHAR(14))
BEGIN
INSERT INTO empresa (cif,
nombreEmpresa,
direccionWeb,
pais,
direccion,
telefono)
VALUES (cif, nombreEmpresa, direccionWeb, pais, direccion, telefono);#aqui se ponen los parametros
END //
DELIMITER ;

-- PROCEDIMIENTO PARA INSERTAR REVISION AUXILIAR

DELIMITER //
CREATE OR REPLACE PROCEDURE
insertaRevisionAuxiliar (
codigoProducto VARCHAR(20),
estado VARCHAR(50),
fechaRevision DATE,
motivo VARCHAR(200)
)

BEGIN
INSERT INTO revisionauxiliar (
codigoProducto,
estado,
fechaRevision,
fechaSiguienteRevision, 
motivo)


VALUES (codigoProducto, estado, fechaRevision, 
DATE_ADD(fechaRevision, INTERVAL (SELECT e.periodicidadDias from  equipamientoelectromedico e 
WHERE codigoProducto= e.codigoProducto) DAY), 
motivo);
END //
DELIMITER ;


-- PROCEDIMIENTO QUE REBAJE UN 60% A LOS EQUIPAMIENTOS ELECTROMEDICOS QUE LE QUEDE 
-- un año o  menos de un año para acabar su vida util
-- PARA SU POSTERIOR VENTA a instituciones acaddémicas

DELIMITER //
    CREATE OR REPLACE PROCEDURE
    rebajaPrecioFinVida()
BEGIN
    UPDATE equipamientoelectromedico
    SET precio = precio*0.4
	 WHERE DATE_ADD(NOW(), INTERVAL 365 DAY) >= fechaFinVidaUtil ;
		
		
    END //
DELIMITER ;



-- PROCEDIMIENTO QUE atrasa la fecha de la proxima revision en 5 dias (solo del equipamiento actual)

DELIMITER //
CREATE OR REPLACE PROCEDURE
    aumentarFechaProximaRevision()
BEGIN
    UPDATE revision r, proxrevequipactuales a1
    SET  r.fechaProximaRevision= DATE_ADD(r.fechaProximaRevision, INTERVAL 5 DAY)
    WHERE a1.proximaRevision= r.fechaProximaRevision AND a1.codigoProducto = r.codigoProducto;
    
    END //
DELIMITER;


-- PROCEDIMEINTO QUE CAMBIE los parámetros minimos de la última normativaClimatizacion en un 15%

DELIMITER //
CREATE OR REPLACE PROCEDURE
    cambioPorcentajeNormativaClima()
BEGIN
    UPDATE normativaclimatizacion n
    SET  n.caudalAireMinimo= n.caudalAireMinimo*1.15
	 WHERE n.fechaNormativaClimatizacion>= (SELECT MAX(fechaNormativaClimatizacion) FROM normativaclimatizacion);
	 UPDATE normativaclimatizacion n
    SET n.gradosMinimos= n.gradosMinimos*1.15
	 WHERE n.fechaNormativaClimatizacion>= (SELECT MAX(fechaNormativaClimatizacion) FROM normativaclimatizacion);
	 UPDATE normativaclimatizacion n
    SET n.porcentajeHumedadMinimo= n.porcentajeHumedadMinimo*1.15
    WHERE n.fechaNormativaClimatizacion>= (SELECT MAX(fechaNormativaClimatizacion) FROM normativaclimatizacion);
    END //
DELIMITER;

-- PROCEDIMEINTO QUE acota el intervalo de valor de luz de laas normativas de electricidad

DELIMITER //
CREATE OR REPLACE PROCEDURE
    cambioIntervaloNormativaElectricidad()
BEGIN
    UPDATE normativaelectricidad n
    SET  n.nivelLuxMinima= n.nivelLuxMinima*1.05
	 WHERE n.fechaNormativaElectricidad>= (SELECT MAX(ne.fechaNormativaElectricidad) FROM normativaelectricidad ne);
	 
	 UPDATE normativaelectricidad n
    SET  n.nivelLuxMaxima= n.nivelLuxMaxima*0.95
	 WHERE n.fechaNormativaElectricidad>= (SELECT MAX(ne.fechaNormativaElectricidad) FROM normativaelectricidad ne);
	 
	 
    END //
DELIMITER;

-- Procedimiento que aumente la periodicidad (disminuye los dios entre revisiones) de revisiones de las normativas de clima y electricidad en un 10%

DELIMITER //
CREATE OR REPLACE PROCEDURE
    cambioPeriodicidadNormativas()
BEGIN
    UPDATE normativaclimatizacion n
    SET  n.periodicidadRevisionDias= n.periodicidadRevisionDias*0.9
	 WHERE n.fechaNormativaClimatizacion>= (SELECT MAX(fechaNormativaClimatizacion) FROM normativaclimatizacion);
	 
	 UPDATE normativaelectricidad ne
    SET ne.periodicidadRevisionDias= ne.periodicidadRevisionDias*0.9
	 WHERE ne.fechaNormativaElectricidad>= (SELECT MAX(ne.fechaNormativaElectricidad) FROM normativaelectricidad ne);
	 
    END //
DELIMITER;

#////////////////////////////////////////////////////////////////////////////////////////////////////////



-- ººººººººººººººººººººººººººº    FUNCIONESS

#Devuelveme la nota de la peor revision de un determinado equipamiento electromedico

DELIMITER //
CREATE OR REPLACE FUNCTION 
	estadoPeorEquipo(codigoP VARCHAR(20)) RETURNS DECIMAL(3,1)
BEGIN


DECLARE res DECIMAL (3,1) DEFAULT (SELECT MIN(r.estado) FROM revision r where r.codigoProducto= codigoP);
DECLARE res2 DECIMAL (3,1) DEFAULT (select MIN(ra.estado)  from revisionauxiliar ra where ra.codigoProducto=codigoP);

if (res > res2)
then
RETURN res2 ;
END if;

RETURN res;

END //
DELIMITER ;




#Cantidad de revisiones de un ingeniero por debajo del 6(el estado)

DELIMITER //
CREATE OR REPLACE FUNCTION 
    numRevisionesMenor5(DNI VARCHAR(9)) RETURNS INT
BEGIN
DECLARE res INT;
DECLARE res2 int;
SET res=  (SELECT COUNT(*) FROM  revision r NATURAL JOIN equipamientoelectromedico e WHERE e.dni= DNI AND r.estado<6 GROUP BY e.dni);
SET res2=  (SELECT COUNT(*) FROM  revisionauxiliar ra, equipamientoelectromedico e WHERE  ra.codigoProducto= e.codigoProducto and e.dni= DNI AND ra.estado<6 GROUP BY e.dni);
RETURN res + res2;
END //
DELIMITER ;

#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Lamparas).

DELIMITER //

CREATE OR REPLACE FUNCTION 
	evaluacionLampara(codigoP VARCHAR(20), valorLuz INT, valorTemperatura INT) RETURNS VARCHAR (1000)
BEGIN
DECLARE res VARCHAR(1000) DEFAULT 'El resultado de la medición es: ';
DECLARE p1 VARCHAR(50) DEFAULT 'Falla la medición de la luz';
DECLARE p2 VARCHAR(50) DEFAULT 'Falla la medición de la temperatura';
DECLARE p3 VARCHAR(50) DEFAULT 'La medición es correcta';
DECLARE c1 BOOLEAN DEFAULT true ;
DECLARE c2 BOOLEAN DEFAULT true;

if (valorLuz < (SELECT valorLuxMinimo from equipamientoelectromedico NATURAL JOIN lampara  WHERE codigoP= codigoProducto) OR 
valorLuz > (SELECT valorLuxMaximo from equipamientoelectromedico NATURAL JOIN lampara WHERE codigoP= codigoProducto )) 
then 
SET res= CONCAT(res, p1, ';') ;
SET c1= false;
END if;

IF ( valorTemperatura < (SELECT gradosMinimos from equipamientoelectromedico NATURAL JOIN lampara WHERE codigoP= codigoProducto) OR 
valorTemperatura > (SELECT gradosMaximos from equipamientoelectromedico NATURAL JOIN lampara WHERE codigoP= codigoProducto )  ) 
then 
SET res= CONCAT(res, p2, ';') ;
SET c2= false;
END if;


if(c1 and c2)
then
set res= CONCAT(res, p3, ';') ;
END if;

RETURN res;
END //
DELIMITER ;


#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Columnas Quirúrgicas).

DELIMITER //

CREATE OR REPLACE FUNCTION 
	evaluacionColumna(codigoP VARCHAR(20), valorVoltaje INT, valorTemperatura INT) RETURNS VARCHAR (1000)
BEGIN
DECLARE res VARCHAR(1000) DEFAULT 'El resultado de la medición es: ';
DECLARE p1 VARCHAR(50) DEFAULT 'Falla la medición del voltaje';
DECLARE p2 VARCHAR(50) DEFAULT 'Falla la medición de la temperatura';
DECLARE p3 VARCHAR(50) DEFAULT 'La medición es correcta';
DECLARE c1 BOOLEAN DEFAULT true ;
DECLARE c2 BOOLEAN DEFAULT true;

if (valorVoltaje < (SELECT voltiosMinimos from equipamientoelectromedico NATURAL JOIN columnaquirurgica  WHERE codigoP= codigoProducto) OR 
valorVoltaje > (SELECT voltiosMaximos from equipamientoelectromedico NATURAL JOIN columnaquirurgica WHERE codigoP= codigoProducto )) 
then 
SET res= CONCAT(res, p1, ';') ;
SET c1= false;
END if;

IF ( valorTemperatura < (SELECT gradosMinimos from equipamientoelectromedico NATURAL JOIN columnaquirurgica WHERE codigoP= codigoProducto) OR 
valorTemperatura > (SELECT gradosMaximos from equipamientoelectromedico NATURAL JOIN columnaquirurgica WHERE codigoP= codigoProducto )  ) 
then 
SET res= CONCAT(res, p2, ';') ;
SET c2= false;
END if;

if(c1 and c2)
then
set res= CONCAT(res, p3, ';') ;
END if;

RETURN res;
END //
DELIMITER ;

#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Paneles).

DELIMITER //

CREATE OR REPLACE FUNCTION 
	evaluacionPanel(codigoP VARCHAR(20), valorLuz INT, valorPresion INT) RETURNS VARCHAR (1000)
BEGIN
DECLARE res VARCHAR(1000) DEFAULT 'El resultado de la medición es: ';
DECLARE p1 VARCHAR(50) DEFAULT 'Falla la medición de la luz';
DECLARE p2 VARCHAR(50) DEFAULT 'Falla la medición de la presión del gas';
DECLARE p3 VARCHAR(50) DEFAULT 'La medición es correcta';
DECLARE c1 BOOLEAN DEFAULT true ;
DECLARE c2 BOOLEAN DEFAULT true;

if (valorLuz < (SELECT valorLuxMinimo from equipamientoelectromedico NATURAL JOIN paneltecnico  WHERE codigoP= codigoProducto) OR 
valorluz > (SELECT valorLuxMaximo from equipamientoelectromedico NATURAL JOIN paneltecnico WHERE codigoP= codigoProducto )) 
then 
SET res= CONCAT(res, p1, ';') ;
SET c1= false;
END if;

IF ( valorPresion < (SELECT presionGasMinimoBar from equipamientoelectromedico NATURAL JOIN paneltecnico WHERE codigoP= codigoProducto) OR 
valorPresion > (SELECT presionGasMaximoBar from equipamientoelectromedico NATURAL JOIN paneltecnico WHERE codigoP= codigoProducto )  ) 
then 
SET res= CONCAT(res, p2, ';') ;
SET c2= false;
END if;

if(c1 and c2)
then
set res= CONCAT(res, p3, ';') ;
END if;

RETURN res;
END //
DELIMITER ;


#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Segun la normativa actual de la Electricidad).

DELIMITER //

CREATE OR REPLACE FUNCTION 
	evaluacionElectricidad(valorLuz INT) RETURNS VARCHAR (1000)
BEGIN
DECLARE res VARCHAR(1000) DEFAULT 'El resultado de la medición es: ';
DECLARE p1 VARCHAR(50) DEFAULT 'Falla la medición de la luz';
DECLARE p2 VARCHAR(50) DEFAULT 'La medición es correcta';
DECLARE c1 BOOLEAN DEFAULT true ;

if (valorLuz < (SELECT nivelLuxMinima 
from normativaelectricidad n
WHERE n.fechaNormativaElectricidad=(SELECT MAX(ne.fechaNormativaElectricidad) FROM normativaelectricidad ne)) OR 
valorLuz > (SELECT nivelLuxMaxima 
from normativaelectricidad 
WHERE fechaNormativaElectricidad=(SELECT MAX(ne.fechaNormativaElectricidad) FROM normativaelectricidad ne)))
then 
SET res= CONCAT(res, p1, ';') ;
SET c1= false;
END if;

if(c1)
then
set res= CONCAT(res, p2, ';') ;
END if;

RETURN res;
END //
DELIMITER ;


#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Segun la normativa actual de la Climatizacion).

DELIMITER //

CREATE OR REPLACE FUNCTION 
	evaluacionClimatizacion(valorCaudalAire INT, valorGrados INT, valorHumedad INT) RETURNS VARCHAR (1000)
BEGIN
DECLARE res VARCHAR(1000) DEFAULT 'El resultado de la medición es: ';
DECLARE p1 VARCHAR(50) DEFAULT 'Falla la medición del caudal del aire';
DECLARE p2 VARCHAR(50) DEFAULT 'Falla la medición de la temperatura';
DECLARE p3 VARCHAR(50) DEFAULT 'Falla la medición del porcentaje humedad';
DECLARE p4 VARCHAR(50) DEFAULT 'La medición es correcta';
DECLARE c1 BOOLEAN DEFAULT true;
DECLARE c2 BOOLEAN DEFAULT TRUE;
DECLARE c3 BOOLEAN DEFAULT true;

if (valorCaudalAire < (SELECT caudalAireMinimo from normativaclimatizacion 
WHERE fechaNormativaClimatizacion=(SELECT MAX(nc.fechaNormativaClimatizacion) FROM normativaclimatizacion nc)) OR 
valorCaudalAire > (SELECT caudalAireMaximo from normativaclimatizacion 
WHERE fechaNormativaClimatizacion=(SELECT MAX(nc.fechaNormativaClimatizacion) FROM normativaclimatizacion nc))) 
then 
SET res= CONCAT(res, p1, ';');
SET c1= false;
END if;

IF ( valorGrados < (SELECT gradosMinimos from normativaclimatizacion
WHERE fechaNormativaClimatizacion=(SELECT MAX(nc.fechaNormativaClimatizacion) FROM normativaclimatizacion nc)) OR 
valorGrados > (SELECT gradosMaximos from normativaclimatizacion
WHERE fechaNormativaClimatizacion=(SELECT MAX(nc.fechaNormativaClimatizacion) FROM normativaclimatizacion nc))) 
then 
SET res= CONCAT(res, p2, ';') ;
SET c2= false;
END if;

if (valorHumedad < (SELECT porcentajeHumedadMinimo from normativaclimatizacion
WHERE fechaNormativaClimatizacion=(SELECT MAX(nc.fechaNormativaClimatizacion) FROM normativaclimatizacion nc)) OR 
valorHumedad > (SELECT porcentajeHumedadMaximo from normativaclimatizacion
WHERE fechaNormativaClimatizacion=(SELECT MAX(nc.fechaNormativaClimatizacion) FROM normativaclimatizacion nc))) 
then 
SET res= CONCAT(res, p3, ';') ;
SET c3= false;
END if;

if(c1 and c2 AND c3)
then
set res= CONCAT(res, p4, ';') ;
END if;

RETURN res;
END //
DELIMITER ;


-- Función que dado el código de un producto te devuelva la fecha de la próxima revisión

DELIMITER //
CREATE OR REPLACE FUNCTION revProx (cProducto VARCHAR(4))
RETURNs DATE
BEGIN

RETURN (SELECT max(fechaProximaRevision)
FROM revision r
WHERE r.codigoProducto= cProducto);
END //
DELIMITER ;

-- Función que dado el nombre de una empresa devuelva el dinero invertido

DELIMITER //
CREATE OR REPLACE FUNCTION DineroInvEmpr (nEmp VARCHAR(20))
RETURNS DECIMAL(10,2)
BEGIN
RETURN (SELECT SUM(precio) 
		FROM equipamientoelectromedico eq, ingenierobiomedico ing , empresa em 
		WHERE eq.dni= ing.dni AND ing.cif= em.cif AND nEmp= em.nombreEmpresa);
END //
DELIMITER ;

-- Funcion que dado el dni de un ingeniero devuelva el nombre de la empresa a la que pertenece

DELIMITER //
CREATE OR REPLACE FUNCTION EmpresaALaQuePertenece (DNIingeniero VARCHAR(9))
RETURNS VARCHAR(20)
BEGIN
RETURN (SELECT nombreEmpresa
	FROM ingenierobiomedico i, empresa e
	WHERE i.cif= e.cif AND DNIingeniero=i.dni);
END //
DELIMITER ;


-- Nos devuelve dada una fecha el coste del quirófano en esa fecha

DELIMITER //
CREATE OR REPLACE FUNCTION PrecioEnFecha (fecha date)
RETURNS DECIMAL(12,2)
BEGIN
if(fecha<(SELECT MIN(fechaAdquisicion) FROM equipamientoelectromedico))
then
RETURN 0.00; 
END if;

RETURN (SELECT SUM(precio) FROM equipamientoelectromedico WHERE codigoProducto in
(
SELECT codigoProducto FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'L%' AND 
fechaAdquisicion = (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'L%'  AND ee.fechaAdquisicion<=fecha)

UNION
SELECT codigoProducto FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'P%' AND 
fechaAdquisicion= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'P%' AND ee.fechaAdquisicion<=fecha)
UNION
SELECT codigoProducto FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'C%' AND 
fechaAdquisicion= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'C%' AND ee.fechaAdquisicion<=fecha)));

END //
DELIMITER ;

-- Nos devuelve la diferencia de coste entre el quirófano actualmente y el coste del quirófano en esa fecha

DELIMITER //
CREATE OR REPLACE FUNCTION DiferenciaCoste (fecha date)
RETURNS DECIMAL(12,2)
BEGIN
RETURN   (SELECT SUM(precio) FROM equipoactual2) -  PrecioEnFecha(fecha);


END //
DELIMITER ;

-- Calcula el año de la normativa más exigente 

DELIMITER //
CREATE OR REPLACE FUNCTION NormativaMasExigente ()
RETURNS int
BEGIN
RETURN  
(SELECT nn.fechaNormativaClimatizacion FROM normativaclimatizacion nn 
WHERE  ((nn.caudalAireMaximo- nn.caudalAireMinimo)
+( nn.gradosMaximos - nn.gradosMinimos ) +( nn.porcentajeHumedadMaximo - nn.porcentajeHumedadMinimo)) = 
(SELECT  MIN((n.caudalAireMaximo- n.caudalAireMinimo)
+( n.gradosMaximos - n.gradosMinimos ) +( n.porcentajeHumedadMaximo - n.porcentajeHumedadMinimo))
FROM normativaclimatizacion n));

END //
DELIMITER ;




/*
-- Función que dado una fecha me diga el equipo que había en el quirofano en esa fecha.

DELIMITER //
CREATE OR REPLACE FUNCTION EquipoDelMomento (fecha DATE)
RETURNS TABLE AS 
RETURN (
(SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'L%' AND 
fechaAdquisicion = (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'L%'  AND ee.fechaAdquisicion<=fecha)
UNION
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'P%' AND 
fechaAdquisicion= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'P%' AND ee.fechaAdquisicion<=fecha )
UNION
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'C%' AND 
fechaAdquisicion= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'C%' AND ee.fechaAdquisicion<=fecha))

);

DELIMITER ;

*/




#////////////////////////////////////////////////////////////////////////////////////////////////////////


-- ººººººººººººººººººººººººººººººººº      TRIGGERS

#RN-001: La fecha de revision de un equipo no puede cambiar en mas de 5 dias 
#con respecto a la fecha en la que se preveia revisarlo segun su periodicidad


DELIMITER //
CREATE OR REPLACE TRIGGER margenesFechaRevision
before INSERT ON revision
FOR EACH ROW
BEGIN
SET @error_message = 
'Se ha excedido en más de 5 días la fecha en la que se preveía revisar ';


if (datediff(NEW.fechaRevision, (SELECT MAX(r.fechaProximaRevision) FROM revision r 
WHERE NEW.codigoProducto= r.codigoProducto)) > 5 OR datediff((SELECT MAX(r.fechaProximaRevision) FROM revision r 
WHERE NEW.codigoProducto= r.codigoProducto), NEW.fechaRevision ) > 5)  

then

INSERT INTO revisionauxiliar (codigoProducto, estado, FechaRevision, fechaSiguienteRevision, motivo) VALUES
(new.codigoProducto,new.estado,new.fechaRevision, new.fechaProximaRevision, @error_message);

SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END if;

END//

DELIMITER ;


#RN-002. El sistema debe garantizar que los equipos sean repuestos antes de superar su vida útil. 
-- para ello, avisa al hacer una revision del equipo en cuestion 3 meses antes de insertar una revision de estas.

DELIMITER //
CREATE OR REPLACE TRIGGER triggerFinVidaÚtil
before INSERT ON revision
FOR EACH ROW
BEGIN
SET @error_message = 
'Queda menos de tres meses para la fecha asociada a la vida útil del equipo';

if (DATE_ADD(NOW(), INTERVAL (90) DAY) >=
 (SELECT UNIQUE(e.fechaFinVidaUtil) from revision r NATURAL JOIN equipamientoelectromedico e 
 WHERE NEW.codigoProducto = e.codigoProducto)) then


INSERT INTO revisionauxiliar (codigoProducto, estado, FechaRevision, fechaSiguienteRevision, motivo) VALUES
(new.codigoProducto,new.estado,new.fechaRevision, new.fechaProximaRevision, @error_message);

SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;

END if;

END//
DELIMITER ;


#RN-004 El codigo de producto, la primera sigla tienen que coincidir con la primera letra del atributo nombre de ese equipamiento electromedico
DELIMITER //
CREATE OR REPLACE TRIGGER letraCodigoProducto
before INSERT ON equipamientoelectromedico
FOR EACH ROW
BEGIN
SET @error_message = 
'La primera letra del código del producto tiene que coincidir con la sigla de su nombre';

IF  ( SUBSTRING(NEW.codigoProducto, 1, 1)<> SUBSTRING(NEW.nombreEquipo ,1,1) ) 
THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END IF;
END//
DELIMITER ;


#RN-005 Si en una revision la nota cambia 3 puntos frente a la revision anterior del mismo equipo, salta un aviso. 
#Esa revision se guarda en la nueva tabla Revision Auxiliar


DELIMITER //
CREATE OR REPLACE TRIGGER revisisionMuyDefectuosa3
before insert ON revision
FOR EACH ROW
BEGIN
SET @error_message = 
'La revision baja tres puntos frente a la revision anterior';

if (	(SELECT estado FROM revision r WHERE NEW.codigoProducto= r.codigoProducto AND r.fechaRevision >= 
(SELECT MAX(r2.fechaRevision) FROM revision r2 WHERE NEW.codigoProducto= r2.codigoProducto)) - NEW.estado >=3) 
then 


INSERT INTO revisionauxiliar (codigoProducto, estado, FechaRevision, fechaSiguienteRevision, motivo) VALUES
(new.codigoProducto,new.estado,new.fechaRevision, new.fechaProximaRevision, @error_message);

SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message ;
END if;
END//
DELIMITER ;


#RN-006 Cambiar el equipamiento despues de que baje en una revision la calificacion del 3

DELIMITER //
CREATE OR REPLACE TRIGGER revisisionMuyDefectuosa1
before insert ON revision
FOR EACH ROW
BEGIN
SET @error_message = 
'La revision es muy defectuosa, baja del 3';

if (new.estado<=3 ) 
then 

INSERT INTO revisionauxiliar (codigoProducto, estado, FechaRevision, fechaSiguienteRevision, motivo) VALUES
(new.codigoProducto,new.estado,new.fechaRevision, new.fechaProximaRevision, @error_message);
END if;

if (new.estado<=3 ) 
then 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;

END if;

END//
DELIMITER ;


#RN-007 que lleve 3 revisiones seguidas anteriores por debajo del 5.5. (la que meto seria la cuarta)


DELIMITER //
CREATE OR REPLACE FUNCTION cursorAuxiliarTriger(NEWcodigoProducto VARCHAR (4))
RETURNS Boolean
BEGIN
DECLARE contBoolean BOOLEAN DEFAULT true;
DECLARE contInt INT default 0;
DECLARE done BOOLEAN DEFAULT false;
DECLARE revisiones ROW TYPE OF revision;

DECLARE cursorTriger CURSOR FOR 
SELECT * FROM revision r
WHERE NEWcodigoProducto= r.codigoProducto ORDER BY fechaRevision DESC; 

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := TRUE;
OPEN cursorTriger;
readLoop:LOOP
FETCH cursorTriger INTO revisiones;
	IF done OR contInt=3 THEN  # para el bucle cuando o bien se acabe los datos de farmacos o bien la cuenta llegue a 3
		LEAVE readLoop;
		END IF;
	if (revisiones.estado > 5.5) then 
	SET contBoolean = FALSE;
	END if;
	SET contInt = contInt + 1;
END LOOP;
CLOSE cursorTriger;

if((SELECT COUNT(*) FROM revision r WHERE NEWcodigoProducto = r.codigoProducto) < 3)
then 
set contBoolean= FALSE;
END if;

RETURN contBoolean;
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE TRIGGER revisisionMuyDefectuosa2
before insert ON revision
FOR EACH ROW
BEGIN
SET @error_message = 
'Este equipo lleva teniendo 3 revisiones seguidas una nota nota inferior a 5.5 ';

if (NEW.estado<5.5 and  cursorAuxiliarTriger(NEW.codigoProducto)) 
then 

INSERT INTO revisionauxiliar (codigoProducto, estado, FechaRevision, fechaSiguienteRevision, motivo) VALUES
(new.codigoProducto,new.estado,new.fechaRevision, new.fechaProximaRevision, @error_message);

#SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END if;
END//
DELIMITER ;



#RN-008. Todo el equipamiento electro médico que este en el quirofano (al mismo tiempo) no podrá ser proveído por la misma empresa.

-- Creemos que debería de funcionar.
/*
DELIMITER //
CREATE OR REPLACE TRIGGER monopolioEmpresa
before INSERT ON equipamientoelectromedico
FOR EACH ROW
BEGIN
SET @error_message = 
'NO puede haber 3 equipos de la misma empresa a la vez';


if ((SELECT e.nombreEmpresa FROM ingenierobiomedico i , empresa e WHERE e.cif= i.cif and NEW.dni= i.dni)
= (SELECT UNIQUE(e.nombreEmpresa) FROM equipoactual2 ea, ingenierobiomedico i, empresa e 
WHERE ea.dni = i.dni AND e.cif= i.cif 
and SUBSTRING(ea.codigoProducto, 1, 1) <> SUBSTRING(NEW.codigoProducto, 1, 1)) ) 

then

SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END if;

END//

DELIMITER;
*/

#RN-008.Todo el equipamiento electro médico que este en el quirofano (al mismo tiempo) no podrá ser proveído por la misma empresa.

#LA CLAVE ESTA EN EL AFTER

DELIMITER //
CREATE OR REPLACE TRIGGER monopolioEmpresa2
after INSERT ON equipamientoelectromedico
FOR EACH ROW
BEGIN
SET @error_message = 
'NO puede haber 3 equipos de la misma empresa a la vez';


if (auxMonopolio()) then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END if;

END//

DELIMITER ;



-- funcion auxiliar para monopolio2

DELIMITER //
CREATE OR REPLACE FUNCTION auxMonopolio() RETURNS boolean
BEGIN
DECLARE res BOOLEAN DEFAULT FALSE;

DECLARE v1 VARCHAR(50) DEFAULT (SELECT e.nombreEmpresa FROM equipoactual2 ea, ingenierobiomedico i, empresa e 
WHERE ea.dni= i.dni AND i.cif= e.cif AND ea.codigoProducto LIKE 'L%');

DECLARE v2 VARCHAR(50) DEFAULT (SELECT e.nombreEmpresa FROM equipoactual2 ea, ingenierobiomedico i, empresa e 
WHERE ea.dni= i.dni AND i.cif= e.cif AND ea.codigoProducto LIKE 'C%');

DECLARE v3 VARCHAR(50) DEFAULT (SELECT e.nombreEmpresa FROM equipoactual2 ea, ingenierobiomedico i, empresa e 
WHERE ea.dni= i.dni AND i.cif= e.cif AND ea.codigoProducto LIKE 'P%');

if (v1=v2 AND v1=v3 AND v2=v3) then 
set res= TRUE;
END if;

RETURN res;
END //
DELIMITER ;


#RN-009: El equipo debe tener al menos tres años de utilidad, desde que ssu compra


DELIMITER //
CREATE OR REPLACE TRIGGER añosUtilidadMinima
before INSERT ON equipamientoelectromedico
FOR EACH ROW
BEGIN
SET @error_message = 
'Tiene que tener al menos 3 años de utilidad desde su compra';


if (DATEDIFF(NEW.fechaFinVidaUtil, NEW.fechaAdquisicion) < 365*3)  
then

SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END if;

END//

DELIMITER ;

# RN-010: NO se puede registrar revisiones de equipos que no están actualmete en el quirófano

DELIMITER //
CREATE OR REPLACE TRIGGER revisionesConSentido2
before INSERT ON revision
FOR EACH ROW
BEGIN
SET @error_message = 
'NO se puede registrar revisiones de equipos que no están actualmete en el quirófano';
 

if NOT( NEW.codigoProducto IN(SELECT ea.codigoProducto FROM equipoactual2 ea )) 
then

SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END if;

END//

DELIMITER ;



/*
DELIMITER //
CREATE OR REPLACE TRIGGER revisionesConSentido
before INSERT ON revision
FOR EACH ROW
BEGIN
SET @error_message = 
'NO se puede registrar revisiones de equipos que no están actualmete en el quirófano 1';
 

if ( NEW.codigoProducto <> (SELECT ea.codigoProducto FROM equipoactual2 ea 
                                    WHERE SUBSTRING(NEW.codigoProducto,1, 1)  =  SUBSTRING(ea.codigoProducto ,1, 1) )) 
then

SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
END if;

END//

DELIMITER ;
*/
