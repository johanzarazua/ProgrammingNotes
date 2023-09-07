title "Ejercicio 1. Johan Axel Zarazua Ramirez" 
	.model small 
	.386		
	.stack 64
	.code
inicio:
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,AX           ;DS = AX, inicializa segmento de datos

;=========== Inicializacion de registros ===============
	mov AX, 1111h
	mov BX, 1212h
	mov CX, 0ABCDh
	mov DX, 0FFFFh
;========================================================

;========== Instrucciones para cambiar valores ==========
	
	mov SP, BP
	push AX
	push BX
	push CX
	push DX
	pop AX
	pop BX
	pop CX
	pop DX
	
;========================================================

;========== Forma alternativa ===========================
	
	mov AX, 1111h
	mov BX, 1212h
	mov CX, 0ABCDh
	mov DX, 0FFFFh
	
	xchg AX, DX
	xchg BX, CX

;========================================================
salir:
	end inicio