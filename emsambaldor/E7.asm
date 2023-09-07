title "Ejercicio 7 Johan Zarazua" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386		;directiva para indicar version del procesador
	.stack 64 	;Define el tamaño del segmento de stack, se mide en bytes
	.data		;Definicion del segmento de datos
X db 30d
Y db 42d
Z dw 0000h
operacion1 dw
operacion2 dw
operacion3 dw  
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
	mov ax, 0000h

;============================
;	10*X = 10*10
;============================	
	mov al, X
	mov bl, 10d
	mul bl              ; AX = 10*30 = 300d = 12Ch
	mov operacion3, ax  ; operacion3 = 12Ch
	
;===========================
;	Y/2 = 42/2
;===========================
	mov ax, 0000h
	mov al, Y
	mov bl, 2d
	div bl              ; Ax = 42/2 = 21 = 15h
	mov operacion2, ax  ; operacion2 = 15h

;==========================
;	3*X*X = 3*10*10
;==========================
	mov al, X
	mov bl, 3d
	mul bl              ; al = 3*30 = 90 = 5Ah
	mov operacion1, ax  ; operacion1 = 5Ah
	mov al, X
	mul operacion1      ; al = 30*90 = 2700 = A8Ch
	mov operacion1, ax  ; operacion1 = A8Ch

;======================================
;	3*x*x + y/2 = A8Ch + 15h = AA1
;======================================
	mov ax, operacion2
	add operacion1, ax ; operacion1 = AA1

;==================================================
;	3*x*x + y/2 + 10*x = A8Ch + 15h + 12Ch = BCD
;==================================================
	mov ax, operacion3
	add operacion1, ax ; operacion1 =  BCD

;==============================================================
;	3*x*x + y/2 + 10*x - 1002 = A8Ch + 15h + 12Ch - 3EA = 7E3
;==============================================================
	sub operacion1, 1002d ; operacion1 = 7E3
	mov ax, operacion1
	mov Z, ax

salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa