USE call_center;

--------------- q_time
SELECT COUNT(*) FROM calls
WHERE q_time > 15; # 218 '0.049%'

CREATE TABLE outliers_q_time LIKE calls;
INSERT INTO outliers_q_time
SELECT * FROM calls
WHERE q_time > 15 OR q_time < 0; #218 Outliers 

--------------- ser_time
SELECT COUNT(*) FROM calls
WHERE ser_time > 50; # 50: 234

CREATE TABLE outliers_ser_time LIKE calls;
INSERT INTO outliers_ser_time
SELECT * FROM calls
WHERE ser_time > 50 OR ser_time < 0; #234 Outliers (0.053%)

---------------- vru_time
CREATE TABLE outliers_vru_time LIKE calls;	
INSERT INTO outliers_vru_time
SELECT * FROM calls
WHERE vru_time > (SELECT AVG(vru_time) FROM calls) + (3 * (SELECT stddev(vru_time) FROM calls)) 
	  OR vru_time < (SELECT AVG(vru_time) FROM calls) - (3 * (SELECT stddev(vru_time) FROM calls))
      OR vru_time < 0; #Sin neg: 1.393 (0.31%)

#Comparacion outliers entre columnas ------------------------------------------------------
#Todas
SELECT oq.* FROM outliers_q_time oq
JOIN outliers_ser_time oser ON oq.cod = oser.cod
JOIN outliers_vru_time ov ON oq.cod = ov.cod; #0 outliers en comun

#q_time vs ser_time
SELECT oq.* FROM outliers_q_time oq
JOIN outliers_ser_time oser ON oq.cod = oser.cod; #3 outliers en comun

#q_time vs vru_time
SELECT oq.* FROM outliers_q_time oq
JOIN outliers_vru_time ov ON oq.cod = ov.cod; #0 outliers en comun

#ser_time vs vru_time
SELECT oser.* FROM outliers_ser_time oser
JOIN outliers_vru_time ov ON oser.cod = ov.cod; #1 outliers en comun

#Borrar outliers --------------------------------------------------------------
#Se crea tabla back up por si
DROP TABLE calls_backup;
CREATE TABLE calls_backup LIKE calls; 
INSERT INTO calls_backup SELECT * FROM calls;

#Agregar outliers a la tabla auxiliar
INSERT INTO deleted_calls SELECT *, 'Outlier q_time' FROM outliers_q_time; #218
INSERT INTO deleted_calls SELECT *, 'Outlier ser_time' FROM outliers_ser_time; #234
INSERT INTO deleted_calls SELECT *, 'Outlier vru_time' FROM outliers_vru_time; #1393

#Crear indice porque si no se putea x2
CREATE INDEX calls_i ON calls(cod);

#Borrar los outliers de q_time
DELETE FROM calls WHERE cod IN (SELECT cod FROM outliers_q_time);
DELETE FROM calls WHERE cod IN (SELECT cod FROM outliers_ser_time);
DELETE FROM calls WHERE cod IN (SELECT cod FROM outliers_vru_time);

#Revision de promedio y desviaciones estandar nuevas
SELECT AVG(q_time), AVG(vru_time), AVG(ser_time), 
       STDDEV(q_time), STDDEV(vru_time), STDDEV(ser_time) FROM calls;