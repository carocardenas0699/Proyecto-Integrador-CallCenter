USE call_center;

######### OUTLIERS

---------------------------------------------------------------
#Analisis de valores negativos
SELECT * FROM calls
WHERE vru_time < 0; #350 (0.078%)

#Se agregan a tabla auxiliar los registros de valores negativos
INSERT INTO modified_calls SELECT *, 'vru_time negativo' FROM calls
WHERE vru_time < 0;

#Se hace la conversion de los valores negativos
UPDATE calls SET vru_time = ABS(vru_time);
---------------------------------------------------------------

#Se crea una copia de la tabla para evaluar los outliers de q_time
DROP TABLE analysis_vru_time;
CREATE TABLE analysis_vru_time LIKE calls;
ALTER TABLE analysis_vru_time ADD COLUMN out_sig TINYINT;
ALTER TABLE analysis_vru_time ADD COLUMN out_bp TINYINT;

INSERT INTO analysis_vru_time 
SELECT *, 1, 1 FROM calls;

SELECT * FROM analysis_vru_time; #444.448

#Se crea tabla que guarda los outliers de q_time
DROP TABLE outliers_vru_time_2;
CREATE TABLE outliers_vru_time_2 LIKE calls;
ALTER TABLE outliers_vru_time_2 ADD COLUMN metodo TINYINT;

#Insertar outliers segun regla de los 3 sigmas en tabla. MAX='1.9185395381666375' MIN='-1.5756701749270454'
INSERT INTO outliers_vru_time_2
SELECT *, 1
FROM calls
WHERE vru_time > (SELECT AVG(vru_time) FROM calls) + (3 * (SELECT stddev(vru_time) FROM calls)) 
	  OR vru_time < (SELECT AVG(vru_time) FROM calls) - (3 * (SELECT stddev(vru_time) FROM calls))
      OR vru_time < 0; #Con neg: 1.691 outliers (0.38%), Sin neg: 1.393 (0.31%)
							
#Insertar outliers segun BoxPlot. 
#Con neg: MAX='0.2666666666666666' MIN='2.7755575615628914e-17', 41220 Outliers (9.27%)
#Sin neg: 
INSERT INTO outliers_vru_time_2
SELECT *, 2
FROM calls
WHERE vru_time > 0.2666666666666666 OR vru_time < 2.7755575615628914e-17; #

#Insertar outliers segun BoxPlot. MAX='0.2666666666666666' MIN='0'
INSERT INTO outliers_vru_time_2
SELECT *, 3
FROM calls
WHERE vru_time > 0.2666666666666666 OR vru_time < 0; #32524 Outliers (7.32%)

SELECT * FROM outliers_vru_time_2; #75.435

#Crear indice porque si no se putea
CREATE INDEX i_calls ON analysis_vru_time(cod);

#Asigna metodo de calculo a la tabla de analisis
UPDATE analysis_vru_time a
JOIN  outliers_vru_time_2 o ON a.cod = o.cod
SET a.out_sig = 0
WHERE o.metodo=1;

UPDATE analysis_vru_time a
JOIN  outliers_vru_time_2 o ON a.cod = o.cod
SET a.out_bp = 0
WHERE o.metodo=2;

ALTER TABLE analysis_vru_time ADD COLUMN out_bp_0 TINYINT;
UPDATE analysis_vru_time SET out_bp_0 = 1;

UPDATE analysis_vru_time a
JOIN  outliers_vru_time_2 o ON a.cod = o.cod
SET a.out_bp_0 = 0
WHERE o.metodo=3;

#Calculo de promedios
#Normal
SELECT AVG(vru_time) FROM analysis_vru_time; #'0.17143468161979605'
#Sin outliers sigma
SELECT AVG(vru_time*out_sig)FROM analysis_vru_time; #'0.14924220913215372'
#Sin outliers BoxPlot
SELECT AVG(vru_time*out_bp)FROM analysis_vru_time; #'0.11796918407780295'
#Sin outliers BoxPlot hasta 0
SELECT AVG(vru_time*out_bp_0)FROM analysis_vru_time; #'0.11796918407780295'

#Calculo de desviaciones
#Normal
SELECT stddev(vru_time) FROM analysis_vru_time; #'0.5823682855156138'
#Sin outliers sigma
SELECT stddev(vru_time*out_sig)FROM analysis_vru_time; #'0.12501854149483171'
#Sin outliers BoxPlot
SELECT stddev(vru_time*out_bp)FROM analysis_vru_time; #'0.05936379676941247'
#Sin outliers BoxPlot hasta 0
SELECT stddev(vru_time*out_bp_0)FROM analysis_vru_time; #'0.05936379676941247'
