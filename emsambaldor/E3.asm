title "Ejercicio 3. Johan Axel Zarazua Ramirez" 
	.model small 
	.386		
	.stack 64
	.data
	X DB 
	Y DB  
	Z DB
	Resultado DW 0000h
	.code
inicio:
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,AX           ;DS = AX, inicializa segmento de datos

;=========== Inicializacion de variables ===============
	mov X,100d
	mov Y,240d
	mov Z,80d
;========================================================

;=========== Operaciones ================================
	sub X,43d
	sub Y,40d
	mov BL,X
	mov CL,Y
	add Z,BL
	mov BL,Z
	add BX, CX
	mov Resultado,BX
;========================================================

salir:
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = [exCode] = 0 Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio