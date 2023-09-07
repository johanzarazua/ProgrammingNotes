title "Ejercicio 1" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definicion de variables
MSG DB 10,13,'Hola!$'
MSG2 DB 10,13,'Este es un ejercicio de programacion en lenguaje ensamblador.$'
MSG3 DB 10,13,'Ahora puedo imprimir en pantalla! =)$'
MSG4 DB 10,13,'Fin.$'
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
;_______________________________________
;AQUI VA SU CODIGO
	MOV AH, 9     ; Funcion (Print String) Imprimir Cadena
	LEA DX, MSG   ; Obtiene la Direccion de "MSG"
	INT 21H       ; Ejecutar

	MOV AH, 9     ; Funcion (Print String) Imprimir Cadena
	LEA DX, MSG2   ; Obtiene la Direccion de "MSG"
	INT 21H       ; Ejecutar

	MOV AH, 9     ; Funcion (Print String) Imprimir Cadena
	LEA DX, MSG3   ; Obtiene la Direccion de "MSG"
	INT 21H       ; Ejecutar

	MOV AH, 9     ; Funcion (Print String) Imprimir Cadena
	LEA DX, MSG4   ; Obtiene la Direccion de "MSG"
	INT 21H       ; Ejecutar
;_______________________________________
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = [exCode] = 0 Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa