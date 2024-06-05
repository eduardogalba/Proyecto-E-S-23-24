BUFFER: 	DS.B	2100 		* Buffer para lectura y escritura de caracteres
PARDIR: 	DC.L	0 		* Direcci´on que se pasa como par´ametro
PARTAM: 	DC.W	0 		* Tama~no que se pasa como par´ametro
CONTC: 		DC.W	0 		* Contador de caracteres a imprimir
DESA: 		EQU 	0 		* Descriptor l´ınea A
DESB: 		EQU 	1 		* Descriptor l´ınea B
TAMBS: 		EQU 	30 		* Tama~no de bloque para SCAN
TAMBP: 		EQU 	7 		* Tama~no de bloque para PRINT
	


	* PROGRAMA PRUEBA ENUNCIADO PAG 75
	
MAIN:			MOVE.L #BUS_ERROR,8 		*Install bus error handler
			MOVE.L #ADDRESS_ER,12 		*Install address error handler
			MOVE.L #ILLEGAL_IN,16 		*Install illegal instruction handler
			MOVE.L #PRIV_VIOLT,32 		*Install privilege violation handler
			MOVE.L #ILLEGAL_IN,40 		*Install illegal instruction handler
			MOVE.L #ILLEGAL_IN,44 		*Install illegal instruction handler
		
			BSR INIT
			MOVE.W #$2000,SR 		* Permite interrupciones
	
BUCPR: 			MOVE.W #TAMBS,PARTAM 		* Inicializa par´ametro de tama~no
			MOVE.L #BUFFER,PARDIR 		* Par´ametro BUFFER = comienzo del buffer
	
OTRAL: 			MOVE.W PARTAM,-(A7) 		* Tama~no de bloque
			MOVE.W #DESA,-(A7) 		* Puerto A
			MOVE.L PARDIR,-(A7) 		* Direcci´on de lectura

ESPL: 			BSR SCAN
			ADD.L #8,A7 			* Restablece la pila

			ADD.L D0,PARDIR 		* Calcula la nueva direcci´on de lectura
			SUB.W D0,PARTAM 		* Actualiza el n´umero de caracteres le´ıdos
			BNE OTRAL 			* Si no se han le´ıdo todas los caracteres
							* del bloque se vuelve a leer
			MOVE.W #TAMBS,CONTC		* Inicializa contador de caracteres a imprimir
			MOVE.L #BUFFER,PARDIR 		* Par´ametro BUFFER = comienzo del buffer
	
OTRAE: 			MOVE.W #TAMBP,PARTAM 		* Tama~no de escritura = Tama~no de bloque
	
ESPE: 			MOVE.W PARTAM,-(A7) 		* Tama~no de escritura
			MOVE.W #DESB,-(A7) 		* Puerto B
			MOVE.L PARDIR,-(A7) 		* Direcci´on de escritura

			BSR PRINT
			ADD.L #8,A7 			* Restablece la pila

			ADD.L D0,PARDIR 		* Calcula la nueva direcci´on del buffer
			SUB.W D0,CONTC 			* Actualiza el contador de caracteres
			BEQ SALIR 			* Si no quedan caracteres se acaba

			SUB.W D0,PARTAM 		* Actualiza el tama~no de escritura
			BNE ESPE 			* Si no se ha escrito todo el bloque se insiste
			CMP.W #TAMBP,CONTC 		* Si el no de caracteres que quedan es menor que
							* el tama~no establecido se imprime ese n´umero
			BHI OTRAE 		* Siguiente bloque
			MOVE.W CONTC,PARTAM
			BRA ESPE 			*Siguiente bloque

SALIR:			BRA BUCPR

BUS_ERROR:	 	BREAK
			NOP

ADDRESS_ER:		BREAK
			NOP

ILLEGAL_IN:		BREAK
			NOP

PRIV_VIOLT:		BREAK
			NOP
