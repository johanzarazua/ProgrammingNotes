title "Hola mundo! Johan Zarazua" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
  .model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
  .386    ;directiva para indicar version del procesador
  .stack 64   ;Define el tamaño del segmento de stack, se mide en bytes
  .data   ;Definicion del segmento de datos
VA DB 0,0,0,0
  .code       ;segmento de codigo
inicio:         ;etiqueta inicio
  mov ax,@data    ;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
  mov ds,ax       ;DS = AX, inicializa segmento de datos

  MOV CX, 0125H
  MOV DX, 15ABH

  MOV [VA],CH
  MOV [VA + 1],CL
  MOV [VA + 2], DH
  MOV [VA + 3],DL



salir:          ;inicia etiqueta salir
  mov ah,4Ch      ;AH = 4Ch, opcion para terminar programa
  mov al,0      ;AL = 0, Exit Code, codigo devuelto al finalizar el programa
            ;AX es un argumento necesario para interrupciones
  int 21h       ;señal 21h de interrupcion, pasa el control al sistema operativo
  end inicio      ;fin de etiqueta inicio, fin de programa