;AUTORES: 
;	- Hernández Rivera David
;	- Garcia Meneses Jeremy
;	- Johan Axel Zarazua Ramirez
;GRUPO: 02
;FECHA DE ENTREGA: 	1/30/2021
;MATERIA: Estructura y programación de computadoras

title "Proyecto 2: Reloj-cronómetro 'gráfico'" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes

;=========================================== Macros ==============================================================
separar_digitos macro HORA, TIME_D  			; separa los componentes de la hora en sus digitos y los guarda en una varaible
	MOV CX,3D
	MOV BX,0D 		;iterar arreglo de 3 posiciones
	MOV DI,0D 		;iterar arreglo de 6 posiciones
	MOV DL,16D

loop_s:
	XOR AX,AX 		;limpia ax
	MOV AL,[HORA + BX] ;toma la primera posicion de la variable hora, hora en formato 24
	DIV DL 				; se divide entre DL
	MOV [TIME_D + DI],AL ; el resultadode la division (primer digito) lo mueve a la vriable time
	MOV [TIME_D + DI + 1],AH ; el residuo (segundo digito) lo mueve a la variale time
	INC BX 					; incrementa BX
	ADD DI,2D 				; suma dos a DI
	LOOP loop_s 			; bucle para repetir con minutos y segundos
endm

guardar_digitos macro TIME_D, MSG 			; mueve cada uno de los digitos de la hora a la plantilla de impresion
	MOV CX,2D
	MOV BX,0
	MOV DI,0D

loop_g:
	MOV AL,[TIME_D + DI]
	ADD AL,30H
	MOV [MSG + BX],AL
	INC BX
	INC DI
	LOOP loop_g
	MOV CX,2D
	INC BX
	CMP DI,6
	JZ salir_macro
	JMP loop_g 

salir_macro:
endm


clear macro 		;clear - Limpia pantalla
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h			;llama interrupcion 10h con opcion 00h. 
					;Establece modo de video limpiando pantalla
endm

posiciona_cursor macro renglon,columna 	;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
	mov dh,renglon						;dh = renglon
	mov dl,columna						;dl = columna
	mov bx,0
	mov ax,0200h 						;preparar ax para interrupcion, opcion 02h
	int 10h 							;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

inicializa_ds_es macro 	;inicializa_ds_es - Inicializa el valor del registro DS y ES
	mov ax,@data
	mov ds,ax
	mov es,ax 			;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

muestra_cursor_mouse macro 	;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
	mov ax,1				;opcion 0001h
	int 33h					;int 33h para manejo del mouse. Opcion AX=0001h
							;Habilita la visibilidad del cursor del mouse en el programa
endm

oculta_cursor_teclado macro  ;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
	mov ah,01h 				 ;Opcion 01h
	mov cx,2607h 			 ;Parametro necesario para ocultar cursor
	int 10h 				 ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;Habilita 16 colores de fondo
apaga_cursor_parpadeo macro ;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
	mov ax,1003h 			;Opcion 1003h
	xor bl,bl 				;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 				;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;DL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse macro loc_etiqueta
	mov ax,0003h        ;Lee la posición del raton almacenada (x(CX),y(DX)) y el estado de los botones (bx)
	int 33h
	test bx,0001h 		;Comparamos bx con 0001h sin guardar el resultado
				  		;Para revisar si el boton izquierdo del mouse fue presionado
	jz [loc_etiqueta]   ;Saltamos a la etiqueta indicada si el estado de los botones es 0 (No se a presionado ningun boton)
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

;printButton - inicializa las variables necesarias para para 
  			   ;imprimir un boton en pantalla y llama al procedimiento 
  			   ;correspondiente para imprimirlo.
printButton macro columna,renglon,color,caracter 
		mov [columna_boton],columna
		mov [renglon_boton],renglon
		mov [color_boton],color
		mov [caracter_boton],caracter
		call IMPRIME_BOTON
endm

imprime_cadena macro loc_cadena 	;para imprimir una cadena segun el nombre que se pasa como parametro
	lea dx,[loc_cadena] 			;se obtiene la localidad de memoria de la cadena y se guarda en DX
	mov ax,0900h					;opcion 9 para interrupcion 21h. Imprime una cadena apuntada por el registro DX
	int 21h							;interrupcion 21h. Imprime cadena.
endm


aumentar_milis macro TICK, MILISEGUNDOS, SEGUNDOS, MINUTOS
	
comprueba_tick:
	MOV BX, 0375H 			;variable para generar un ciclo en la etiqueta perder_tiempo
	CALL guardar_ticks      ; guarda los ticks del procesador y los pone en una varaible
	CMP [TICK], CX 			; compara los valores de la variable TICK CONTRA cx
	JNZ actualiza_tick 		; si son iguales actuaaliza los ticks
	CMP [TICK + 2], DX 		; comapra la segund aposicion de ticks con DX
	JNZ actualiza_tick 		; si son iguales actualiza las ticks

;lA ÑERA PARA QUE NO VAYA TAN RAPIDO
perder_tiempo:
	DEC BX
	CMP BX, 0000H
	JNZ perder_tiempo
;fin de la ÑERA

	INC MILISEGUNDOS 		; se incrementa en una unidad la varaible MILISEGUNDOS
	CMP MILISEGUNDOS,3E8H 	; se verifica que MILISEGUNDOS sea menor a 1000 
	JZ aumentar_segundo     ; si es 1000 pasamos a la etiqueta aumentar_segundo
	call IMPRIME_CRON       ; si es menor que 1000 solo se imprimen los valores
	
	JMP comprueba_tick      ; comprobamos los ticks

actualiza_tick:
	MOV [TICK],CX 			; se mueve el valor cx a la primera posicion de TICK
	MOV [TICK + 2],DX 		; se mueve DX a la segunda posicion de TICK

	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse
	lee_mouse boton_iniciar_2 	;si comprueba el mouse, si no fue activa brinca a boton_iniciar_2, si se dio click brincamos a posiciones
	jmp posiciones

	;JMP comprueba_tick

aumentar_segundo:    
	SUB MILISEGUNDOS,3E8H 		; se lleva a 0 los MILISEGUNDOS
	INC SEGUNDOS 				; se incrementa en una unidad los SEGUNDOS
	CMP SEGUNDOS,3CH 			; se compara si segunds es menor a 60
	JZ 	aumentar_minutos 		; si es 60 se brinca a aumentar_minutos
	JMP comprueba_tick 			; si es menor a 60 se comprueban los ticks

aumentar_minutos:
	SUB SEGUNDOS,3CH 			; se lleva a 0 los SEGUNDOS
	INC MINUTOS 				; se incrementa en una unidad los MINUTOS
	CMP MINUTOS,3CH				; se comprueba que los minutos sean menores a 60
	JZ limpiar_crono            ; si son 60 se lleva todo a 0
	JMP comprueba_tick 			; se comprueban los ticks

limpiar_crono:
	SUB MILISEGUNDOS,3E8H 		; se lleva a 0 los MILISEGUNDOS
	SUB SEGUNDOS,3CH 			; se lleva a 0 los SEGUNDOS
	SUB MINUTOS,3CH 			; se lleva a 0 los MINUTOS
	JMP comprueba_tick	 		; se comprueban los ticks
endm

imprimir_cronometro macro MILISEGUNDOS,SEGUNDOS,MINUTOS  				; macro para imprimir el cronometro
	MOV AH,02H
	
	XOR AX,AX
	MOV AL,MINUTOS 		;se ponen los minutos en AL
	AAM 				; se dividen sus digitos
	MOV BX, AX 			; se mueve el priemr digito a BX

	MOV AH,02H 			; prpearamos la opcionde la interrupcion
	MOV DL,BH 			; se mueve el valor a imprimir a DL
	ADD DL,30H 			; se suma 30 a DL para tener el valor del numero en ascci
	INT 21H 			; interrupcion 21h para imprimirlo

	MOV DL,BL 			; se mueve el segundo digito de los minutos a DL
	ADD DL,30H 			; se suma 30 DL para obteneer el numero en ascci
	INT 21H 			; interrupcion 21h para imprimirlo

	MOV DL,3AH 			; imprime un ":"	
	INT 21H

	XOR AX,AX 			; limpiamos AX y se repite el proceso anterior pero utilizando los segundos
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

	MOV DL,2EH 			; imprime un "."
	INT 21H	

	MOV CX,10D 			; los MILISEGUNDOS tienen 3 digitos por lo cual hay que hacer dos divisiones, por lo cual usamos CX con el valor de 10d
	MOV AX, MILISEGUNDOS 	;movemos a AX los MILISEGUNDOS
	DIV CL 					;dividimos entre 10
	MOV BL, AH 				; se mueve a BL el ultimo digito de los MILISEGUNDOS
	XOR AH,AH 				; se limpia AH
	DIV CL 					; se dividen entre 10 los dos digitos restrantes de los MILISEGUNDOS para separarlos
	MOV BH, AH 				; se mueve el segundo digito a BH
	MOV DL, AL 				; se mueve el primer digito a DL

	MOV AH,02H 				; se prepara la opcion de la interrupcion
	ADD DL,30H 				; se suma 30 a DL para obtener us valor en ascci
	INT 21H 				; imprimimos

	MOV DL, BH 				; se mueve el segundo digito a DL
	ADD DL,30H 				; se suma 30 para obtener el numero en ascci
	INT 21H 				;imprimimos

	MOV DL, BL 				; se mmmueve el ultimo digito a DL
	ADD DL,30H 				; se suma 30 para obtener el numero en ascci
	INT 21H 				; imprimimos

	MOV DL,0DH 				
	INT 21H
endm


reinic_cronometro macro MILISEGUNDOS, SEGUNDOS, MINUTOS 	;reincia las variables para el cronometro
	MOV MILISEGUNDOS,0D 	;pone en 0 MILISEGUNDOS
	MOV SEGUNDOS,0D 		;pone en 0 SEGUNDOS
	MOV MINUTOS,0D 			;pone en 0 MINUTOS
endm

;====================================================================================================================

;=================================== Segmento de datos ==============================================================
	.data	

;---------------------------- Constantes ------------------------------
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'

;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;-----------------------------------------------------------------------
	
;----------------------------- Variables -------------------------------
titulo 			db 		"Reloj - Cron",162,"metro"
reloj_str 		db 		"RELOJ"
crono_str 		db 		"CRON",224,"METRO"
creditos_str	db 		"CR",144,"DITOS"
regresar_str    db      "<- REGRESAR"
reloj			db 		"00:00:00 hrs",0DH,'$'	
crono			db		"00:00.000"
integ_1_str 	db      "GARCIA MENESES JEREMY"
integ_2_str     db 		"HERN",181,"DEZ RIVERA DAVID"
integ_3_str		db 		"ZARAZ",233,"A RAMIREZ JOHAN AXEL"
t_inicial		dw 		0,0
t_final			dw		0,0
t_dif 			dw		0,0
tick_ms			dw 		55
mil				dw		1000
cien 			db 		100
diez			db 		10
sesenta 		db 		60
crono_ms		dw 		0
crono_s 		db 		0
crono_m 		db 		0
col_aux 		db 		0
ren_aux 		db 		0

;Auxiliar para cálculo de coordenadas del mouse
ocho			db 		8
;Cuando el driver del mouse no esta disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'

;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
caracter_boton 	db 		0
renglon_boton 	db 		0
columna_boton 	db 		0
color_boton		db 		0

;MARCO DE BOTON
;Caracteres del marco superior
;					000,	001		002		003		004
marco_sup_bot	db	218,	196,	196,	196,	191

;Caracter del marco lateral para los botones
marco_lat_bot	db	179

;Caracteres del marco inferior para los botones
marco_inf_bot	db	192,	196,	196,	196,	217

;variables para reloj
HORA     DB	 0,0,0
TIME     DB  0,0,0,0,0,0

;banderas
bandera_reloj DB 0
bandera_crono db 0
bandera_creditos db 0

;variables para cronometro
MILI	 DW  0D
SEGU     DB  0D
MINU     DB  0D
TICK   	 DW  0,0
;----------------------------------------------------------------------
;==================================================================================================

;=============================== Segmento de codigo ===============================================
	.code				
inicio:							;etiqueta inicio
	inicializa_ds_es    		;Inicializamos segmento de datos.
	comprueba_mouse				;macro para revisar driver de mouse
	xor ax,0FFFFh				;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui				;Si existe el driver del mouse, entonces salta a 'imprime_ui', si no existe el driver del mouse entonces se muestra un mensaje y salta a 'teclado'
	imprime_cadena no_mouse 	;Imprimimos una cadena indicando que no se encontro el driver del mouse.
	jmp teclado		        	;Si no se encuentra el driver del mouse, podemos finalizar el programa con el teclado.

imprime_ui:
	clear 						;limpia pantalla
	oculta_cursor_teclado		;oculta cursor del mouse
	apaga_cursor_parpadeo 		;Deshabilita parpadeo del cursor
	call DIBUJA_MARCO_EXT 		;procedimiento que dibuja marco de la interfaz
	call DIBUJA_BOTONES_INICIO  ;Imprimimos en pantalla botones de la ventana principal (menú).
	muestra_cursor_mouse 		;hace visible el cursor del mouse, revisar que el boton izquierdo del mouse no esté presionado, si el botón no está suelto, no continúa
mouse_no_clic:
	lee_mouse mouse_no_clic 	;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

posiciones:
								;Leer la posicion del mouse y hacer la conversion a resolucion 80x25 (columnas x renglones) en modo texto
	mov ax,dx 					;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 					;Division de 8 bits
								;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
								;para obtener el valor correspondiente en resolucion 80x25

	xor ah,ah 					;Descartar el residuo de la division anterior
	mov dx,ax 					;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 					;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 					;Division de 8 bits
								;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
								;para obtener el valor correspondiente en resolucion 80x25

	xor ah,ah 					;Descartar el residuo de la division anterior
	mov cx,ax 					;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
								;dx renglones
								;cx columnas
								;Si el mouse fue presionado en el renglon 0
	cmp dx,0    				;se va a revisar si fue dentro del boton [X]
	je boton_x

;Revisamos en que 'ventana' nos encontramos
	cmp bandera_reloj,1 
	je segunda_ventana 			;Salta si je es igual a 1 (Estamos en segunda ventana).

	cmp bandera_crono,1
	je tercer_ventana 			;Salta si je es igual a 1 (Estamos en tercer ventana).

	cmp bandera_creditos,1
	je cuarta_ventana 			;Salta si je es igual a 1 (Estamos en cuarta ventana).


;Si estamos en la primer ventana validamos cúal de los 3 botones se presiona
primer_ventana:
    							;Se verifica primero si el mouse se presiono antes del marco inferior de cada boton
    							;para poder llevar un flujo secuencial de las condiciones de los saltos.
								;Verificamos si se presiono boton 1 marco sup(renglon = 5) marco inf(renglon = 7)
	cmp dx,7 
	jbe boton_1_1 				;Salta si dx es menor o igual a 7
								;Verificamos si se presiono boton 2 marco sup(renglon = 10) marco inf(renglon = 12)
	cmp dx,12
	jbe boton_2_1 				;Saltamos si dx es menor o igual a 12
								;Verificamos si se presiono boton 3 marco sup(renglon = 15) marco inf(renglon = 17)
	cmp dx,17
	jbe boton_3_1				;Saltamos si dx es menor o igual a 17
	jmp mouse_no_clic 			;Si no se presiono el clic izquierdo del mouse saltamos a la etiqueta mouse_no_clic.

;Si estamos en la segunda ventana validamos si se presiono el boton de regreso.
segunda_ventana:
    							;Verificamos si el mouse fue presionado en el renglon correspondiente al marco superior del boton de regreso al menú principal
	cmp dx,20
	jae boton_reloj_salir_1 	;Salta si dx es mayor o igual a 20
	jmp mostrar_reloj 			;Si no se presiono el mouse o el renglon correspondiete saltamos a la etiqueta mostrar_reloj para continuar su flujo.

;Si estamos en la tercer ventana validamos cúal de los 3 botones se presiono (inicio/continuar, pausa, reiniciar), los cuales estan alineados
;horizontalmente y todos tienen el marco inferior en el renglón 15. Adicionalmente se verifica si se presiona el boton de regreso el cual tiene
;su marco inferior en el renglón 20.  
tercer_ventana:
    							;Verificamos si se presiono el mouse en la fila de botones o antes.
	cmp dx,15
	jbe botones_cron_1			;Salta si dx es menor o igual a 15
								;Verificamos si el mouse fue presionado en el renglon correspondiente al marco superior del boton de regreso al menú principal
	cmp dx,20
	jae boton_cron_salir_1 		;Salta si dx es mayor o igual a 20
	jmp mostrar_cron   			;Si no se presiono ninguno de los botones continuamos con el flujo del cronometro

;Cuando estamos en la cuarta ventana solo se valida si se presiono el boton de regreso.
cuarta_ventana:
    							;Verificamos si el mouse fue presionado en el renglon correspondiente al marco superior del boton de regreso al menú principal
	cmp dx,20
	jae boton_creditos_salir_1 	;Salta si dx es mayor o igual a 20
	jmp mostrar_creditos       	;Si no se presiona ningun boton continuamos en la ventana de créditos

;Condiciones para boton salir (global para todas las ventanas).
boton_x:
								;Lógica para revisar si el mouse fue presionado en [X]
								;[X] se encuentra en renglon 0 y entre columnas 76 y 78
	jmp boton_x1
boton_x1:
    							;Veificamos si se presiono el boton despues del marco izquierdo del boton salir
	cmp cx,76
	jge boton_x2  				;Si cx es mayor o igual a 76 saltamos
 	jmp mouse_no_clic
boton_x2:
    							;Veificamos si se presiono el boton despues del marco izquierdo del boton salir
	cmp cx,78
	jbe boton_x3   				;Si cx es menor o igual a 78 saltamos
	jmp mouse_no_clic
boton_x3:
								;Se cumplieron todas las condiciones
	jmp salir 					;Se termina el programa.

;;;;;;;;;;;;;;;;;;;
;BOTON 1 VENTANA 1;
;;;;;;;;;;;;;;;;;;;
;Si ya se verifico que presionamos el mouse en el renglón 7 o antes llegamos a este punto
boton_1_1:
    							;Validamos si presionamos el marco superior del boton 1 o despues del marco superior
	cmp dx,5
	jae boton_1_2 				;salta si cx es mayor o igual a 5 (ya se verificaron los marcos superior e inferior, sigue validar los laterares)
	jmp mouse_no_clic   		;Continuamos el flujo del menú
boton_1_2:
								;Validamos si se presiono el marco izquierdo o despues.
	cmp cx,24
	jae boton_1_3 				; salta si cx es mayor o igual a 24
	jmp mouse_no_clic 			
boton_1_3:
								;Validamos si se presiono el marco derecho o antes
	cmp cx, 28
	jbe boton_1_4 				;salta si cx es menor o igual a 28
	jmp mouse_no_clic  			

;;;;;;;
;RELOJ;
;;;;;;;
;Si llegamos a este punto significa que se presiono el boton 1 y nos 'cambiamos' a la
;ventana del reloj
boton_1_4:
;Preparamos la ventana del reloj
	clear
	call DIBUJA_MARCO_EXT
	call DIBUJA_BOTONES_RELOJ
	call IMPRIME_HORA
	mov bandera_reloj,1d
	oculta_cursor_teclado	
	apaga_cursor_parpadeo 	
	muestra_cursor_mouse 	
mostrar_reloj:
;Empiezan las funcionalidades del reloj
	CALL guardar_hora				; guardara la hoa del sistema en CX y DX
	MOV [HORA],CH 					; copia la hora (CH) en la primera localidad de la variable hora
	MOV [HORA+1],CL 				; copia los minutos (CL) en la segunda localidad de la variable hora
	MOV [HORA+2],DH 				; copia los segundos (DH) en la tercera localidad de la variable hora
	separar_digitos HORA,TIME 		; separa cada uno de los digitos de la hora, minutos y segundos para imprimirlos
	guardar_digitos TIME, reloj 	; guarda los digitos en las posiciones de memoria correspondientes a plantilla de la hora
	call IMPRIME_HORA				; imprime la hora 

									;Revisar que el boton izquierdo del mouse no esté presionado
									;Si el botón no está suelto, no continúa
	lee_mouse mostrar_reloj 		;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse2:
	lee_mouse mouse2 				;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
	jmp posiciones   				;Saltamos a la etiqueta posiciones para validar en que ventana estamos y si se esta presionando algun boton

;;;;;;;;;;;;;;;;;;;;;;;;;
;BOTON REGRESO VENTANA 2;
;;;;;;;;;;;;;;;;;;;;;;;;;
;En esta ventana solo tenemos el boton de salir
boton_reloj_salir_1:
								;Para este punto ya se verifico que se presiono el mouse despues del renglon 20
								;Validamos si se presiono el mouse en renglon 22 (marco inferior boton salir) o antes 
	cmp dx,22
	jbe boton_reloj_salir_2		;Si dx es menor o igual a 22 salta
	jmp mostrar_reloj  			;Continuamos flujo reloj

boton_reloj_salir_2:
								;Validamos si se presiono el mouse en la columna 10 (marco izquierdo boton salir) o despues
	cmp cx,10
	jae boton_reloj_salir_3		;salta si cx es mayor o igual a 10
	jmp mostrar_reloj 			
boton_reloj_salir_3:
								;Validamos si se presiono el mouse en la columna 14 (marco derecho del boton salir) o antes
	cmp cx, 14
	jbe boton_reloj_salir_4 	;salta si cx es menor o igual a 14
	jmp mostrar_reloj 
;Si se cumplieron las condiciones quiere decir que presionamos el boton de salir
boton_reloj_salir_4:
	mov bandera_reloj,0  		;Indicamos que salimos de la ventana de reloj
	jmp imprime_ui 				;'Volvemos' al menú

;;;;;;;;;;;;;;;;;;;
;BOTON 2 VENTANA 1;
;;;;;;;;;;;;;;;;;;;
boton_2_1:
								;Para este punto ya se verifico que se presiono el mouse antes del renglon 12 y despues del 7	
								;Validamos si se presiono mouse despues de renglon 10 (marco superior boton 2)
	cmp dx,10		
	jae boton_2_2 				;salta si cx es mayor o igual a 10
	jmp mouse_no_clic

boton_2_2:
								;Validamos si se presiono el mouse en el marco izquierdo del boton o despues
	cmp cx,24
	jae boton_2_3 				;salta si cx es mayor o igual a 25
	jmp mouse_no_clic
boton_2_3:
								;Validamos si se presiono el mouse en el marco derecho del boton o despues
	cmp cx, 28
	jbe boton_2_4 				;salta si cx es menor o igual a 28
	jmp mouse_no_clic

;;;;;;;;;;;;
;CRONOMETRO;
;;;;;;;;;;;;
;Si llegamos a este punto significa que se presiono el boton 2 y nos 'cambiamos' a la
;ventana del cronometro
boton_2_4:
;Preparamos la ventana
	clear
	call DIBUJA_MARCO_EXT
	call DIBUJA_BOTONES_CRON
	mov bandera_crono,1d
	oculta_cursor_teclado
	apaga_cursor_parpadeo
	muestra_cursor_mouse 	
	mostrar_cron:
	;Empiezan las funcionalidades del cronometro
		call IMPRIME_CRON
									;Revisar que el boton izquierdo del mouse no esté presionado
									;Si el botón no está suelto, no continúa
		lee_mouse mostrar_cron 		;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
		mouse3:
			lee_mouse mouse3 		;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
		jmp posiciones	            ;Saltamos a la etiqueta posiciones para validar en que ventana estamos y si se esta presionando algun boton

;;;;;;;;;;;;;;;;;;;
;BOTONES VENTANA 2;
;;;;;;;;;;;;;;;;;;;
botones_cron_1:
                                    ;Para este punto ya se verifico si se presiono el mouse en el renglon 15 o antes.
									;Validamos si se presiono el mouse en el renglon 13(marco superior botones cron)  o despues
	cmp dx,13
	jae botones_cron_2 				;Salta si dx mayor o igual a 13
	jmp mostrar_cron

botones_cron_2:
									;Validamos si se presiono el mouse en el renglon 29 (marco derecho boton iniciar crono) o antes 
	cmp cx,29
	jbe boton_iniciar_1 			;Salta si cx menor o igual a 29

									;Validamos si se presiono el mouse en el renglon 39 (marco derecho boton detener crono) o antes 
	cmp cx,39
	jbe boton_pausa_1  				;Salta si cx menor o igual a 39


									;Validamos si se presiono el mouse en el renglon 49 (marco derecho boton reiniciar crono) o antes 
	cmp cx,49
	jbe boton_reiniciar_1 ;			Salta si cx menor o igual a 49
	jmp mostrar_cron

boton_iniciar_1:
									;Validamos si presionamos el marco izquierdo del boton de iniciar cron o despues
	cmp cx,25
	jae boton_iniciar_2 			;Salta si cx es mayor o igual a 25
	jmp mostrar_cron

boton_iniciar_2:
	;ACCIONES TEMPORALES (AQUI VA LO CORRESPONDIENTE A CUANDO INICIA EL CRONOMETRO)
	aumentar_milis TICK, MILI, SEGU, MINU


boton_pausa_1:
									;Validamos si presionamos el marco izquierdo del boton de pausa cron o despues
	cmp cx,35
	jae boton_pausa_2 				;Saltamos si cx es mayor o igual a 35
	jmp mostrar_cron

boton_pausa_2:
	;ACCIONES TEMPORALES (AQUI VA LO CORRESPONDIENTE A CUANDO SE PAUSA EL CRONOMETRO)
	call IMPRIME_CRON			;solo imprimimos los valores del cronometro para mostrar el ultimo valor
	apaga_cursor_parpadeo 		;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 		;hace visible el cursor del mouse
	lee_mouse boton_pausa_2     ;Mientras no se precione el mouse continuamos en esta etiqueta
	jmp posiciones              ;Si se presiono saltamos a etiqueta posiciones para validar si se presiono algun boton

boton_reiniciar_1:
                                ;Validamos si se presiono el marco izquierdo del boton para reiniciar
	cmp cx,45
	jae boton_reiniciar_2       ;Saltamos si cx es mayor o igual a 35
	jmp mostrar_cron

boton_reiniciar_2:

	reinic_cronometro MILI, SEGU, MINU 	;llamada a macro reiniciar_cronometro.
	call IMPRIME_CRON 				;imprimir_cronometro MILI, SEGU, MINU
	apaga_cursor_parpadeo 			;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 			;hace visible el cursor del mouse
	lee_mouse boton_reiniciar_2     ;Mientras no se precione el mouse continuamos en esta etiqueta
	jmp posiciones             		 ;Si se presiono saltamos a etiqueta posiciones para validar si se presiono algun boton


boton_cron_salir_1:
	cmp dx,22
	jbe boton_cron_salir_2
	jmp mostrar_cron
boton_cron_salir_2:
	cmp cx,10
	jae boton_cron_salir_3; salta si cx es mayor o igual a 10
	jmp mostrar_cron
boton_cron_salir_3:
	cmp cx, 14
	jbe boton_cron_salir_4 ;salta si cx es menor o igual a 14
	jmp mostrar_cron
boton_cron_salir_4:
	mov bandera_crono,0
	jmp imprime_ui

boton_3_1:
	cmp dx,15
	jae boton_3_2 ;salta si cx es mayor o igual a 15
	jmp mouse_no_clic
boton_3_2:
	cmp cx,24
	jae boton_3_3 ; salta si cx es mayor o igual a 24
	jmp mouse_no_clic
boton_3_3:
	cmp cx, 28
	jbe boton_3_4 ;salta si cx es menor o igual a 28
	jmp mouse_no_clic	


;;;;;;;;;;;;
;CREDITOS  ;
;;;;;;;;;;;;	
boton_3_4:
	clear
	call DIBUJA_MARCO_EXT
	mov bandera_creditos,1d
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse
	mostrar_creditos:
		call DIBUJA_CREDITOS
		;Revisar que el boton izquierdo del mouse no esté presionado
		;Si el botón no está suelto, no continúa
		lee_mouse mostrar_creditos
		;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
		mouse4:
			lee_mouse mouse4
		jmp posiciones	

boton_creditos_salir_1:
	cmp dx,22
	jbe boton_creditos_salir_2
	jmp mostrar_creditos
boton_creditos_salir_2:
	cmp cx,10
	jae boton_creditos_salir_3; salta si cx es mayor o igual a 10
	jmp mostrar_creditos
boton_creditos_salir_3:
	cmp cx, 14
	jbe boton_creditos_salir_4 ;salta si cx es menor o igual a 14
	jmp mostrar_creditos
boton_creditos_salir_4:
	mov bandera_creditos,0
	jmp imprime_ui

;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DIBUJA_MARCO_EXT proc
	;imprimir esquina superior izquierda del marco
	posiciona_cursor 0,0
	imprime_caracter_color marcoEsqSupIzq,cBlanco,bgNegro
	
	;imprimir esquina superior derecha del marco
	posiciona_cursor 0,79
	imprime_caracter_color marcoEsqSupDer,cBlanco,bgNegro
	
	;imprimir esquina inferior izquierda del marco
	posiciona_cursor 24,0
	imprime_caracter_color marcoEsqInfIzq,cBlanco,bgNegro
	
	;imprimir esquina inferior derecha del marco
	posiciona_cursor 24,79
	imprime_caracter_color marcoEsqInfDer,cBlanco,bgNegro
	
	;imprimir marcos horizontales, superior e inferior
	mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
marco_sup_e_inf:
	mov [col_aux],cl
	;Superior
	posiciona_cursor 0,[col_aux]
	imprime_caracter_color marcoHor,cBlanco,bgNegro
	;Inferior
	posiciona_cursor 24,[col_aux]
	imprime_caracter_color marcoHor,cBlanco,bgNegro
	mov cl,[col_aux]
	loop marco_sup_e_inf

	;imprimir marcos verticales, derecho e izquierdo
	mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
marco_der_e_izq:
	mov [ren_aux],cl
	;Izquierdo
	posiciona_cursor [ren_aux],0
	imprime_caracter_color marcoVer,cBlanco,bgNegro
	;Inferior
	posiciona_cursor [ren_aux],79
	imprime_caracter_color marcoVer,cBlanco,bgNegro
	mov cl,[ren_aux]
	loop marco_der_e_izq

	;imprimir [X] para cerrar programa
	posiciona_cursor 0,76
	imprime_caracter_color '[',cBlanco,bgNegro
	posiciona_cursor 0,77
	imprime_caracter_color 'X',cRojoClaro,bgNegro
	posiciona_cursor 0,78
	imprime_caracter_color ']',cBlanco,bgNegro

	;imprimir título
	posiciona_cursor 0,31
	imprime_cadena_color [titulo],18,cBlanco,bgNegro
	ret
	endp

;###################################33
;
;	procedimiento de prueba para imprimir botones.
;
;#####################################

	DIBUJA_BOTONES_INICIO proc
		;Imprime Boton reloj
		printButton 24,5,cGrisClaro,'1'
		posiciona_cursor 6,30
		imprime_cadena_color [reloj_str],5,cBlanco,bgNegro

		;Imprime Boton cron
		printButton 24,10,cGrisClaro,'2'
		posiciona_cursor 11,30
		imprime_cadena_color [crono_str],10,cBlanco,bgNegro		

		;Imprime Boton creditos
		printButton 24,15,cGrisClaro,'3'
		posiciona_cursor 16,30
		imprime_cadena_color [creditos_str],8,cBlanco,bgNegro			

		ret
	endp

;###################################33
;
;	procedimiento de prueba para imprimir botones reloj.
;
;#####################################

	DIBUJA_BOTONES_RELOJ proc	
		;Imprime Boton regresar
		printButton 10,20,cGrisClaro,'*'
		posiciona_cursor 21,16 
		imprime_cadena_color [regresar_str],11,cBlanco,bgNegro			
		ret
	endp

;#########################3
;#	Procedimiento para imprimir hora
;###########################

	IMPRIME_HORA proc
		posiciona_cursor 5,34
		imprime_cadena_color [reloj],8,cBlanco,bgNegro
		ret
	endp

;###################################33
;
;	procedimiento de prueba para imprimir botones de cronometro.
;
;#####################################

	DIBUJA_BOTONES_CRON proc	
		;Imprime Boton regresar
		printButton 10,20,cGrisClaro,'*'
		posiciona_cursor 21,16 
		imprime_cadena_color [regresar_str],11,cBlanco,bgNegro			
		;ImPrime Boton iniciar
		printButton 25,13,cGrisClaro,17d	
		;Imprime Boton pausa
		printButton 35,13,cGrisClaro,186d
		;Imprime Boton reiniciar
		printButton 45,13,cGrisClaro, 8d
		ret
	endp

;#########################3
;#	Procedimiento para imprimir cronometro
;###########################
	IMPRIME_CRON proc
		posiciona_cursor 5,34
		;imprime_cadena_color [crono],9,cBlanco,bgNegro	
		imprimir_cronometro MILI, SEGU, MINU
		ret
	endp

	DIBUJA_CREDITOS proc	
		posiciona_cursor 5,30
		imprime_cadena_color [integ_1_str],21,cBlanco,bgNegro
		posiciona_cursor 10,30
		imprime_cadena_color [integ_2_str],21,cBlanco,bgNegro
		posiciona_cursor 15, 30 
		imprime_cadena_color [integ_3_str],26,cBlanco,bgNegro
		;Imprime Boton regresar
		printButton 10,20,cGrisClaro,'*'
		posiciona_cursor 21,16 
		imprime_cadena_color [regresar_str],11,cBlanco,bgNegro			
		ret
	endp	

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posicion que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;caracter_boton: debe contener el caracter que va a mostrar el boton
	;renglon_boton: contiene la posicion del renglon en donde inicia el boton
	;columna_boton: contiene la posicion de la columna en donde inicia el boton
	;color_boton: contiene el color del boton
	IMPRIME_BOTON proc
		xor di,di
		mov cx,5d
		mov al,[columna_boton]
		mov [col_aux],al
	marcos_hor_boton:
		push cx
		;Imprime marco superior
		posiciona_cursor [renglon_boton],[col_aux]
		imprime_caracter_color [marco_sup_bot+di],[color_boton],cNegro
		;Imprime marco inferior
		add [renglon_boton],2
		posiciona_cursor [renglon_boton],[col_aux]
		sub [renglon_boton],2
		imprime_caracter_color [marco_inf_bot+di],[color_boton], cNegro
		inc [col_aux]
		inc di
		pop cx
		loop marcos_hor_boton
		;Imprime marcos laterales
		xor di,di
		mov cx,14		;cx = 23d = 17h. Prepara registro CX para loop. 
						;para imprimir los marcos laterales en pantalla, entre el segundo y el penúltimo renglones	
		mov al,[renglon_boton]
		mov [ren_aux],al
	marcos_ver_boton:
		inc [ren_aux]
		posiciona_cursor [ren_aux],[columna_boton]
		imprime_caracter_color [marco_lat_bot],[color_boton],cNegro
		add [columna_boton],4
		posiciona_cursor [ren_aux],[columna_boton]
		sub [columna_boton],4
		imprime_caracter_color [marco_lat_bot],[color_boton],cNegro
	car_boton:
		add [renglon_boton],1
		add [columna_boton],2
		posiciona_cursor [renglon_boton],[columna_boton]
		imprime_caracter_color [caracter_boton],[color_boton], cNegro
		sub [renglon_boton],1
		sub [columna_boton],2
		ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador

	guardar_hora proc 	;Procedimiento para tomar la hora del sistema
		MOV AH,02H
		INT 1AH
		RET
	endp

	guardar_ticks proc 	; toma los ticks del microporcesador
		MOV AH,00H
		INT 1AH
		; ticjs almacenados en cx y dx 
		RET
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	end inicio			;fin de etiqueta inicio, fin de programa