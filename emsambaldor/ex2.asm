title "Examen 2. Zarazua Johan" 
	.model small 
	.386		
	.stack 64
	.data
i    dw 0
i_p  dw 1

p    dw 3
p_i  dw 0
i_cuad dw 0
o_dos dw 0
tres dw 3d
dos dw 2d
divis dw 0
o_tres dw 0 

r dw  0,0,0,0,0,0,0,0,0,0
	.code
inicio:
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,AX           ;DS = AX, inicializa segmento de datos		

operacion:
	cmp i, 0
	jz potencia_cero
	cmp i, 1
	jz potencia_uno

	mov [p],3
potencia:
	mov cx,i_p
	cmp cx, i
	jz  ope_dos
	mov ax,3d
	mul [p]
	mov [p],ax
	inc i_p
	jmp potencia

potencia_cero:
	mov [p],1d
	jmp ope_dos

potencia_uno:
	mov [p],3d
	jmp ope_dos

ope_dos:
	mov i_p,1

	mov ax, i
	mul i
	mov [p_i],ax
	mov ax, [p_i]
	mul i 
	mov [p_i],ax
	mov ax, [p_i]
	mul [tres]
	mov [o_dos], AX


	mov ax, i
	mul i
	mov [i_cuad], AX
	mov ax,[i_cuad]
	div [dos]

	xor ah,ah
	mov [divis], ax

	mov ax,5
	mul i
	mov [o_tres], AX


	mov ax,[p]
	add ax,[o_dos]
	sub ax,[divis]
	add ax,[o_tres]

	mov [r+bx],ax
	inc bx
	inc bx
	cmp i, 10d
	jz salir
	inc i
	jmp operacion

salir:
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa