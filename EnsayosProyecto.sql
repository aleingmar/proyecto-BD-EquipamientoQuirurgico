
# INDICACIONES: está preparado para que todo esté perfecto, si se ejecuta todas las lineas de codigo de arriba a abajo.
#               si no es posible que se descontrole. :)




                                   #PRUEBAS PROCEDIMIENTOS


-- Procedimientos para insertar

CALL `insertaRevision`('7', '2022-02-7', 'L090', '67', '80');

CALL `insertaEquipamientoElectromedico`('C129', '123', 'Columna Quirúrgica', 
'2028-12-23', '20', '1200', '2017-01-12', '60245603V');

CALL `insertaRevisionAuxiliar`('C129', '2', '2018-10-10', 'Problemas con la toma de alimentacion');

CALL `insertaIngenieroBiomedico`('12345678A', '1223344455', 'Carlos', 'Ramirez Manzano', 'Ingenieria de la Salud', 
'1998-02-21', '11100', '644890789', 'carlitosramirez98@gmail.com', 'A08993735');

CALL `insertaEmpresa`('A34568975', 'novaclinic', 'novaclinicweb', 'España', 'Carpestro,14', '601234556');



# Procedimiento para rebajar un 60% el precio de los equipos que le quedan un año para caducar.

CALL `insertaEquipamientoElectromedico`('L800', '123', 'Lámpara', 
'2023-1-23', '20', '10000', '2019-01-12', '60245603V');

SELECT e.codigoProducto, e.fechaFinVidaUtil, e.precio FROM equipamientoelectromedico e 
WHERE DATE_ADD(NOW(), INTERVAL 365 DAY) >= e.fechaFinVidaUtil;

CALL rebajaPrecioFinVida();


# Procedimiento para atrasar la fecha proxima revision en 5 dias del equipo actual

SELECT * FROM proxrevequipactuales;

CALL `aumentarFechaProximaRevision`();

# PROCEDIMEINTO QUE CAMBIE los parámetros minimos de la última normativaClimatizacion en un 15%

SELECT * from normativaclimatizacion n 
where n.fechaNormativaClimatizacion>= (SELECT MAX(fechaNormativaClimatizacion) FROM normativaclimatizacion);

CALL `cambioPorcentajeNormativaClima`();

-- PROCEDIMEINTO QUE acota el intervalo de valor de luz de laas normativas de electricidad

SELECT * from normativaelectricidad n 
WHERE n.fechaNormativaElectricidad>= (SELECT MAX(fechaNormativaElectricidad) FROM normativaelectricidad);

CALL `cambioIntervaloNormativaElectricidad`();

# Procedimiento que cambia de periodicidad de clima y electricidad

SELECT n.fechaNormativaElectricidad 'fechaNormativa', n.periodicidadRevisionDias from normativaelectricidad n 
WHERE n.fechaNormativaElectricidad>= (SELECT MAX(fechaNormativaElectricidad) FROM normativaelectricidad)
UNION 
SELECT nc.fechaNormativaClimatizacion 'fechaNormativa', nc.periodicidadRevisionDias from normativaclimatizacion nc
where nc.fechaNormativaClimatizacion>= (SELECT MAX(fechaNormativaClimatizacion) FROM normativaclimatizacion);


CALL `cambioPeriodicidadNormativas`();




                                       #PRUEBAS FUNCIONES
 
 
                                       
#Devuelveme la nota de la peor revision de un determinado equipamiento electromedico
SELECT MIN(r.estado) FROM revision r where r.codigoProducto= 'C127';
select MIN(ra.estado)  from revisionauxiliar ra where ra.codigoProducto='C127';
                                       
SELECT `estadoPeorEquipo`('C127');


#Cantidad de revisiones de un ingeniero por debajo del 5

SELECT e.dni,COUNT(*) FROM  revision r NATURAL JOIN equipamientoelectromedico e WHERE e.dni='32536784Z'  AND r.estado<6 GROUP BY e.dni;
SELECT e.dni, COUNT(*) FROM  revisionauxiliar ra, equipamientoelectromedico e WHERE  ra.codigoProducto= e.codigoProducto and e.dni= '32536784Z' AND ra.estado<6 GROUP BY e.dni;

SELECT `numRevisionesMenor5`('32536784Z');

#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Lamparas).
SELECT * FROM lampara WHERE codigoProducto='L089';

SELECT `evaluacionLampara`('L089', '800', '50');
SELECT `evaluacionLampara`('L089', '3000', '50');
SELECT `evaluacionLampara`('L089', '800', '1');

#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Columnas Quirúrgicas).
SELECT * FROM columnaquirurgica WHERE codigoProducto='C127';

SELECT `evaluacionColumna`('C127', '20', '10');
SELECT `evaluacionColumna`('C127', '1', '10');
SELECT `evaluacionColumna`('C127', '1', '-20');

#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Paneles).
SELECT * FROM paneltecnico WHERE codigoProducto='P101';

SELECT `evaluacionPanel`('P101', '3000', '6');
SELECT `evaluacionPanel`('P101', '120', '6');
SELECT `evaluacionPanel`('P101', '2000', '1');

#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Segun la normativa actual de la Electricidad).
SELECT * FROM normativaelectricidad ne WHERE ne.fechaNormativaElectricidad=(SELECT MAX(ne.fechaNormativaElectricidad) FROM normativaelectricidad ne);

SELECT `evaluacionElectricidad`('1');
SELECT `evaluacionElectricidad`('2000');

#QUE ME DIGA SI LAS MEDICIONES QUE ESTOY LLEVANDO A CABO, ESTÁN CORRECTAMENTE (Segun la normativa actual de la Climatizacion).
SELECT * FROM normativaclimatizacion nc WHERE nc.fechaNormativaClimatizacion=(SELECT MAX(nc.fechaNormativaClimatizacion) FROM normativaclimatizacion nc);

SELECT `evaluacionClimatizacion`('1', '1', '1');
SELECT `evaluacionClimatizacion`('3000', '20', '50');

# Función que dado el código de un producto te devuelva la fecha de la próxima revisión
SELECT max(fechaProximaRevision)
FROM revision r
WHERE r.codigoProducto= 'C128';

SELECT `revProx`('C128');
SELECT `revProx`('C127');

# Función que dado el nombre de una empresa devuelva el dinero invertido
SELECT SUM(precio) 
		FROM equipamientoelectromedico eq, ingenierobiomedico ing , empresa em 
		WHERE eq.dni= ing.dni AND ing.cif= em.cif AND 'Carburos Medica'= em.nombreEmpresa;

SELECT `DineroInvEmpr`('Carburos Medica');
SELECT `DineroInvEmpr`('NovaClinic');

# Funcion que dado el dni de un ingeniero devuelva el nombre de la empresa a la que pertenece
SELECT nombreEmpresa
	FROM ingenierobiomedico i, empresa e
	WHERE i.cif= e.cif AND '32536784Z'=i.dni;
	
SELECT `EmpresaALaQuePertenece`('32536784Z');

#Nos devuelve dada una fecha el coste del quirófano en esa fecha

SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'L%' AND 
fechaAdquisicion = (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'L%'  AND ee.fechaAdquisicion<='2021-1-1')
UNION
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'P%' AND 
fechaAdquisicion= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'P%' AND ee.fechaAdquisicion<='2021-1-1' )
UNION
SELECT codigoProducto, nombreEquipo, precio, fechaAdquisicion, dni FROM equipamientoelectromedico  WHERE codigoProducto LIKE 'C%' AND 
fechaAdquisicion= (SELECT MAX(ee.fechaAdquisicion) FROM equipamientoelectromedico ee 
WHERE ee.codigoProducto LIKE 'C%' AND ee.fechaAdquisicion<='2021-1-1');


SELECT `PrecioEnFecha`('2021-1-1');
SELECT `PrecioEnFecha`('2010-1-1');

#Nos devuelve la diferencia de coste entre el quirófano actualmente y el coste del quirófano en esa fecha

SELECT `PrecioEnFecha`(NOW());
SELECT `PrecioEnFecha`('2021-1-1');

SELECT `DiferenciaCoste`('2021-1-1');

#Calcula el año de la normativa más exigente 

SELECT `NormativaMasExigente`();



 #PROBAR LOS TRIGGERS

#RN-001: La fecha de revision de un equipo no puede cambiar en mas de 5 dias 
#con respecto a la fecha en la que se preveia revisarlo segun su periodicidad

SELECT `revProx`('C128');

CALL `insertaRevision`('9.1', '2022-1-29', 'C128', '8', '9');

#RN-002. El sistema debe garantizar que los equipos sean repuestos antes de superar su vida útil. 
#para ello, avisa al hacer una revision del equipo en cuestion 3 meses antes de insertar una revision de estas.

SELECT * FROM equipamientoelectromedico WHERE codigoProducto='P101';
CALL `insertaRevision`('6.7', '2022-2-28', 'P101', '8', '9');

#RN-003. Check sobre el estado revision

CALL `insertaRevision`('14', '2022-1-25', 'C128', '8', '9');


#RN-004 El codigo de producto, la primera sigla tienen que coincidir con la primera letra del atributo nombre de ese equipamiento electromedico

CALL insertaEquipamientoElectromedico('C456', '100', 'Lampara', '2021-4-2', '78', '34000.67', '2022-1-1', '89898989H');


#RN-005 Si en una revision la nota cambia 3 puntos frente a la revision anterior del mismo equipo, salta un aviso. 
#Esa revision se guarda en la nueva tabla Revision Auxiliar

SELECT estado FROM revision WHERE fechaProximaRevision=revProx('C128');
CALL `insertaRevision`('6', '2022-1-18', 'C128', '8', '9');

#RN-006 Cambiar el equipamiento despues de que baje en una revision la calificacion del 3 (el estado)

CALL `insertaRevision`('7', '2022-1-18', 'C128', '8', '9');
CALL `insertaRevision`('4.3', '2022-2-8', 'C128', '8', '9');
CALL `insertaRevision`('2.3', '2022-2-28', 'C128', '8', '9'); #debe saltar este :)


#RN-007 que lleve 3 revisiones seguidas anteriores por debajo del 5.5. (la que meto seria la cuarta)

# NO DEBE SALTAR MENSAJE, SINO QUE DEBE DE INSERTARSE EN LA TABLA REVISIONAUXILIAR

CALL `insertaRevision`('5.4', '2022-2-28', 'C128', '8', '9'); # segundo
CALL `insertaRevision`('5.3', '2022-3-20', 'C128', '8', '9'); # tercera
CALL `insertaRevision`('5.2', '2022-4-10', 'C128', '8', '9'); # debe de saltar este :)



#RN-008. Todo el equipamiento electro médico que esté en el quirófano (al mismo tiempo) no podrá ser proveído por la misma empresa.

SELECT e.nombreEmpresa, ea.codigoProducto, i.dni, e.cif FROM equipoactual2 ea, ingenierobiomedico i, empresa e 
WHERE ea.dni = i.dni AND e.cif= i.cif;

SELECT e.nombreEmpresa FROM ingenierobiomedico i , empresa e WHERE e.cif= i.cif and '45678314C'= i.dni;

SELECT UNIQUE(e.nombreEmpresa) FROM equipoactual2 ea, ingenierobiomedico i, empresa e 
WHERE ea.dni = i.dni AND e.cif= i.cif 
and SUBSTRING(ea.codigoProducto, 1, 1) <> SUBSTRING('C202', 1, 1);


CALL `insertaEquipamientoElectromedico`('C202', '123', 'Columna',  # Esto es lo que salta :)
'2028-12-23', '20', '1200', '2023-02-20', '45678314C');



#RN-009: El equipo debe tener al menos tres años de utilidad, desde que ssu compra

CALL `insertaEquipamientoElectromedico`('C289', '1000', 'Columna', '2023-1-1', '56', '34000.89', '2022-1-1',
 '99999999F');


# RN-010: NO se puede registrar revisiones de equipos que no están actualmente en el quirófano

SELECT * FROM equipoactual2;
CALL `insertaRevision`('8.2', '2021-10-9', 'C127', '8', '8');


# RN-011: Los valores maximos tienen que ser mayores que los valores minimos de un mismo intervalo.
# (en las tablas de las normativas y en las tablas de los equipos; lampara... ) 

INSERT INTO normativaElectricidad(nivelLuxMaxima, nivelLuxMinima, fechaNormativaElectricidad, 
periodicidadRevisionDias)
VALUES (270, 1000, 2016, 14);

INSERT INTO normativaClimatizacion(caudalAireMinimo, caudalAireMaximo, gradosMaximos, gradosMinimos, porcentajeHumedadMinimo,
PorcentajeHumedadMaximo, fechaNormativaClimatizacion, periodicidadRevisionDias)
VALUES (2700, 350, 2, 19, 48, 5, 2012, 20);

INSERT INTO columnaQuirurgica(codigoProducto,voltiosMinimos, voltiosMaximos,gradosMinimos, gradosMaximos,alturaMetros)
VALUES ('C127',100, 60, 100, 50, 2.2);


INSERT INTO lampara(valorLuxMaximo, valorLuxMinimo, gradosMaximos, gradosMinimos, numeroLeds, codigoProducto) 
VALUES (100.00, 400.00, 55, 95, 48, 'L089');


INSERT INTO panelTecnico(valorLuxMaximo, valorLuxMinimo, presionGasMaximoBar, presionGasMinimoBar, codigoProducto) 
VALUES(700, 1000, 1, 5, 'P100');


#RN-012: La fecha proxima de revisión tiene que ser mayor o igual a la fecha de revision.(tablas de revision y revisionAux)

INSERT INTO revisionauxiliar(codigoProducto, estado, FechaRevision, fechaSiguienteRevision, motivo)
VALUES ('C127', 4 , '2023-10-9', '2021-10-29', 'Hola ');

INSERT INTO revision(oid_r, estado,  fechaRevision, fechaProximaRevision, codigoProducto,
fechaNormativaElectricidad, fechaNormativaClimatizacion)
VALUES (1, 9.6, '2023-1-1', '2021-1-14', NULL, 2018, NULL);






#SELECT  row_number() OVER (ORDER BY r.fechaRevision), r.codigoProducto FROM revision r ; 
















