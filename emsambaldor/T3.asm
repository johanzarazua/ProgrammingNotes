title "Tarea 3. Instrucciones aritmeticas" 
	.model small 
	.386		
	.stack 20
	.code
inicio:
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,AX           ;DS = AX, inicializa segmento de datos		
	mov ax, 0FFF1h           ; a AX se le pasa el valor 5.
	;INC ax             ; AX incrementa en una unidad su valor (AX=6).
	;DEC ax             ; AX dismunuye en una unidad su valor (AX=4).
	;INC WORD PTR ES:[DI+4] ;Increm. palabra contenida en ES:DI+4
	;DEC WORD PTR ES:[DI+4] ;DEcrementa la palabra contenida en ES:DI+4
	mov bx, 7			; a BX se le pasa el valor de 3.
	;add ax, bx 		; ax = ax + bx
	;add ch, bx 		; Error ch y bx son de diferentes tipos
	;add ch, bl 		; ch = ch + bx
	;sub ax, bx 		; ax = ax - bx
	;sub cl, ax 		;Error cl es diferente tipo que ax
	;sub cl, al 		; cl = cl - ax
	;stc                 ; ponemos la bandera de acarreo en 1
	;adc ax, bx         ; como la badera de acarreo esta en 1 -> ax = ax + bx + 1
	;adc cl, 05h		; cl =  cl + 05h + CF
	;sbb ax, bx          ; como la badera de acarreo esta en 1 -> ax = ax - bx - 1
	;sbb cx, 8			; cx = cx - 8 - CF
	;mul bx 				; ax = ax * bx  multiplica ax por bx
	div bx 				; ax = ax / bx dividira el valor de ax entre bx
	;mov al, 10
	;mov bl, 12
	;mul bl				; multiplica al por bl --> al = al * bl
	mov ax, 12
	mov bl, 10
	div bl				; divide ax entre bl y el resultado se almacena en al y ah
salir:
	end inicio