USE call_center;

######### OUTLIERS

#Se crea una copia de la tabla para evaluar los outliers de q_time
CREATE TABLE analysis_q_time LIKE calls;
ALTER TABLE analysis_q_time ADD COLUMN out_sig TINYINT;
ALTER TABLE analysis_q_time ADD COLUMN out_bp TINYINT;

INSERT INTO analysis_q_time 
SELECT *, 1, 1 FROM calls;

SELECT * FROM analysis_q_time; #444.4483

#Se crea tabla que guarda los outliers de q_time
DROP TABLE outliers_q_time_2;
CREATE TABLE outliers_q_time_2 LIKE calls;
ALTER TABLE outliers_q_time_2 ADD COLUMN metodo TINYINT;

#Insertar outliers segun regla de los 3 sigmas en tabla. MAX='6.956914775950615' MIN='-4.990104634804974'
INSERT INTO outliers_q_time_2
SELECT *, 1
FROM calls
WHERE q_time > (SELECT AVG(q_time) FROM calls) + (3 * (SELECT stddev(q_time) FROM calls)) 
	  OR q_time < (SELECT AVG(q_time) FROM calls) - (3 * (SELECT stddev(q_time) FROM calls))
      OR q_time < 0; #5.184 outliers (1.17%)
							
#Insertar outliers segun BoxPlot. MAX='3.2916675' MIN='0'
INSERT INTO outliers_q_time_2
SELECT *, 2
FROM calls
WHERE q_time > 3.2916675 OR q_time < 0; #37.237 Outliers (8.38%)

SELECT * FROM outliers_q_time_2; #42.421

#Crear indice porque si no se putea
CREATE INDEX i_calls ON analysis_q_time(cod);

#Asigna metodo de calculo a la tabla de analisis
UPDATE analysis_q_time a
JOIN  outliers_q_time_2 o ON a.cod = o.cod
SET a.out_sig = 0
WHERE o.metodo=1;

UPDATE analysis_q_time a
JOIN  outliers_q_time_2 o ON a.cod = o.cod
SET a.out_bp = 0
WHERE o.metodo=2;

#Calculo de promedios
#Normal
SELECT AVG(q_time) FROM analysis_q_time; #'0.9834050705728208'
#Sin outliers sigma
SELECT AVG(q_time*out_sig)FROM analysis_q_time; #'0.872038498960118'
#Sin outliers BoxPlot
SELECT AVG(q_time*out_bp)FROM analysis_q_time; #'0.5453150500724715'

#Calculo de desviaciones
#Normal
SELECT stddev(q_time) FROM analysis_q_time; #'1.9911699017925981'
#Sin outliers sigma
SELECT stddev(q_time*out_sig)FROM analysis_q_time; #'1.3185738113446972'
#Sin outliers BoxPlot
SELECT stddev(q_time*out_bp)FROM analysis_q_time; #'0.8096631323285934'
