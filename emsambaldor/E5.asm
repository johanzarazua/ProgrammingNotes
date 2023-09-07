title "Ejercicio 4. Johan Axel Zarazua Ramirez" 
	.model small 
	.386		
	.stack 64
	.data
	X DW 0F5636301234FEDCBh
	.code
inicio:
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,AX           ;DS = AX, inicializa segmento de datos

;========== Operaciones ==========
	
	adc x, 4921BCF0216505FBh
	
;========================================================

salir:
	mov ah,4Ch			
	mov al,0			
	int 21h	
	end inicio