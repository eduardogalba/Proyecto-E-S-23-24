# Proyecto de Entrada–Salida (2023–2024)
El objetivo del proyecto es que el alumno se familiarice con la realizacion de operaciones de Entrada/Salida en un periferico mediante interrupciones. El dispositivo elegido es la DUART MC68681 operando ambas lineas 
mediante interrupciones. En el computador del proyecto la DUART esta conectada a la <strong>linea de peticion de interrupcion de nivel 4.</strong> <br>
La estructura del proyecto se muestra en la figura 5.1. Como puede apreciarse se necesitan unos bufferes internos para almacenar los caracteres que se reciben asincronamente por las lineas. Del mismo modo, se necesitan sendos bufferes internos para almacenar los caracteres pendientes de 
transmitirse por las lineas. <br>
Ademas, existe una unica rutina de tratamiento de las interrupciones de las lineas que sera la encargada transferir la informacion a o desde los mencionados bufferes internos. El
proyecto implica la programacion de la rutina de tratamiento de las interrupciones (RTI) asi como de las subrutinas SCAN y PRINT que constituyen la interfaz:
<ul>
<li> <strong> INIT: </strong> Inicializacion de los dispositivos. Preparara las dos lineas serie para recibir y transmitir caracteres y notificar los sucesos mediante la solicitud de interrupciones. </li>
<li> <strong>SCAN:</strong> Lectura de un dispositivo. Devolvera un bloque de caracteres que se haya recibido
previamente por la linea correspondiente (A o B). </li>
<li> <strong>PRINT:</strong> Escritura en un dispositivo. Ordenara la escritura de un bloque de caracteres por
la linea correspondiente (A o B). </li>
</ul>
Como ayuda para la implementacion y prueba de los bufferes internos que deben manipular las subrutinas anteriores, se proporcionan las subrutinas auxiliares que se indican a
continuacion:<br><br>
<ul>
<li> <strong>LEECAR:</strong> Obtencion de un caracter de un buffer interno. Se encarga, junto a la funcion
siguiente, de la gestion de los bufferes internos que permiten el comportamiento no
bloqueante de las subrutinas SCAN y PRINT. </li>
<li> <strong>ESCCAR:</strong> Insercion de un caracter en un buffer interno. Se encarga, junto a la funcion
anterior, de la gestion de los bufferes internos que permiten el comportamiento no
bloqueante de las subrutinas SCAN y PRINT. </li>
<li> <strong>INI_BUFS:</strong> Inicializacion de todos los buffers internos involucrados en el proyecto. Esta
subrutina se invocara una sola vez desde INIT. </li>
</ul>

Es importante que despues de la linea que contiene el INCLUDE se añada al menos una linea vacia, puesto que de lo contrario generara un error de ensamblado. <br>
Las subrutinas SCAN y PRINT deberan tener un comportamiento no bloqueante. Es decir, estas subrutinas se limitaran a almacenar o recuperar la informacion solicitada de los bufferes internos y no esperaran en ningun caso a que termine la transmision de los caracteres o a que 
se reciban nuevos caracteres. <br><br>
La forma de acceder a los bufferes internos y variables compartidas entre la RTI y SCAN y PRINT debe asegurar la integridad de los datos manejados por las subrutinas, es decir,
que ningun caracter es leido dos veces y que no se pierde ninguno. Esto exige realizar un estudio de concurrencia entre la RTI y el resto de subrutinas que se pueden ejecutar de forma concurrente, teniendo en cuenta 
que informacion modifica cada subrutina y en que momento lo hace.<br><br>
Las subrutinas anteriores se depuraran y probaran escribiendo una serie de programas principales que llamen a estas subrutinas con un conjunto de parametros distintos. Este
juego de ensayo debe asegurar el funcionamiento correcto de la RTI, SCAN y PRINT.
## Descripcion de las Subrutinas
Todas las subrutinas, excepto INI_BUFS, LEECAR y ESCCAR reciben los parametros en la pila y el valor de retorno, si lo tiene, se devuelve en el registro D0. En la figura 5.1 se muestra
la relacion entre las subrutinas de la practica, excluyendo INI_BUFS, LEECAR y ESCCAR que se utilizaran para que SCAN, PRINT y RTI realicen el acceso a los bufferes internos de 2000 bytes
de las lineas serie. <br><br>
### INI_BUFS ( )
<pre>
<em>Parametros:</em>
No tiene.<br>
<em>Descripcion:</em>  <br>
La rutina INI BUFS realiza la inicializacion de los cuatro bufferes internos y, despues de la ejecucion, los cuatro estaran vacios. 
Esta subrutina se llamara una sola vez desde INIT.<br>
</pre>
### LEECAR (Buffer)
<pre>
<em>Parametros:</em>
<ul>
<li><strong>Buffer:</strong> 4 bytes. Es un descriptor que indica de que buffer interno se desea extraer elcaracter. Se pasa por valor 
en el registro D0. Es un parametro de entrada/salida. Tiene dos bits significativos: </li>
<ul>
• Bit 0: Selecciona la linea de transmision. Un 0 indica que se desea acceder a un buffer asociado a la linea A y un 1 a la 
  linea B.
• Bit 1: Selecciona el tipo de buffer. Un 0 indica que se desea acceder al buffer de recepcion y un 1 al de transmision.
• El resto de bits no seran tenidos en cuenta.
</ul>
<li><strong>Caracter:</strong> 1 byte. Es el caracter que se desea añadir al buffer interno como ultimo caracter. Se pasa por valor 
en los 8 bits menos significativos del registro D1. Es un parametro de entrada.</li>
</ul>
<em>Descripcion:</em> <br>
La rutina LEECAR realiza la extraccion de un caracter del buffer interno que se selecciona en el parametro. Si el buffer interno esta 
vacio, la funcion devolvera el valor 0xFFFFFFFF y no modificara el buffer. Si el buffer interno contiene caracteres, la funcion extraera 
el primer caracter del buffer almacenandolo en el registro D0 y lo “eliminara”. Los posibles valores de los dos bits menos significativos
del parametro de entrada son:
<ul>
<strong>0:</strong> indica que se desea acceder al buffer interno de recepcion de la linea A.
<strong>1:</strong> indica que se desea acceder al buffer interno de recepcion de la linea B.
<strong>2:</strong> indica que se desea acceder al buffer interno de transmision de la linea A.
<strong>3:</strong> indica que se desea acceder al buffer interno de transmision de la linea B.
</ul>
Se supondra que el programa que invoca a esta subrutina no deja ningun valor representativo en los registros del computador salvo el
puntero de marco de pila (A6) y en el parametro D0. <br>
<em>Resultado:</em>
<ul>
<li>D0: 4 bytes. Se devuelve un codigo que indica el resultado de la operacion:
• D0 = 0xFFFFFFFF si no hay ningun caracter disponible en el buffer interno
seleccionado.
• D0 es un numero entre 0 y 255. Indicara el caracter que se ha extraido del
buffer interno seleccionado.
</li>
</ul>
</pre>
### ESCCAR (Buffer,Caracter)
<em>Parametros:</em>
Buffer: 4 bytes. Es un descriptor que indica de que buffer interno se desea obtener el
primer caracter. Se pasa por valor en el registro D0. Es un parametro de entrada/salida.
Tiene dos bits significativos:
• Bit 0: Selecciona la linea de transmision. Un 0 indica que se desea acceder a un
buffer asociado a la linea A y un 1 a la linea B.
• Bit 1: Selecciona el tipo de buffer. Un 0 indica que se desea acceder al buffer de
recepcion y un 1 al de transmision.
• El resto de bits no seran tenidos en cuenta.
Caracter: 1 byte. Es el caracter que se desea añadir al buffer interno como ultimo
caracter. Se pasa por valor en los 8 bits menos significativos del registro D1. Es un
parametro de entrada.
<em>Descripcion:</em>
La rutina ESCCAR realiza la insercion de un caracter del buffer interno que se selecciona
en el parametro. Si el buffer interno esta lleno, la funcion devolvera el valor 0xFFFFFFFF y
no modificara el buffer. Si el buffer no esta lleno, la funcion insertara el caracter contenido en
D1 como ultimo caracter del buffer. Los posibles valores de los dos bits menos significativos
de D0 son:
0: indica que se desea acceder al buffer interno de recepcion de la linea A.
1: indica que se desea acceder al buffer interno de recepcion de la linea B.
2: indica que se desea acceder al buffer interno de transmision de la linea A.
3: indica que se desea acceder al buffer interno de transmision de la linea B.5. Enunciado del proyecto: E/S mediante interrupciones 61
Se supondra que el programa que invoca a esta subrutina no deja ningun valor representativo en los registros del computador salvo el puntero de marco de pila (A6) y en los
parametros D0 y D1.
Resultado:
D0: 4 bytes. Se devuelve un codigo que indica el resultado de la operacion:
• D0 = 0xFFFFFFFF si el buffer interno seleccionado esta lleno.
• D0 = 0 indicara que el caracter se ha insertado en el buffer interno correctamente.62 Proyecto de Entrada–Salida (2023–2024)
### INIT ( )
<em>Parametros:</em>
No tiene.
Resultado:
Las lineas A y B deben quedar preparadas para la recepcion y transmision de caracteres
mediante E/S por interrupciones. Al finalizar la ejecucion de la instruccion RTS, el puntero
de pila (SP) debe apuntar a la misma direccion a la que apuntaba antes de ejecutar la
instruccion BSR. Debido a la particular configuracion del emulador, esta subrutina no puede
devolver ningun error y, por tanto, no se devuelve ningun valor de retorno. Se supondra que
el programa que invoca a esta subrutina no deja ningun valor representativo en los registros
del computador salvo el puntero de marco de pila (A6).
<em>Descripcion:</em>
La rutina INIT realiza la inicializacion de las dos lineas disponibles en la DUART MC68681.
Los parametros de inicializacion de esta subrutina son los siguientes:
8 bits por caracter para ambas lineas.
No activar el eco en ninguna de las lineas.
Se debe solicitar una interrupcion cada vez que llegue un caracter.
La velocidad de recepcion y transmision sera de 38400 bits/s en ambas lineas.
Funcionamiento Full Duplex: deben estar habilitadas la recepcion y la transmision simultaneamente.
Establecer el vector de interrupcion 40 (hexadecimal).
Habilitar las interrupciones de recepcion de las lineas correspondientes en la mascara
de interrupcion. Las interrupciones de transmision solo se activaran cuando el buffer de
transmision de la linea correspondiente contenga algun caracter.
Actualizar la direccion de la rutina de tratamiento de interrupcion en la tabla de vectores
de interrupcion.
Inicializar los bufferes internos de 2000 bytes de las subrutinas indicadas anteriormente
mediante una llamada a INI BUFS.
Nota: se recuerda que el registro de mascara de interrupcion (IMR) de la DUART MC68681
no se puede leer. Si la logica del programa necesitase conocer su contenido, se podria
mantener una copia en memoria de las escrituras sobre dicho registro.5. Enunciado del proyecto: E/S mediante interrupciones 63
### SCAN (Buffer, Descriptor, Tama~no)
<em>Parametros:</em>
Buffer: 4 bytes. Es el buffer en el que se van a devolver los caracteres que se han leido
del dispositivo. Se pasa por direccion. Es un parametro de salida.
Descriptor: 2 bytes. Es un numero entero. Es un parametro de entrada. Indica el
dispositivo sobre el que se desea realizar la operacion de lectura:
• 0 indica que la lectura se realizara de la linea A.
• 1 indica que la lectura se realizara de la linea B.
• Cualquier otro valor provocara que la subrutina devuelva un error.
Tamaño: 2 bytes. Es un numero entero sin signo. Es un parametro de entrada. Indica
el numero maximo de caracteres que se deben leer del buffer interno y copiar en el
parametro Buffer.
Resultado:
D0: 4 bytes. Se devuelve un codigo que indica el resultado de la operacion:
• D0 = 0xFFFFFFFF si existe algun error en los parametros pasados.
• D0 es un numero positivo. Indicara el numero de caracteres que se han leido
y se han copiado a partir de la posicion de memoria indicada por el parametro
Buffer.
<em>Descripcion:</em>
La rutina SCAN realiza la lectura de un bloque de caracteres de la linea correspondiente
(A o B).
La lectura se debera realizar de forma no bloqueante, es decir, la subrutina se limitara a
copiar en el parametro Buffer los Tama~no primeros caracteres almacenados en el buffer interno
correspondiente y “eliminarlos” de dicho buffer interno utilizando la funcion LEECAR. Si el
buffer interno contiene menos de Tama~no caracteres, los copiara en el parametro Buffer y el
buffer interno pasara a estar vacio. En D0 se almacenara el numero de caracteres que se han
copiado en Buffer.
Ademas se debera tener en cuenta lo siguiente:
El comportamiento no bloqueante es resultado de gestionar las lineas serie mediante E/S
por interrupciones. Para ello la subrutina SCAN dispondra de sendos bufferes internos de
2000 bytes (a los que tiene acceso dicha subrutina a traves de las subrutinas auxiliares)
que contendran los caracteres leidos de las lineas y no consumidos por ninguna llamada
a SCAN. En particular esta subrutina debe asegurar que ningun caracter es leido dos
veces y que no se pierde ninguno (vease la figura 5.1).
En ningun caso esta subrutina debe esperar a que lleguen nuevos caracteres del dispositivo.
Se copiaran a lo sumo tantos bytes como indique el parametro Tama~no.64 Proyecto de Entrada–Salida (2023–2024)
Esta subrutina debera dejar el dispositivo preparado para realizar lecturas posteriores y,
al igual que la subrutina de inicializacion, debe dejar el puntero de pila (SP) apuntando a la
misma posicion de memoria a la que apuntaba antes de realizar la llamada a subrutina.
Se supondra que el programa que invoca a esta subrutina habra reservado espacio suficiente en el buffer que se pasa como parametro (Buffer) y no deja ningun valor representativo
en los registros del computador salvo el puntero de marco de pila (A6).
### PRINT (Buffer, Descriptor, Tama~no)
<em>Parametros:</em>
Buffer: 4 bytes. Es el buffer en el que se pasa el conjunto de caracteres que se desea
escribir en el dispositivo. Se pasa por direccion. Es un parametro de entrada.
Descriptor: 2 bytes. Es un numero entero. Es un parametro de entrada. Indica el
dispositivo sobre el que se desea realizar la operacion de escritura:
• 0 indica que la escritura se realizara de la linea A.
• 1 indica que la escritura se realizara de la linea B.
• Cualquier otro valor provocara que la subrutina devuelva un error.
Tamaño: 2 bytes. Es un numero entero sin signo. Es un parametro de entrada. Indica
el numero de caracteres que se deben leer del parametro Buffer y escribir en el puerto.
Resultado:
D0: 4 bytes. Se devuelve un codigo que indica el resultado de la operacion:
• D0 = 0xFFFFFFFF si existe algun error en los parametros pasados.
• D0 es un numero positivo. Indicara el numero de caracteres que se han aceptado para su escritura en el dispositivo.
<em>Descripcion:</em>
La rutina PRINT realiza la escritura en el correspondiente buffer interno de tantos caracteres como indique el parametro Tama~no contenidos en el buffer que se pasa como parametro.
La escritura se debera realizar de forma no bloqueante, es decir, la subrutina finalizara inmediatamente despues de copiar los caracteres pasados en el parametro Buffer al
buffer interno y, si como resultado de dicha copia hay caracteres en el buffer interno, activar
la transmision de caracteres por la linea. La copia de los caracteres se realizara invocando a
la funcion ESCCAR.
Ademas se debera tener en cuenta lo siguiente:
Al igual que en la subrutina SCAN el comportamiento no bloqueante es resultado de
gestionar la linea serie mediante E/S por interrupciones. Esto indica que el MC68681
generara una interrupcion cuando alguna de las lineas este preparada para transmitir y,
por tanto, la rutina de tratamiento de interrupcion sera la encargada de ir transmitiendo
los caracteres por la linea correspondiente (vease la figura 5.1). Para permitir este
comportamiento, la subrutina PRINT dispondra de sendos bufferes internos de 2000
bytes (a los que tiene acceso a traves de las subrutinas auxiliares) que contendra los
caracteres pendientes de ser enviados por las lineas.5. Enunciado del proyecto: E/S mediante interrupciones 65
Una llamada a PRINT para una de las lineas se limitara a copiar del parametro Buffer los
datos que se desean escribir al buffer interno correspondiente y “encolarlos” al conjunto
de caracteres que estan pendientes de transmitirse. En el caso de que los caracteres que
se desean transmitir no quepan en su totalidad en el buffer interno, se “encolaran” los
que quepan y se devolvera el numero de caracteres copiados en D0. Si se ha copiado
algun caracter en el buffer, se activara la transmision de caracteres por la linea.
En ningun caso esta subrutina debe esperar a que finalice la transmision de caracteres
del dispositivo.
La DUART solicitara interrupciones cada vez que la linea correspondiente este lista
para transmitir si se han activado en el registro de mascara de interrupciones (IMR).
Esta subrutina debera dejar el dispositivo preparado para realizar escrituras posteriores
y, al igual que las otras subrutinas, debe dejar el puntero de pila (SP) apuntando a la misma
posicion de memoria a la que apuntaba antes de realizar la llamada a subrutina.
Se supondra que el programa que invoca a esta subrutina habra reservado espacio suficiente en el buffer que se pasa como parametro (Buffer) y no deja ningun valor representativo
en los registros del computador salvo el puntero de marco de pila (A6).
RTI
<em>Descripcion:</em>
La invocacion de la rutina de tratamiento de interrupcion es el resultado de la ejecucion
de la secuencia de reconocimiento de interrupciones expuesta en la pagina 8. Entre otras
acciones esta subrutina debe realizar las siguientes acciones:
Identificacion de la fuente de interrupcion. Puesto que el MC68681 activa una
misma señal de interrupcion para las cuatro condiciones posibles, esta subrutina debe
identificar cual de las cuatro posibles condiciones ha generado la solicitud de interrupcion.
Tratamiento de la interrupcion. Una vez identificada la fuente, se debe realizar el
tratamiento de la interrupcion.
• Si la interrupcion es de “recepcion” indica que la cola FIFO de recepcion de la
linea no esta vacia (vease la pagina 38). En este caso se debe añadir el caracter
que se recibio por la linea al buffer interno correspondiente utilizando la funcion
ESCCAR.
• Si la interrupcion es de “transmision” indica que la linea esta preparada para
transmitir un caracter. En este caso si quedan caracteres en el buffer interno de
transmision, se debe obtener el primer caracter del buffer interno, “eliminarlo”
invocando a la funcion LEECAR y transmitirlo por la linea.
Situaciones “especiales”. Hay situaciones en las que el tratamiento de la interrupcion
no se puede asociar al tratamiento general:66 Proyecto de Entrada–Salida (2023–2024)
• Si la interrupcion es de “recepcion” y el buffer interno esta lleno, (la llamada a
la funcion ESCCAR ha devuelto 0xFFFFFFFF) no se puede añadir el caracter que
se recibe por la linea, pero se debe leer el caracter del buffer de recepcion del
MC68681 para desactivar la peticion de interrupcion. En este caso el caracter no
se añade al buffer interno (se “tira”).
• Si la interrupcion es de “transmision” y el buffer interno de la linea esta vacio
(la llamada a la funcion LEECAR ha devuelto 0xFFFFFFFF) se deben deshabilitar
las interrupciones de transmision para la linea que ha interrumpido en el registro
IMR del MC68681. Si no se realizara esta operacion el dispositivo no desactivaria
la señal de interrupcion puesto que seguiria estando preparado para transmitir.
Nota: como complemento a la descripcion de estas subrutinas, en la seccion Ejemplos se
proporcionan distintos casos de uso.
