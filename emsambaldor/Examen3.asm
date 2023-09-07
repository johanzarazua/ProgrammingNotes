title "Examen 3 Johan Zarazua" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386		;directiva para indicar version del procesador
	.stack 64 	;Define el tamaño del segmento de stack, se mide en bytes
	.data		;Definicion del segmento de datos
resultado_f dw 0
n1 db 0
n2 db 0
d1 db 0
d2 db 0
resultado db 0
m_n1 db 0Dh,0Ah,"Ingrese el primer numero : ","$"
m_n2 db 0Dh,0Ah,"Ingrese el segundo numero : ","$"
;mayor 	db		0Dh,0Ah,"El primer numero es mayor",0Dh,0Ah,"$"
;menor 	db		0Dh,0Ah,"El segundo numero es mayor",0Dh,0Ah,"$"
;igual 	db		0Dh,0Ah,"Los numeros son iguales",0Dh,0Ah,"$"

	.code

leer_teclado proc
	MOV AH, 01H
	INT 21H
	RET
endp

inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos

	lea dx,[m_n1]		;Obtiene posicion de memoria de la cadena que contiene la variable 'm_n1'
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.

	CALL leer_teclado   ;leemos la tecla presionada
	mov n1, AL 			;guardamos el valor de numero 1

	lea dx,[m_n2]		;Obtiene posicion de memoria de la cadena que contiene la variable 'm_n1'
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.

	CALL leer_teclado   ;leemos la tecla presionada
	mov n2, AL 			;guardamos el valor de numero 2

	mov ah,n1 			;movemos n1 a ah para comparar
	mov bh,n2 			;movemos n2 a bh para comparar

	cmp ah, bh 			;comparamos ah y bh
	je  e_igual 		; si son iguales brinca a la etiquete e_igual
	jae e_mayor 		; si ah es mayor a bh brinca a la etiquete e_mayor
	cmp bh, ah 			;comparamos bh y ah
	jae e_menor 		; si ah es menor a bh brinca a la etiquete e_menor
 
 e_mayor:
	;lea dx,[mayor]		;Obtiene posicion de memoria de la cadena que contiene la variable 'hola'
	;mov ax,0900h		;opcion 9 para interrupcion 21h
	;int 21h				;interrupcion 21h. Imprime cadena.
	mov al,n1
	sub al,30H
	xor ah, ah
	mov bl,n1
	sub bl,30H
	xor bh,bh
	mul bl
	add n1,al
	mov al,n1
	sub al,30H
	mov [resultado], al

	mov al,[resultado]
	xor ah,ah
	mov bl,10d
	div bl
	mov [d1],al
	mov [d2],ah

	MOV AH,02H
	mov dl,0Ah
	INT 21H 	
	MOV DL,[d1]
	ADD DL,30H
	INT 21H
	MOV DL,[d2]
	ADD DL,30H
	INT 21H
	jmp salir


	jmp salir

e_menor:
	;lea dx,[menor]		;Obtiene posicion de memoria de la cadena que contiene la variable 'hola'
	;mov ax,0900h		;opcion 9 para interrupcion 21h
	;int 21h	            ;interrupcion 21h. Imprime cadena.
	mov cl,n2
	xor ch,ch
	sub cl,0030h
	sub cx,1
	cmp cx,1
	jz fac_1
loop_f:
	mov ax, cx
	mul cx
	add [resultado_f], ax
	loop loop_f

	mov al,[0000h]
	xor ah,ah
	mov bl,10d
	div bl
	mov [d1],al
	mov [d2],ah

	MOV AH,02H
	mov dl,0Ah
	INT 21H 	
	MOV DL,[d1]
	ADD DL,30H
	INT 21H
	MOV DL,[d2]
	ADD DL,30H
	INT 21H

	mov al,[0001h]
	xor ah,ah
	mov bl,10d
	div bl
	mov [d1],al
	mov [d2],ah

	MOV AH,02H
	mov dl,0Ah
	INT 21H 	
	MOV DL,[d1]
	ADD DL,30H
	INT 21H
	MOV DL,[d2]
	ADD DL,30H
	INT 21H
	jmp salir

fac_1:
	MOV AH,02H
	mov dl,0Ah
	INT 21H
	mov [resultado], 1 	
	MOV DL,[resultado]
	ADD DL,30H
	INT 21H
	jmp salir
				
e_igual:
	;lea dx,[igual]		;Obtiene posicion de memoria de la cadena que contiene la variable 'hola'
	;mov ax,0900h		;opcion 9 para interrupcion 21h
	;int 21h				;interrupcion 21h. Imprime cadena.
	MOV AH,02H
	mov dl,0Ah
	INT 21H
	mov [resultado], 1 	
	MOV DL,[resultado]
	ADD DL,30H
	INT 21H
	jmp salir


salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa

