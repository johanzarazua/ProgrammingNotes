terminos macro num, d3, d5, d4, dig1, dig2, dig3, dig4, dig5
	xor ax,ax			;AX = 0000h
	mov ax,[num]		; AX = [a]

	div [cien]			;AL = AX / 100d
						;AH = AX % 100d

	mov [d3],al			;d3 = AL
	mov [d4],ah			;d4 = AH

	;PRIMERA MITAD
	xor ax,ax			;AX = 0000d

	mov al,[d3]			;AL = d3
;	cbw					;convierte de byte a word, AX = AL = d3
	div [cien]			;AL = AX / 100d
						;AH = AX % 100d

	mov [dig1],al		;dig1 = AL
	mov [d5],ah			;d5 = AH

	xor ax,ax			;AX = 0000d

	mov al,[d5]			;AL = d5
	div [diez]			;AL = AX / 10d
						;AH = AX % 10d

	mov [dig2],al		;dig2 = AL
	mov [dig3],ah		;dig3 = AH
	mov ax,0d			;AX = 0000d

	;SEGUNDA MITAD
	xor ax,ax			;AX = 0000d
	mov al,[d4]			;AL = d4
	div [diez]			;AL = AX / 10d
						;AH = AX % 10d

	mov [dig4],al		;dig4 = AL
	mov [dig5],ah		;dig5 = AH
endm

imprimir macro salto, dig1, dig2, dig3, dig4, dig5
	mov ah,09h			;AH = 09h, prepara AH para interrupcion 21h
	lea dx,[salto]		;Obtiene la direccion de donde inicia la cadena 'salto'
	int 21h 			;int 21h, AH = 09h. Imprime en pantalla un salto de linea

	mov ah,02h
	mov dl,[dig1]
	add dl,30h
	int 21h

	mov ah,02h
	mov dl,[dig2]
	add dl,30h
	int 21h

	mov ah,02h
	mov dl,[dig3]
	add dl,30h
	int 21h

	mov ah,02h
	mov dl,[dig4]
	add dl,30h
	int 21h

	mov ah,02h
	mov dl,[dig5]
	add dl,30h
	int 21h
endm

title "Tarea 5. Johan Zarazua" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386		;directiva para indicar version del procesador
	.stack 64 	;Define el tamaño del segmento de stack, se mide en bytes

;======================= DATOS =======================================================
	.data		;Definicion del segmento de datos
a			dw		0001h		
b			dw		0000h
c           dw      0
d3			db		0
d4			db		0
d5			db		0
d6			db		0
dig1		db		0
dig2		db		0
dig3		db		0
dig4		db		0
dig5		db		0
cien		db		64h
diez		db		0Ah
contador	db		0
salto		db		13,10," ","$"
;======================= CODIGO ======================================================
	.code				;segmento de codigo
nuevo_termino proc
	mov ax,[a]			;AX = [a]
	mov bx,[b]			;BX = [b]
	mov [b],ax			;[b] = AX
	add ax,bx			;AX = AX + BX
	mov [a],ax			;[a] = AX
	RET
endp

inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos

	;ESCRITURA DE 0
	terminos b, d3, d5, d4, dig1, dig2, dig3, dig4, dig5
	;IMPRIMIR
	imprimir salto, dig1, dig2, dig3, dig4, dig5

	;ESCRITURA DE 1	
	terminos a, d3, d5, d4, dig1, dig2, dig3, dig4, dig5
	;IMPRIMIR
	imprimir salto, dig1, dig2, dig3, dig4, dig5
	
et_fibo:
	CALL nuevo_termino
	mov c, ax
	terminos c, d3, d5, d4, dig1, dig2, dig3, dig4, dig5
	imprimir salto, dig1, dig2, dig3, dig4, dig5

	xor ax, ax			;AX = 0000h

	cmp contador,19		;compara contador con 19
	je salir			;brinca a la etiqueta salir
	inc contador		; contador = contador + 1
	jmp et_fibo			;repite el pocedimiento hasta que contador = 19

;====================== FIN =========================================================
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa