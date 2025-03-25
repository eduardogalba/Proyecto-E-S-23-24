# Sistema de Comunicación Serie con DUART MC68681
## 📌 Resumen del Proyecto
Este proyecto implementa un sistema de comunicación serie mediante interrupciones utilizando la DUART MC68681. El objetivo principal es gestionar la entrada y salida de datos de forma eficiente y no bloqueante en dos líneas serie (A y B), permitiendo la transmisión y recepción de caracteres de manera asíncrona.

## 🛠️ Funcionalidades Principales
- Configuración inicial: Inicialización de la DUART y preparación de las líneas serie.
- Lectura no bloqueante: Obtención de datos recibidos sin esperar a que lleguen nuevos caracteres.
- Escritura no bloqueante: Envío de datos sin bloquear la ejecución del programa principal.
- Gestión de interrupciones: Manejo eficiente de las interrupciones generadas por la DUART para optimizar el flujo de datos.
  
## 📂 Estructura del Código
El proyecto se compone de las siguientes subrutinas clave:

###  1. `INIT`
- Configurar los parámetros de las líneas A y B (velocidad: 38400 bps, 8 bits por carácter, sin eco).
- Habilitar las interrupciones para recepción y transmisión.
- Inicializar los buffers internos para almacenar datos.
  
### 2. `SCAN`
- Lee un bloque de caracteres desde el buffer interno de una línea específica (A o B).
- Devuelve el número de caracteres leídos o un código de error si los parámetros son inválidos.
- **No bloqueante**: Si no hay datos disponibles, retorna inmediatamente.

### 3. `PRINT`
- Escribe un bloque de caracteres en el buffer interno de una línea específica (A o B).
- Activa la transmisión si hay datos pendientes.
- **No bloqueante**: No espera a que se complete el envío.

### 4. `Rutina de Interrupción (RTI)`
- Detecta si la interrupción proviene de recepción o transmisión.
- Transfiere caracteres entre los buffers internos y la DUART.
- Maneja casos especiales (ej.: buffer lleno o vacío).
  
## ⚙️ Ejemplo de Uso
### Inicialización del sistema
```asm
BSR INIT  ; Configura la DUART y los buffers
```
### Lectura de datos desde la línea A
```asm
MOVE.L #buffer_destino, -(SP)  ; Dirección donde se guardarán los datos  
MOVE.W #0, -(SP)               ; 0 = línea A  
MOVE.W #10, -(SP)              ; Máximo 10 caracteres a leer  
BSR SCAN                       ; Llama a la subrutina de lectura
```
### Escritura de datos en la línea B
```asm
MOVE.L #buffer_origen, -(SP)   ; Dirección de los datos a enviar  
MOVE.W #1, -(SP)               ; 1 = línea B  
MOVE.W #5, -(SP)               ; 5 caracteres a escribir  
BSR PRINT                      ; Llama a la subrutina de escritura
```
## 📌 Consideraciones Importantes
- Concurrencia: Las subrutinas deben garantizar que no se pierdan datos ni se lean caracteres duplicados.
- Eficiencia: El sistema está diseñado para minimizar el tiempo de espera en operaciones de E/S.
- Modularidad: El código está organizado para facilitar su mantenimiento y extensión.

## 🚀 Cómo Empezar
- Ensamblado: Incluye el archivo bib_aux.s en tu proyecto.
- Ejecución: Prueba las subrutinas con diferentes casos de uso para verificar su correcto funcionamiento.
- Personalización: Ajusta los parámetros de la DUART según tus necesidades.
