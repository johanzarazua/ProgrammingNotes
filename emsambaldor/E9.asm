title "Ejercicio 9 Johan Zarazua" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386		;directiva para indicar version del procesador
	.stack 64 	;Define el tamaño del segmento de stack, se mide en bytes
	.data		;Definicion del segmento de datos
n1 db 15
n2 db 16
mayor 	db		"El primer numero es mayor",0Dh,0Ah,"$"
menor 	db		"El segundo numero es mayor",0Dh,0Ah,"$"
igual 	db		"Los numeros son iguales",0Dh,0Ah,"$"
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
	mov ah,n1
	mov bh,n2

	cmp ah, bh
	je  e_igual
	jae e_mayor
	cmp bh, ah
	jae e_menor
 
 e_mayor:
	lea dx,[mayor]		;Obtiene posicion de memoria de la cadena que contiene la variable 'hola'
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.
	jmp salir

e_menor:
	lea dx,[menor]		;Obtiene posicion de memoria de la cadena que contiene la variable 'hola'
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h	            ;interrupcion 21h. Imprime cadena.
	jmp salir
				
e_igual:
	lea dx,[igual]		;Obtiene posicion de memoria de la cadena que contiene la variable 'hola'
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.
	jmp salir

salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa