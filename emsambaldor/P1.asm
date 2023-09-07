;====================================== MACROS =======================================
imprimir_mensaje macro mensaje
	MOV AH,09H
	LEA DX,[mensaje]
	INT 21H
endm

imprimir_mensaje_hora macro mensaje
	MOV CX,3D
	MOV BX,0D
	MOV AH,02H

loop_i0:
	MOV DL,[mensaje + BX]
	INT 21H
	INC BX
	LOOP loop_i0

	MOV CX,2D
loop_i:
	MOV DL,[mensaje + BX]
	ADD DL,30H
	INT 21H
	INC BX
	LOOP loop_i

	MOV DL,[mensaje + BX]
	INT 21H
	INC BX
	MOV CX,2D
	CMP BX,0CH
	JZ  imprimir_resto
	JMP loop_i

imprimir_resto:
	MOV CX,4D

loop_i2:
	MOV DL,[mensaje + BX]
	INT 21H
	INC BX
	LOOP loop_i2

endm

separar_digitos macro HORA, TIME_D
	MOV CX,3D
	MOV BX,0D 		;iterar arreglo de 3 posiciones
	MOV DI,0D 		;iterar arreglo de 6 posiciones
	MOV DL,16D

loop_s:
	XOR AX,AX
	MOV AL,[HORA + BX]
	DIV DL
	MOV [TIME_D + DI],AL
	MOV [TIME_D + DI + 1],AH
	INC BX
	ADD DI,2D
	LOOP loop_s
endm

guardar_digitos macro TIME_D, MSG
	MOV CX,2D
	MOV BX,0
	MOV DI,0D

loop_g:
	MOV AL,[TIME_D + DI]
	MOV [DS:003Eh + BX],AL
	INC BX
	INC DI
	LOOP loop_g
	MOV CX,2D
	INC BX
	CMP DI,6
	JZ imp_h
	JMP loop_g 

imp_h:
	imprimir_mensaje_hora MSG
	JMP revisar_teclado

endm


aumentar_milis macro TICK, MILISEGUNDOS, SEGUNDOS, MINUTOS
	CALL limpiar_buffer

comprueba_tick:
	MOV BX, 0375H
	CALL guardar_ticks
	CMP [TICK], CX
	JNZ actualiza_tick
	CMP [TICK + 2], DX
	JNZ actualiza_tick

;lA ÑERA PARA QUE NO VAYA TAN RAPIDO
perder_tiempo:
	DEC BX
	CMP BX, 0000H
	JNZ perder_tiempo

	INC MILISEGUNDOS
	CMP MILISEGUNDOS,3E8H
	JZ aumentar_segundo
	imprimir_cronometro MILISEGUNDOS, SEGUNDOS, MINUTOS
	JMP comprueba_tick

actualiza_tick:
	MOV [TICK],CX
	MOV [TICK + 2],DX
	CALL revisar_buffer
	JNZ  revisar_tecla
	JMP comprueba_tick

aumentar_segundo:
	SUB MILISEGUNDOS,3E8H
	INC SEGUNDOS
	CMP SEGUNDOS,3CH
	JZ 	aumentar_minutos
	JMP comprueba_tick

aumentar_minutos:
	SUB SEGUNDOS,3CH
	INC MINUTOS
	CMP MINUTOS,3CH
	JZ limpiar_crono
	JMP comprueba_tick

limpiar_crono:
	SUB MILISEGUNDOS,3E8H
	SUB SEGUNDOS,3CH
	SUB MINUTOS,3CH
	JMP comprueba_tick	
endm

reinic_cronometro macro MILISEGUNDOS, SEGUNDOS, MINUTOS
	MOV MILISEGUNDOS,0D
	MOV SEGUNDOS,0D
	MOV MINUTOS,0D
endm

imprimir_cronometro macro MILISEGUNDOS,SEGUNDOS,MINUTOS
	MOV AH,02H
	MOV DL,09H
	INT 21H

	MOV DL,09H
	INT 21H

	MOV DL,09H
	INT 21H

	XOR AX,AX
	MOV AL,MINUTOS
	AAM
	MOV BX, AX

	MOV AH,02H
	MOV DL,BH
	ADD DL,30H
	INT 21H

	MOV DL,BL
	ADD DL,30H
	INT 21H

	MOV DL,3AH
	INT 21H

	XOR AX,AX
	MOV AL,SEGUNDOS
	AAM
	MOV BX, AX

	MOV AH,02H
	MOV DL,BH
	ADD DL,30H
	INT 21H

	MOV DL,BL
	ADD DL,30H
	INT 21H

	MOV DL,2EH
	INT 21H	

	MOV CX,10D
	MOV AX, MILISEGUNDOS
	DIV CL
	MOV BL, AH
	XOR AH,AH
	DIV CL
	MOV BH, AH
	MOV DL, AL

	MOV AH,02H
	ADD DL,30H
	INT 21H

	MOV DL, BH
	ADD DL,30H
	INT 21H

	MOV DL, BL
	ADD DL,30H
	INT 21H

	MOV DL,0DH
	INT 21H

	;MOV DL,24H
	;INT 21H
endm
;====================================================================================================


title "Proyecto 1. Johan Axel Zarazua Ramirez" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386		;directiva para indicar version del procesador
	.stack 64 	;Define el tamaño del segmento de stack, se mide en bytes


;============================== DEFINICION DE VARIABLES =============================================
	.data
;Reloj
MSG_R    DB  'Reloj.',0AH,20H,20H,20H,20H,'(Presione cualquier tecla para volver al menu)',0AH,'$'
MSG_HORA DB  09H,09H,09H,'00:00:00 hrs',0DH,'$'		
MENU     DB  'Proyecto 1',0AH,0AH,20H,20H,'Seleccione una opcion presionando la tecla correspondiente:',0AH,'$'
OP_RELOJ DB  09H,'[R] Reloj',0AH,'$'
OP_CRONO DB  09H,'[C] Cron',0A2H,'metro',0AH,'$'
OP_SALIR DB  09H,'[S] Salir',0AH,09H,'$'
TIME     DB  0,0,0,0,0,0
HORA     DB	 0,0,0
;fin reloj

;Cronometro
MSG_C    DB  'Cronometro.',0AH,20H,20H,'[I] Iniciar/Continuar',09H,20H,20H,'[D] Detener',09H,'[R] Reinciar',0AH,20H,20H,'(Presione cualquier otra tecla para volver al menu)',0AH,'$'
MILI	 DW  0D
SEGU     DB  0D
MINU     DB  0D
TICK   	 DW  0,0

;fin cronometro

;====================================================================================================

;====================================== CODIGO ======================================================
	.code

;================================= PROCEDIMIENTOS ===================================================
limpiar_pantalla proc
	;CODIGO TOMADO DE https://lgomezitm.blogspot.com/2018/02/cambio-de-color-en-las-pantallas-con-el.html
    MOV AH,06H		;ah 06(es un recorrido)
    MOV BH,70H		;fondo blanco(7), letra negra(0)
    MOV CX,0000H	;es la esquina superior izquierda reglon: columna
    MOV DX,184FH	;es la esquina inferior derecha reglon: columna
    INT 10H			;interrupcion que llama al BIOS
       
    MOV AH,02H    	;peticion para colocar cursor
    MOV BH,0000H    ;numero pagina o pantalla
    MOV DX,0119H 	;dh fila, dl columna
    INT 10H 		;interrupcion que llama a BIOS
    RET
endp

guardar_hora proc
	MOV AH,02H
	INT 1AH
	RET
endp

leer_teclado proc
	MOV AH, 01H
	INT 21H
	RET
endp

revisar_buffer proc
	MOV AH,01H
	INT 16H
	RET
endp

limpiar_buffer proc
	MOV AX ,0C00H  ;limpia buffer
  	INT 21H
  	RET
endp

guardar_ticks proc
	MOV AH,00H
	INT 1AH
	; ticjs almacenados en cx y dx 
	RET
endp
;====================================================================================================

inicio:					
	MOV AX,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	MOV DS,AX			;DS = AX, inicializa segmento de datos

imprimir_menu: 
	CALL limpiar_buffer
	CALL limpiar_pantalla
	imprimir_mensaje MENU
	imprimir_mensaje OP_RELOJ
	imprimir_mensaje OP_CRONO
	imprimir_mensaje OP_SALIR

leer_opcion:
	CALL leer_teclado

	CMP AL,'R'
	JE reloj
	CMP AL,'r'
	JE reloj

	CMP AL,'C'
	JE cronometro
	CMP AL,'c'
	JE cronometro

	CMP AL,'S'
	JE salir
	CMP AL,'s'
	JE salir

	JMP imprimir_menu

reloj:
	CALL limpiar_pantalla
	imprimir_mensaje MSG_R

mostrar_hora:
	CALL guardar_hora

	MOV [HORA],CH 		;hora
	MOV [HORA+1],CL 	;minutos
	MOV [HORA+2],DH 	;segundos

	separar_digitos HORA,TIME
	guardar_digitos TIME, MSG_HORA

revisar_teclado:
	CALL revisar_buffer
	JNZ imprimir_menu
	JMP mostrar_hora


cronometro:
	CALL limpiar_pantalla
	imprimir_mensaje MSG_C
cronometro_letra:
	CALL revisar_buffer
	JNZ  revisar_tecla
	JMP cronometro_letra

revisar_tecla:
	CMP AL,'I'
	JE iniciar_crono
	CMP AL,'i'
	JE iniciar_crono

	CMP AL,'D'
	JE detener_crono
	CMP AL,'d'
	JE detener_crono

	CMP AL,'R'
	JE reiniciar_crono
	CMP AL,'r'
	JE reiniciar_crono

	JMP imprimir_menu

iniciar_crono:
	aumentar_milis TICK, MILI, SEGU, MINU

detener_crono:
	imprimir_cronometro MILI, SEGU, MINU
	CALL limpiar_buffer
det_crono:
	CALL revisar_buffer
	JNZ  revisar_tecla
	JMP det_crono

reiniciar_crono:
	reinic_cronometro MILI, SEGU, MINU
	imprimir_cronometro MILI, SEGU, MINU
	CALL limpiar_buffer
rein_crono:
	CALL revisar_buffer
	JNZ  revisar_tecla
	JMP rein_crono


;====================================================================================================

;====================== FIN =========================================================
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa

