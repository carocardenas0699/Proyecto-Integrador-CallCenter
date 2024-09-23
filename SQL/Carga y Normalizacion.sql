CREATE DATABASE call_center;
USE call_center;

DROP TABLE calls;
CREATE TABLE calls2(vru_line VARCHAR(10),
                   call_id INT,
                   customer_id VARCHAR(50),
                   priority TINYINT,
                   tipo VARCHAR(5),
                   fecha DATE,
                   vru_entry TIME,
                   vru_exit TIME,
                   vru_time FLOAT,
                   q_start TIME,
                   q_exit TIME,
                   q_time FLOAT,
                   outcome VARCHAR(10),
                   ser_start TIME,
                   ser_exit TIME,
                   ser_time FLOAT,
                   agente VARCHAR(50),
                   startdate INT);
                   
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Call_Center_1999.csv'
INTO TABLE calls2
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 

######### NORMALIZACION

#Se borran columnas que no se consideran relevantes
ALTER TABLE calls DROP COLUMN vru_exit;
ALTER TABLE calls DROP COLUMN q_exit;
ALTER TABLE calls DROP COLUMN ser_exit;
ALTER TABLE calls DROP COLUMN q_start;
ALTER TABLE calls DROP COLUMN ser_start;
ALTER TABLE calls DROP COLUMN startdate;

#Se cambia la unidad de los tiempos
UPDATE calls SET vru_time = vru_time/60;
UPDATE calls SET q_time = q_time/60;
UPDATE calls SET ser_time = ser_time/60;

#Se crea un identificar unico para cada registro
ALTER TABLE calls
ADD COLUMN cod VARCHAR(50);
UPDATE calls SET cod = CONCAT(vru_line,call_id);

#Categorizacion de priority
ALTER TABLE calls MODIFY COLUMN priority VARCHAR(6);
UPDATE calls SET priority = 'Normal' WHERE priority = 0 OR priority = 1; #306.995
UPDATE calls SET priority = 'Alta' WHERE NOT priority = 'Normal';

#Normalizar nombre de Server
SELECT agente, COUNT(*) FROM calls
GROUP BY agente;
UPDATE calls SET agente = 'NO_SERVER' WHERE agente = 'NO_SERVERAMA' OR agente = 'ANO_SERVERT';

#Normalizar tipo TT
UPDATE calls SET tipo = 'TT' WHERE tipo = ' TT';

#Se crea tabla para ingresar los registros borrados
CREATE TABLE deleted_calls LIKE calls;
ALTER TABLE deleted_calls ADD COLUMN motivo VARCHAR(255);

#Registros que tienen todos los tiempos en 0
SELECT * FROM calls
WHERE vru_time = 0 AND q_time = 0 AND ser_time = 0; #5390 (1.21%)

INSERT INTO deleted_calls SELECT *, 'Todos los tiempos en 0' FROM calls
WHERE vru_time = 0 AND q_time = 0 AND ser_time = 0;

#Borrar registros con todos los tiempos en 0
DELETE FROM calls WHERE vru_time = 0 AND q_time = 0 AND ser_time = 0;

#Se crea tabla para ingresar datos cambiados
CREATE TABLE modified_calls LIKE calls;
ALTER TABLE modified_calls ADD COLUMN motivo VARCHAR(255);
