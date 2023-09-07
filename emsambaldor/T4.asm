title "Tarea 4. Johan Zarazua" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386		;directiva para indicar version del procesador
	.stack 64 	;Define el tamaño del segmento de stack, se mide en bytes

;======================= DATOS =======================================================
	.data		;Definicion del segmento de datos
N1 dw 0FE13h, 0452h, 89D7h, 26C4h, 0DCB3h, 0CF97h, 45BDh, 0ADBCh ;ADBC 45BD CF97 DCB3 26C4 89D7 0452 FE13
N2 dw 87CDh, 0FDE1h, 417Bh, 0E307h, 0E163h, 435Fh, 96ACh, 0BDF3h  ;BDF3 96AC 435F E163 E307 417B FDE1 87CD
S  dw 0,0,0,0,0,0,0,0
SC db 0

;======================= CODIGO ======================================================
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
	mov cx, 8d
	mov bx, 0d

for1:
	mov ax,[N1 + bx]
	adc ax,[N2 + bx]
	mov [S + bx],ax
	inc bx
	inc bx
	loop for1
	ja e1
	jmp salir

e1:
	mov [SC],1d
	jmp salir

;====================== FIN =========================================================
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa