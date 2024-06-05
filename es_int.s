	* PRACTICA E/S POR INTERRUPCIONES POR EDUARDO GIL ALBA (170238)
	
		ORG 0
		DC.L $8000				* SP <- 8000
		DC.L MAIN				* PC <- MAIN
		

		ORG 400
	* Declaraciones Equivalencias
	
MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2º escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
ACR	EQU	$effc09	      * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion (lectura)
MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2º escritura)
CRB     EQU     $effc15	      * de control A (escritura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
RBB	EQU	$effc17       * buffer recepcion B (lectura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB	EQU	$effc13       * de seleccion de reloj B (escritura)
IVR 	EQU 	$effc19	      * vector de interrupcion
	
	 
	* Arranca el programa principal
	
IMR_COPY		DS.B 1

SR_COPY			DS.W 1	

* INCLUDE prueba_pag75.s	
MAIN:	
	
**************************** INIT *********************************************************

INIT: 		* 8b/caracter y RxRDY(solicitar INT cada vez que llegue un caracter)
			MOVE.B #%00000011,MR1A			* 0| 0 |0|00|0|11|
			MOVE.B #%00000011,MR1B			* X|Rdy|X|XX|X|8b|
		* No eco
			MOVE.B #%00000000,MR1A			* MR2A = 0
			MOVE.B #%00000000,MR1B			* MR2B = 0

		* Ajustar la velocidad de transmision/recepcion
			MOVE.B #%00000000,ACR			* Elegir el conjunto 1
			MOVE.B #%11001100,CSRA			* Ajustar la velocidad linea A
			MOVE.B #%11001100,CSRB			* Ajustar la velocidad linea B

		* Full Duplex
			MOVE.B #%00000101,CRA			* 0|000|01|01|
			MOVE.B #%00000101,CRB			       |Tx|Rx|

		* Establecer el vector de interrupcion
			MOVE.B #$40,IVR

		* Habilitar INT recepcion e inhibir las de transmision hasta que contenga un caracter
			MOVE.B #%00100010,IMR_COPY		* 00|1|0|00|1|0 
			MOVE.B IMR_COPY,IMR

		* Actualizar RTI en TVint
			MOVE.L #RTI,$100

		* Inicializar buffer internos
			BSR INI_BUFS
	
		* Salida de subrutina
			RTS
**************************** FIN INIT *********************************************************	

**************************** SCAN *********************************************************
			
		* Creacion de marco de pila e inicializacion de registros
SCAN:			LINK A6,#-6		* 2 bytes para contar los n caracteres y 4 bytes para el puntero
			MOVE.L 8(A6),A0		* Buffer -> A0
			MOVE.W 12(A6),D1		* Descriptor -> D1
			EOR.L D0,D0
			EOR.L D3,D3		* Nº caracteres leidos

		* Protocolo de entrada (Evalua el descriptor)
			CMP.W #0,D1
			BEQ SCAN_A
			CMP.W #1,D1
			BEQ SCAN_B
			BRA SCAN_ERR

	* Linea A :
	
		* Preparamos la llamada a LEECAR
SCAN_A: 		BCLR #0,D0
			BCLR #1,D0
		* Guardamos las variables locales
			MOVE.L A0,-4(A6)
			MOVE.W D3,-6(A6)
			BSR LEECAR
		* Comprobacion del buffer si esta vacio
			CMP.L #$FFFFFFFF,D0
			BEQ F_SCAN
		* Recuperamos las variables locales
			MOVE.W -6(A6),D3
			MOVE.L -4(A6),A0
			MOVE.W 14(A6),D2		* Tamanho -> D2
		* Copia el caracter al buffer e incremento puntero y nºcaracteres leidos
			MOVE.B D0,(A0)+
			ADD.L #1,D3
		* Comprobacion de si he copiado los tamanho bytes
			CMP.L D2,D3
			BNE SCAN_A
			BRA F_SCAN

	* Linea B :
	
		* Preparamos la llamada a LEECAR
SCAN_B:			BSET #0,D0
			BCLR #1,D0
		* Guardamos las variables locales
			MOVE.L A0,-4(A6)
			MOVE.W D3,-6(A6)
			BSR LEECAR
		* Comprobacion del buffer si esta vacio
			CMP.L #$FFFFFFFF,D0
			BEQ F_SCAN
		* Recuperamos las variables locales
			MOVE.W -6(A6),D3
			MOVE.L -4(A6),A0
			MOVE.W 14(A6),D2		* Tamanho -> D2
		* Copia el caracter al buffer e incremento puntero y nºcaracteres leidos
			MOVE.B D0,(A0)+
			ADD.L #1,D3
		* Comprobacion de si he copiado los tamanho bytes
			CMP.L D2,D3
			BNE SCAN_B
			BRA F_SCAN

	* Salida de la subrutina
	
		* Salida de error
SCAN_ERR: 		MOVE.L #$FFFFFFFF,D0
			UNLK A6			* Deshacer el marco de pila
			RTS
	
		* Salida correcta
F_SCAN:			MOVE.L D3,D0
			UNLK A6			* Deshacer el marco de pila
			RTS

**************************** FIN SCAN *********************************************************

	
	
**************************** PRINT *********************************************************	

		* Creacion de marco de pila e inicializacion de registros
PRINT:			LINK A6,#-6
			MOVE.L 8(A6),A0			* Buffer -> A0
			MOVE.W 12(A6),D1		* Descriptor -> D1
			MOVE.W 14(A6),D2 		* Tamanho -> D2
			EOR.L D0,D0
			EOR.L D3,D3		* Nº caracteres leidos

		* Comprobacion del tamaño buffer
			CMP.W #0,D2
			BEQ F_PRINT
		* Protocolo de entrada (Evalua el descriptor)
			CMP.W #0,D1
			BEQ PRINT_A
			CMP.W #1,D1
			BEQ PRINT_B
			BRA PRINT_ERR


	* Linea A :
	
		* Preparamos la llamada a LEECAR
PRINT_A: 		BCLR #0,D0
			BSET #1,D0
			MOVE.B (A0)+,D1
			CMP.B #0,D1
			BEQ F_PRINT
		* Guardamos las variables locales
			MOVE.L A0,-4(A6)
			MOVE.W D3,-6(A6)
			BSR ESCCAR
		* Comprobacion del buffer si esta lleno
			CMP.L #$FFFFFFFF,D0
			BEQ F_PRINT
		* Recuperamos las variables locales
			MOVE.W -6(A6),D3
			MOVE.L -4(A6),A0
			MOVE.W 14(A6),D2		* Tamanho -> D2
		* Incremento el nºcaracteres leidos
			ADD.L #1,D3
		* Habilitar interrupciones de transmision (Exclusion Mutua)
		** Salvaguardo el registro de estado
			MOVE.W SR,SR_COPY
		** Enmascaro todas las interrupciones (DI)
			MOVE.W #$2700,SR
		** Entrada a Seccion Critica
			BSET #0,IMR_COPY
			MOVE.B IMR_COPY,IMR
		*** Salida de Seccion Critica
			MOVE.W SR_COPY,SR
		* Comprobacion de si he copiado los tamanho bytes
			CMP.L D2,D3
			BNE PRINT_A
			BRA F_PRINT


	* Linea B :
	
		* Preparamos la llamada a LEECAR
PRINT_B: 		BSET #0,D0
			BSET #1,D0
			MOVE.B (A0)+,D1
			CMP.B #0,D1
			BEQ F_PRINT
		* Guardamos las variables locales
			MOVE.L A0,-4(A6)
			MOVE.W D3,-6(A6)
			BSR ESCCAR
		* Comprobacion del buffer si esta lleno
			CMP.L #$FFFFFFFF,D0
			BEQ F_PRINT
		* Recuperamos las variables locales
			MOVE.W -6(A6),D3
			MOVE.L -4(A6),A0
			MOVE.W 14(A6),D2		* Tamanho -> D2
		* Incremento el nºcaracteres leidos
			ADD.L #1,D3
		* Habilitar interrupciones de transmision (Exclusion Mutua)
		** Salvaguardo el registro de estado
			MOVE.W SR,SR_COPY
		** Enmascaro todas las interrupciones (DI)
			MOVE.W #$2700,SR
		** Entrada a Seccion Critica
			BSET #4,IMR_COPY
			MOVE.B IMR_COPY,IMR
		*** Salida de Seccion Critica
			MOVE.W SR_COPY,SR
		* Comprobacion de si he copiado los tamanho bytes
			CMP.L D2,D3
			BNE PRINT_B
			BRA F_PRINT
	

	* Salida de la subrutina
	
		* Salida de error
PRINT_ERR: 		MOVE.L #$FFFFFFFF,D0
			UNLK A6			* Deshacer el marco de pila
			RTS
	
		* Salida correcta
F_PRINT:		MOVE.L D3,D0
			UNLK A6			* Deshacer el marco de pila
			RTS
		

**************************** FIN PRINT *********************************************************

	
**************************** RTI *********************************************************	

		* Salvo el estado actual de los registros que voy a usar
RTI:			MOVE.L D0,-(A7)		* PUSH(D0)
			MOVE.L D1,-(A7)		* PUSH(D1)
			
		* Bucle de identificacion de la fuente
B_IDEN:			MOVE.B ISR,D1
			AND.B IMR_COPY,D1
			BTST #1,D1
			BNE LIN_A_RX		* ¿RxRDYA == 1? 
			BTST #5,D1
			BNE LIN_B_RX		* ¿RxRDYB == 1?
			BTST #0,D1	
			BNE LIN_A_TX		* ¿TxRDYA == 1?
			BTST #4,D1
			BNE LIN_B_TX		* ¿TxRDYB == 1?
			BRA F_RTI
	
	* Linea A: Atender Recepion
	
		* Preparo la llamada a ESCCAR 
LIN_A_RX:		MOVE.B RBA,D1 		* D1 <- RBA
			EOR.L D0,D0		* D0 <- 00
			BSR ESCCAR
			BRA B_IDEN
	
	* Linea B: Atender Recepion
	
		* Preparo la llamada a ESCCAR 
LIN_B_RX:		MOVE.B RBB,D1 		* D1 <- RBB 
			MOVE.L #1,D0		* D0 <- 01
			BSR ESCCAR
			BRA B_IDEN

	* Linea A: Atender Transmision
	
		* Preparo la llamada a LEECAR
LIN_A_TX:		MOVE.L #2,D0		* D0 <- 10
			BSR LEECAR
			CMP.L #$FFFFFFFF,D0
			BEQ ESP_TX_A
			MOVE.B D0,TBA
			BRA B_IDEN

	* Caso Especial (linA-Tx): Buffer interno vacio

ESP_TX_A:		BCLR #0,IMR_COPY	* Inhibir TxRDYA
			MOVE.B IMR_COPY,IMR
			BRA B_IDEN

	* Linea B: Atender Transmision
	
		* Preparo la llamada a LEECAR
LIN_B_TX:		MOVE.L #3,D0		* D0 <- 11
			BSR LEECAR
			CMP.L #$FFFFFFFF,D0
			BEQ ESP_TX_B
			MOVE.B D0,TBB
			BRA B_IDEN	

	* Caso Especial (linB-Tx): Buffer interno vacio

ESP_TX_B:		BCLR #4,IMR_COPY	* Inhibir TxRDYB
			MOVE.B IMR_COPY,IMR
			BRA B_IDEN	

	* Salida de la subrutina
	
		* Antes de retornar, recupero el estado anterior de los registros
F_RTI:			MOVE.L (A7)+,D1		* POP(D1)
			MOVE.L (A7)+,D0		* POP(D0)
			RTE
**************************** FIN RTI *********************************************************
			
	
			
		


			
INCLUDE bib_aux.s
	
