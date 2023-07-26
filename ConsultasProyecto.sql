
-- CONSULTAS


--  Informacion sobre los equipamientos electromedicos, actualmente en uso.

-- dos formas de hacerlo, una a traves de la fecha de adquisicion de la tabla equipamiento y otra a traves del oid de las tablas lampara, panel...

CREATE OR REPLACE VIEW equipoactual2 AS 

SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'L%' AND 
fechaAdquisicion>= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee WHERE ee.codigoProducto LIKE 'L%' )
UNION
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'P%' AND 
fechaAdquisicion>= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee WHERE ee.codigoProducto LIKE 'P%' )
UNION
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'C%' AND 
fechaAdquisicion>= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee WHERE ee.codigoProducto LIKE 'C%' );




CREATE OR REPLACE VIEW equipoactual  AS 

SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni
FROM equipamientoelectromedico e NATURAL JOIN lampara l WHERE l.oid_l>=(SELECT MAX(l2.oid_l) FROM lampara l2)
UNION 
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni
FROM equipamientoelectromedico e NATURAL JOIN columnaquirurgica c WHERE c.oid_c>=(SELECT MAX(c2.oid_c) FROM columnaquirurgica c2)
UNION 
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni
FROM equipamientoelectromedico e NATURAL JOIN paneltecnico p WHERE p.oid_p>=(SELECT MAX(p2.oid_p) FROM paneltecnico p2);



-- Vista donde se muestren ordenados adecuadamente las revisiones por equipo y por fecha. (quitando las revisiones de clima y elec)

CREATE or replace VIEW revisionesOrdenadas AS 
SELECT * FROM revision WHERE codigoProducto <> 'NULL' ORDER BY codigoProducto, fechaRevision DESC;

-- Vista que constiene la proxima revision de los equipos actuales del quirofano

CREATE OR REPLACE VIEW proxRevEquipActuales as
SELECT r.codigoProducto, MAX(r.fechaProximaRevision) 'proximaRevision' FROM equipoactual ea, revision r 
WHERE ea.codigoProducto = r.codigoProducto GROUP BY ea.codigoProducto;  




-- Número de lamparas en la BD, precio máximo y precio mínimo y precio medio

SELECT COUNT(*)'Nº de equipos', MAX(precio) 'Precio máximo', MIN(precio) 'Precio minimo', AVG(precio) 'Precio medio'
FROM equipamientoelectromedico WHERE codigoProducto LIKE 'L%';

-- Número de Columnas quirúrgicas en la BD, precio máximo y precio mínimo y precio medio

SELECT COUNT(*)'Nº de equipos', MAX(precio) 'Precio máximo', MIN(precio) 'Precio minimo', AVG(precio) 'Precio medio'
FROM equipamientoelectromedico WHERE codigoProducto LIKE 'C%';

-- Número de Paneles técnicos en la BD, precio máximo y precio mínimo y precio medio

SELECT COUNT(*)'Nº de equipos', MAX(precio) 'Precio máximo', MIN(precio) 'Precio minimo', AVG(precio) 'Precio medio'
FROM equipamientoelectromedico WHERE codigoProducto LIKE 'P%';

-- El nombre, el correo y numero de telefono y la empresa a la que pertenecen(datos de contacto) de los ingenieros que han  
-- trabajado en el mantenimiento de los equipamientos electromedicos.

SELECT e.codigoProducto, e.fechaAdquisicion, i.nombre, i.correoElectronico, i.telefono, em.nombreEmpresa
FROM equipamientoelectromedico e, ingenierobiomedico i, empresa em 
WHERE i.dni=e.dni AND i.cif=em.cif;



-- Las empresas que proveen actualmente la bd 

SELECT unique(e.nombreEmpresa) FROM equipoactual ea, ingenierobiomedico i, empresa e 
WHERE ea.dni= i.dni AND i.cif= e.cif;


-- El precio total actual del quirofano.

SELECT SUM(precio) FROM equipamientoelectromedico where precio IN  (
SELECT precio
FROM equipamientoelectromedico e NATURAL JOIN lampara l WHERE l.oid_l>=(SELECT MAX(l2.oid_l) FROM lampara l2)
UNION 
SELECT precio
FROM equipamientoelectromedico e NATURAL JOIN columnaquirurgica c WHERE c.oid_c>=(SELECT MAX(c2.oid_c) FROM columnaquirurgica c2)
UNION 
SELECT precio
FROM equipamientoelectromedico e NATURAL JOIN paneltecnico p WHERE p.oid_p>=(SELECT MAX(p2.oid_p) FROM paneltecnico p2)
);


-- La media de precio de los diferentes equipamientos electromedicos, así como su máx precio y su min.

SELECT nombreEquipo, AVG(precio)'Precio medio', Min(precio)'Precio mínimo', MAX(precio)'Precio máximo'
FROM equipamientoelectromedico 
GROUP BY nombreEquipo;

-- La cantidad de dinero que se ha gastado en cada empresa y el numero de equipos que se le han comprado,
--  así como el precio medio por equipo ( ordenandolo de mas dinero a menos)

SELECT em.nombreEmpresa, SUM(precio)'Dinero total gastado', COUNT(*)'Nº de equipos', SUM(precio)/COUNT(*) 'precioMedioEquipo'
FROM equipamientoelectromedico e, ingenierobiomedico i, empresa em WHERE e.dni= i.dni AND i.cif = em.cif
GROUP BY em.nombreEmpresa
ORDER BY precio desc;

-- Peso actual del quirofano

SELECT SUM(e.pesoEnKg) FROM equipoactual ea NATURAL JOIN equipamientoelectromedico e;

-- Número de revisiones por equipo 

SELECT codigoProducto, COUNT(*) 'numeroRevisiones' 
from revision where codigoProducto != 'NULL' GROUP  BY codigoProducto ;


-- Equipamiento electromedico que se haya comprado en los últimos 3 años

SELECT codigoProducto, nombreEquipo,fechaAdquisicion, fechaFinVidaUtil, precio FROM equipamientoelectromedico E
WHERE YEAR(E.fechaAdquisicion) BETWEEN YEAR(NOW())-3 AND YEAR(NOW()); 


-- Nombre, codigo del producto, fecha adquisicion y estado del último que haya obtenido menos de un 7 en la ultima revisión

SELECT nombreEquipo, codigoProducto, fechaAdquisicion, estado 
FROM equipamientoelectromedico NATURAL JOIN revision 
WHERE fechaRevision>=(SELECT MAX(fechaRevision) FROM revision WHERE estado<=7);


-- Datos del equipamiento electromedico perteneciente a una empresa y el ingeniero al cargo(En este caso Carburos Medica)

SELECT  em.nombreEmpresa, ing.nombre, ing.apellidos, eq.codigoProducto, ing.dni, ing.telefono, ing.correoElectronico
	FROM equipamientoelectromedico eq, ingenierobiomedico ing , empresa em 
	WHERE eq.dni= ing.dni AND ing.cif= em.cif AND em.nombreEmpresa='Carburos Medica';
	
	
-- (VISTA para la siguiente consulta) Información sobre los ingenieros biomédicos, y el número de revisiones que han hecho
-- aprovechamos el fallo de mariaDB con el nombre. (aquí si tiene sentido que se pueda)

CREATE OR REPLACE VIEW revisionesHechasIngenieros  as
SELECT i.dni, i.nombre,i.apellidos, COUNT(*) 'Revisiones Hechas' FROM revision r, equipamientoelectromedico e, ingenierobiomedico i 
WHERE r.codigoProducto= e.codigoProducto AND e.dni= i.dni GROUP BY i.dni;

-- El ingeniero que haya hecho mas revisiones

SELECT * FROM revisioneshechasingenieros rhi 
WHERE rhi.`Revisiones Hechas`>= (SELECT MAX(rhii.`Revisiones Hechas`) FROM revisioneshechasingenieros rhii) ;	
	
	
-- Equipamiento al que se le haya hecho mas revisiones

create or replace VIEW countRevisiones as SELECT r.codigoProducto, COUNT(*) 'nRevisiones' FROM revision r 
WHERE codigoProducto <> 'NULL'
GROUP BY r.codigoProducto;

SELECT codigoProducto, max(nRevisiones) FROM countRevisiones;	
	
-- Dias de utilidad del equipamiento actual del quirofano

SELECT codigoProducto, DATEDIFF(fechaFinVidaUtil, fechaAdquisicion) FROM equipoactual NATURAL JOIN equipamientoelectromedico;

-- Días que llevan activos los equipos desde su compra

SELECT codigoProducto  , DATEDIFF(NOW(),fechaAdquisicion) FROM equipamientoelectromedico;	
	















