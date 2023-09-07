;----------------------- Macros Johan ---------------------------------------------
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

;----------------------------------------------------------------------------------





title "Proyecto 2: Reloj-cronómetro 'gráfico'" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definición de constantes
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
	
;Definicion de variables
titulo 			db 		"Reloj - Cron",162,"metro"
reloj_str 		db 		"RELOJ"
crono_str 		db 		"CRON",224,"METRO"
creditos_str	db 		"CR",144,"DITOS"
regresar_str    db      "<- REGRESAR"
reloj			db 		"00:00:00 hrs",0DH,'$'	
crono			db		"00:00.000"
integ_1_str 	db      "GARCIA MENESES JEREMY"
integ_2_str     db 		"HERN",181,"DEZ RIVERA DAVID"
integ_3_str		db 		"ZARAZUA JOHAN"
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
;Auxiliar para calculo de coordenadas del mouse
ocho		db 		8
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
;Caracter del marco lateral
marco_lat_bot	db	179
;Caracteres del marco inferior
marco_inf_bot	db	192,	196,	196,	196,	217

;variables para reloj
HORA     DB	 0,0,0
TIME     DB  0,0,0,0,0,0

;banderas
bandera_reloj DB 0
bandera_crono db 0
bandera_creditos db 0

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm
;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 
;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm
;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm
;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm
;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
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
lee_mouse	macro
	mov ax,0003h
	int 33h
endm
;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

;Macro para imprimir un boton
printButton macro columna,renglon,color,caracter
		mov [columna_boton],columna
		mov [renglon_boton],renglon
		mov [color_boton],color
		mov [caracter_boton],caracter
		call IMPRIME_BOTON
endm

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code				;segmento de codigo
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_MARCO_EXT 	;procedimiento que dibuja marco de la interfaz

;################
	call DIBUJA_BOTONES_INICIO 
;Prueba procedimiento

;########################3
	muestra_cursor_mouse 	;hace visible el cursor del mouse
;Revisar que el boton izquierdo del mouse no esté presionado
;Si el botón no está suelto, no continúa
mouse_no_clic:
	lee_mouse
	test bx,0001h ;Comparamos bx con 0001h sin guardar el resultado
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
posiciones:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon
	;dx renglones
	;cx columnas

	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x

	cmp bandera_reloj,1
	je segunda_ventana ; Salta si je es igual a 1 (Estamos en segunda ventana).

	cmp bandera_crono,1
	je tercer_ventana ; Salta si je es igual a 1 (Estamos en tercer ventana).

	cmp bandera_creditos,1
	je cuarta_ventana ; Salta si je es igual a 1 (Estamos en cuarta ventana).


primer_ventana:
	;Verificamos si se presiono boton 1
	cmp dx,7 
	jbe boton_1_1 ;Salta si dx es menor o igual a 7
	;Verificamos si se presiono boton 2
	cmp dx,12
	jbe boton_2_1 ;Saltamos si dx es menor o igual a 12
	;Verificamos Boton 3
	cmp dx,17
	jbe boton_3_1; Saltamos si dx es menor o igual a 17

	jmp mouse_no_clic


segunda_ventana:
	cmp dx,20
	jae boton_reloj_salir_1 ; Salta si dx es mayor o igual a 20
	jmp mostrar_reloj

tercer_ventana:
	cmp dx,15
	jbe botones_cron_1; Salta si dx es menor o igual a 12

	cmp dx,20
	jae boton_cron_salir_1 ; Salta si dx es mayor o igual a 20
	jmp mostrar_cron

cuarta_ventana:
	cmp dx,20
	jae boton_creditos_salir_1 ; Salta si dx es mayor o igual a 20
	jmp mostrar_creditos

;#################
;# Condiciones para boton salir (global para todas las ventanas).
;##################

boton_x:
	jmp boton_x1
;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
	cmp cx,76
	jge boton_x2
	jmp mouse_no_clic
boton_x2:
	cmp cx,78
	jbe boton_x3
	jmp mouse_no_clic
boton_x3:
	;Se cumplieron todas las condiciones
	jmp salir



;########################################3
;	BOTONES VENTANA 1
;
;	PRUEBA PARA BOTON 1 
;
;#######################################
boton_1_1:
	cmp dx,5
	jae boton_1_2 ;salta si cx es mayor o igual a 5
	jmp mouse_no_clic
boton_1_2:
	cmp cx,24
	jae boton_1_3 ; salta si cx es mayor o igual a 25
	jmp mouse_no_clic
boton_1_3:
	cmp cx, 28
	jbe boton_1_4 ;salta si cx es menor o igual a 28
	jmp mouse_no_clic
boton_1_4:
	clear
	call DIBUJA_MARCO_EXT
	call DIBUJA_BOTONES_RELOJ
	call IMPRIME_HORA
	mov bandera_reloj,1d
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse

mostrar_reloj:
	CALL guardar_hora
	MOV [HORA],CH 		;hora
	MOV [HORA+1],CL 	;minutos
	MOV [HORA+2],DH 	;segundos
	separar_digitos HORA,TIME
	guardar_digitos TIME, reloj 	;guarda los digitos en las posiciones de memoria correspondientes a plantilla de la hora
	call IMPRIME_HORA
;Revisar que el boton izquierdo del mouse no esté presionado
;Si el botón no está suelto, no continúa
	lee_mouse
	test bx,0001h ;Comparamos bx con 0001h sin guardar el resultado
	jz mostrar_reloj
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse2:
	lee_mouse
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse2 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
	jmp posiciones
;########################################3
;	BOTONES VENTANA 2
;
;	PRUEBA PARA BOTON SALIR 
;
;#######################################
boton_reloj_salir_1:
	cmp dx,22
	jbe boton_reloj_salir_2
	jmp mostrar_reloj
boton_reloj_salir_2:
	cmp cx,10
	jae boton_reloj_salir_3; salta si cx es mayor o igual a 10
	jmp mostrar_reloj
boton_reloj_salir_3:
	cmp cx, 14
	jbe boton_reloj_salir_4 ;salta si cx es menor o igual a 14
	jmp mostrar_reloj
boton_reloj_salir_4:
	mov bandera_reloj,0
	jmp imprime_ui

boton_2_1:
	cmp dx,10
	jae boton_2_2 ;salta si cx es mayor o igual a 10
	jmp mouse_no_clic
boton_2_2:
	cmp cx,24
	jae boton_2_3 ; salta si cx es mayor o igual a 25
	jmp mouse_no_clic
boton_2_3:
	cmp cx, 28
	jbe boton_2_4 ;salta si cx es menor o igual a 28
	jmp mouse_no_clic
boton_2_4:
	clear
	call DIBUJA_MARCO_EXT
	
	mov bandera_crono,1d
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse
	mostrar_cron:
		call DIBUJA_BOTONES_CRON
		call IMPRIME_CRON
		;Revisar que el boton izquierdo del mouse no esté presionado
		;Si el botón no está suelto, no continúa
		lee_mouse
		test bx,0001h ;Comparamos bx con 0001h sin guardar el resultado
		jz mostrar_cron
		;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
		mouse3:
			lee_mouse
			test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
			jz mouse3 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
		jmp posiciones	


botones_cron_1:
	cmp dx,13
	jae botones_cron_2 ;Salta si dx mayor o igual a 10
	jmp mostrar_cron

botones_cron_2:
	cmp cx,29
	jbe boton_iniciar_1 ;Salta si cx menor o igual a 29
	
	cmp cx,39
	jbe boton_pausa_1  ;Salta si cx menor o igual a 39

	cmp cx,49
	jbe boton_reiniciar_1 ;Salta si cx menor o igual a 49

	jmp mostrar_cron

boton_iniciar_1:
	cmp cx,25
	jae boton_iniciar_2 ;Salta si cx es mayor o igual a 25
	jmp mostrar_cron

boton_iniciar_2:

	;ACCIONES TEMPORALES (AQUI VA LO CORRESPONDIENTE A CUANDO INICIA EL CRONOMETRO)
	;clear
	;call DIBUJA_MARCO_EXT
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse

boton_pausa_1:
	cmp cx,35
	jae boton_pausa_2
	jmp mostrar_cron

boton_pausa_2:
	;ACCIONES TEMPORALES (AQUI VA LO CORRESPONDIENTE A CUANDO SE PAUSA EL CRONOMETRO)
	clear
	call DIBUJA_MARCO_EXT
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse

boton_reiniciar_1:
	cmp cx,45
	jae boton_reiniciar_2
	jmp mostrar_cron

boton_reiniciar_2:
;ACCIONES TEMPORALES (AQUI VA LO CORRESPONDIENTE A CUANDO SE REINICIA EL CRONOMETRO)
	clear
	call DIBUJA_MARCO_EXT
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	muestra_cursor_mouse 	;hace visible el cursor del mouse

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
		lee_mouse
		test bx,0001h ;Comparamos bx con 0001h sin guardar el resultado
		jz mostrar_creditos
		;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
		mouse4:
			lee_mouse
			test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
			jz mouse4 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
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
		imprime_cadena_color [crono],9,cBlanco,bgNegro	
		ret
	endp

	DIBUJA_CREDITOS proc	
		posiciona_cursor 5,30
		imprime_cadena_color [integ_1_str],21,cBlanco,bgNegro
		posiciona_cursor 10,30
		imprime_cadena_color [integ_2_str],21,cBlanco,bgNegro
		posiciona_cursor 15, 30 
		imprime_cadena_color [integ_3_str],13,cBlanco,bgNegro
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	end inicio			;fin de etiqueta inicio, fin de programa