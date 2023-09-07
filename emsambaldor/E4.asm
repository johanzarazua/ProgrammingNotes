title "Ejercicio 4. Johan Axel Zarazua Ramirez" 
	.model small 
	.386		
	.stack 64
	.data
	X DW -132d
	Y Dw 120d
	r1 DW 0000h
	r2 Dw 0000h
	r3 DW 0000h
	.code
inicio:
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,AX           ;DS = AX, inicializa segmento de datos

;========== Operaciones ==========
	
	sub Y,-35d
	add Y,53d
	mov AX,Y
	add X,AX
	mov BX,X
	mov r1,BX
	mov r2,BX
	mov r3,BX
	inc r2
	dec r3
	
;========================================================

salir:
	mov ah,4Ch			
	mov al,0			
	int 21h	
	end inicio