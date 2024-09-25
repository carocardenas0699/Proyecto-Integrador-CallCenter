# Proyecto-Integrador-M5

Se realizó el analisis de un caso de negocio basado en el Call Center del banco **“Anonymous Bank”** en Israel. En este repositorio se encuentra el Analisis Exploratorio de Datos desarrollado en Python y un Dashboard de control de resultados elaborado en PowerBI. <br>
El dataset entregado contiene las llamadas registradas durante 12 meses (desde el 01/01/99 hasta el 31/12/99). <br>
A continuación, se describe el contexto correspondiente a los datos analizados.

## Descripción General
El Call Center de **"Anonymous Bank"** provee varios servicios diferentes: <br>
- Información y transacciones sobre cheques y cuentas de ahorros, de sus clientes bancarios. <br>
- Respuesta de voz generada por computadora con información sobre las cuentas de los clientes (a través del dispositivo VRU = Voice Response Unit (unidad de respuesta de voz). Una unidad de respuesta de voz (VRU) es un sistema de contestador telefónico automático que posee un hardware y software que permite a la persona que llama navegar a través de una serie de mensajes pregrabados y utilizar un menú de opciones mediante los botones de un teléfono o el reconocimiento de voz.) <br>
- Brindar información a prospectos de clientes. <br> 
- Soporte a los clientes del web-site de "Anonymous Bank" (clientes que acceden al Home Banking)<br>

### Capacidad del Call Center
El call center esta conformado por:<br>
- 8 posiciones de agentes para llamadas de clientes y prospectos<br>
- 1 posición de supervisor<br>
- 5 posiciones de agentes para llamadas para soporte de internet home banking (en un cuarto adjac room)<br>

### Horario de atención
- Domingo a Jueves: 7:00 a.m. a la medianoche. <br>
- Viernes a Sábado: 2:00 p.m.  del Viernes y reabre a las 8:00 p.m. del Sábado.<br>
- El servicio automático (VRU) opera los 7 días de la semana, 24 horas al día (7x24).<br>

## Descripción de la Estructura de Datos
El dataset contiene toda la información del Call Centre de un año calendario: Enero 1999 a Diciembre 1999. Cada registro / fila del dataset, contiene una llamada (entre 20,000 a 30,000 llamadas por mes).

1. **vru_line** - 6 dígitos <br>
Cada llamada telefónica entrante es ruteada a través del VRU. Hay 6 VRUs etiquetados desde  AA01 a AA06. Cada VRU tiene varias líneas etiquetadas de 1 a 16. Hay un total de 65 líneas. Cada llamada es asignada a un número de VRU y a un número de línea.
2. **call_id** - 5 dígitos <br>
A cada llamada telefónica entrante se le asigna un “call id”. Aunque son diferentes, los identificadores no son necesariamente consecutivos por estar asignado a diferentes VRUs.
3. **customer_id** - 0 a 12 dígitos <br>
Es la identificación del cliente. Es única por cliente; si el ID es cero, es porque el sistema no pudo identificar a la persona que realiza la llamada (por ejemplo para el caso de los prospectos no se identifican).
4. **priority** - 1 digito <br>
Hay dos tipos de prioridades: (Alta-)prioridad y Regular:
   - 0 y 1 indican clientes no identificados o clientes regulares (los detallaremos más adelante)
   - 2 indica clientes de Alta Prioridad. A los clientes de Alta Prioridad se les asigna un tiempo de espera de 1.5 minutos al comienzo de su llamada (esto les permite avanzar en la posición de la cola de llamadas).
5. **type** - 2 digits <br>
Hay 6 tipos diferentes de servicio:
   - PS - Actividad Regular
   - PE - Actividad Regular en inglés
   - IN - Actividad / Consulta por internet
   - NE - Actividad por Acciones (stock exchange)
   - NW - Cliente potencial (prospecto) solicitando información
   - TT – clientes que dejan un mensaje pidiendo al banco que le devuelvan su llamado pero que cuando el sistema automático devuelve el llamado, el agente pasó a estado “ocupado”, dejando al cliente en espera en la cola.
6. **date** - 6 dígitos (año-mes-día) <br>
La fecha en la cual se realizó la llamada.
7. **vru_entry** - 6 dígitos <br>
Hora en que la llamada telefónica ingresa al call center. Es decir, la hora en que la llamada ingresa a la VRU.
8. **vru_exit** - 6 dígitos <br>
Hora de salida de la VRU: 
9. **vru_time** - 1 a 3 dígitos <br>
Tiempo (en segundos) de espera en la VRU (calculada como vru_time= exit_time – entry_time) .
10. **q_start** - 6 dígitos <br>
Hora en la que se une a la cola. (la llamada queda “en espera”).
11. **q_exit** - 6 digits <br>
Tiempo (en segundos) en salir de la cola: ya sea porque recibe el servicio o por qué abandona el llamado.
12. **q_time** - 1 to 3 digitos <br>
Tiempo de espera en la cola (calculado por q_time = q_exit – q_start)
13. **outcome** - 4,5 o 7 digitos <br>
Destino final de la llamada. Hay tres posibles salidas por cada llamada:
    - AGENT: se dio servicio
    - HANG: se cortó la llamada y no se dió servicio
    - PHANTOM: una llamada en la que virtualmente se ignora lo que sucedió (afortunadamente son pocas llamadas en esta situación).
14. **ser_start** - 6 digitos <br>
Hora de comienzo del servicio por un agente.
15. **ser_exit** - 6 digitos <br>
Hora del final del servicio por un agente.
16. **ser_time** - 1 to 3 digitos <br>
Duración del servicio en segundos (calculada como ser_time = ser_exit – ser_start)
17. **server** - text <br>
Nombre del cliente que atendió la llamada. Este campo es NO_SERVER, si el servicio no fue provisto.

## Informacion adicional necearia
Para realizar un analisis mas preciso de la actividad del Call Center seria necesario las siguiente informacion adicional:
- Listado de los agentes que trabajaron en el Call Center durante el año y el periodo durante el cual estuvieron activos para poder normalizar los nombres del campo **'Server'** de manera adecuada.
- Informacion adicional de los clientes para poder identificarlos de manera correcta.
- Una calificacion a la llamada por parte de los clientes de manera que se pueda evaluar de manera mas precisa el trabajo de los agentes.
