USE call_center;

######### OUTLIERS

#Se crea una copia de la tabla para evaluar los outliers de q_time
CREATE TABLE analysis_ser_time LIKE calls;
ALTER TABLE analysis_ser_time ADD COLUMN out_sig TINYINT;
ALTER TABLE analysis_ser_time ADD COLUMN out_bp TINYINT;

INSERT INTO analysis_ser_time 
SELECT *, 1, 1 FROM calls;

SELECT * FROM analysis_ser_time; #444.4483

#Se crea tabla que guarda los outliers de q_time
DROP TABLE outliers_ser_time_2; 
CREATE TABLE outliers_ser_time_2 LIKE calls;
ALTER TABLE outliers_ser_time_2 ADD COLUMN metodo TINYINT;

#Insertar outliers segun regla de los 3 sigmas en tabla. MAX='16.661318412545157' MIN='-11.575925895853311'
INSERT INTO outliers_ser_time_2
SELECT *, 1
FROM calls
WHERE ser_time > (SELECT AVG(ser_time) FROM calls) + (3 * (SELECT stddev(ser_time) FROM calls)) 
	  OR ser_time < (SELECT AVG(ser_time) FROM calls) - (3 * (SELECT stddev(ser_time) FROM calls))
      OR ser_time < 0; #5.815 outliers (1.31%)
							
#Insertar outliers segun BoxPlot. MAX='7.408333333333333' MIN='0'
INSERT INTO outliers_ser_time_2
SELECT *, 2
FROM calls
WHERE ser_time > 7.408333333333333 OR ser_time < 0; #32.381 Outliers (7.29%)

SELECT * FROM outliers_ser_time_2; #38.196

-----------------------------------------------------------------
#Revision de patron de outliers
SELECT cod, vru_line, call_id, fecha, vru_entry, outcome, agente, ser_time FROM outliers_ser_time_2
WHERE metodo = 1 AND ser_time > 60
ORDER BY agente, fecha, vru_entry;

#Outliers por agente
SELECT agente, COUNT(*) FROM outliers_ser_time_2
WHERE metodo = 2
GROUP BY agente;
------------------------------------------------------------------

#Insertar outliers segun criterio (ser_time > 60)
#INSERT INTO outliers_ser_time
SELECT *, 3
FROM calls
WHERE ser_time > 40 OR ser_time < 0; # 40: 470 Outliers (0.10%), 60: 141 Outliers (0.032%), 90: 44 Outliers (0.0099%)

#Crear indice porque si no se putea
CREATE INDEX i_calls ON analysis_ser_time(cod);

#Asigna metodo de calculo a la tabla de analisis
UPDATE analysis_ser_time a
JOIN  outliers_ser_time_2 o ON a.cod = o.cod
SET a.out_sig = 0
WHERE o.metodo=1;

UPDATE analysis_ser_time a
JOIN  outliers_ser_time_2 o ON a.cod = o.cod
SET a.out_bp = 0
WHERE o.metodo=2;

#Calculo de promedios
#Normal
SELECT AVG(ser_time) FROM analysis_ser_time; #'2.542696258345923'
#Sin outliers sigma
SELECT AVG(ser_time*out_sig)FROM analysis_ser_time; #'2.1977074557892458'
#Sin outliers BoxPlot
SELECT AVG(ser_time*out_bp)FROM analysis_ser_time; #'1.5724910826836664'

#Calculo de desviaciones
#Normal
SELECT stddev(ser_time) FROM analysis_ser_time; #'4.706207384733078'
#Sin outliers sigma
SELECT stddev(ser_time*out_sig)FROM analysis_ser_time; #'2.742399817511373'
#Sin outliers BoxPlot
SELECT stddev(ser_time*out_bp)FROM analysis_ser_time; #'1.727896919444546'
