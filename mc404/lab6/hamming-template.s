.globl _start

.data

input_buffer:   .skip 32
output_buffer:  .skip 32
    
.text
.align 4

@ Funcao inicial
_start:
    @ Chama a funcao "read" para ler 4 caracteres da entrada padrao
    ldr r0, =input_buffer
    mov r1, #5             @ 4 caracteres + '\n'
    bl  read
    mov r4, r0             @ copia o retorno para r4.

    @ Chama a funcao "atoi" para converter a string para um numero
    ldr r0, =input_buffer
    mov r1, r4
    bl  atoi

    @ Chama a funcao "encode" para codificar o valor de r0 usando
    @ o codigo de hamming.
    bl  encode
    mov r4, r0             @ copia o retorno para r4.
	
    @ Chama a funcao "itoa" para converter o valor codificado
    @ para uma sequencia de caracteres '0's e '1's
    ldr r0, =output_buffer
    mov r1, #7
    mov r2, r4
    bl  itoa

    @ Adiciona o caractere '\n' ao final da sequencia (byte 7)
    ldr r0, =output_buffer
    mov r1, #'\n'
    strb r1, [r0, #7]

    @ Chama a funcao write para escrever os 7 caracteres e
    @ o '\n' na saida padrao.
    ldr r0, =output_buffer
    mov r1, #8         @ 7 caracteres + '\n'
    bl  write

    @ Chama a funcao exit para finalizar processo.
    mov r0, #0
    bl  exit

@ Codifica o valor de entrada usando o codigo de hamming.
@ parametros:
@  r0: valor de entrada (4 bits menos significativos)
@ retorno:
@  r0: valor codificado (7 bits como especificado no enunciado).
encode:    
       push {r4-r11, lr}
       
       @ <<<<<< ADICIONE SEU CODIGO AQUI >>>>>>

       @ Separa os dados   r4<-d4   r5<-d3   r6<-d2   r7<-d1
       and  r4,r0,#0b1
       and  r5,r0,#0b10
       and  r6,r0,#0b100
       and  r7,r0,#0b1000
       lsr  r5,#1
       lsr  r6,#2
       lsr  r7,#3

       @ Calcula os bits de paridade p1<-r8   p2<-r9   p3<-r10
       eor  r8,r7,r6
       eor  r8,r8,r4
        
       eor  r9,r7,r5
       eor  r9,r7,r6

       eor  r10,r6,r5
       eor  r10,r10,r4

       @ Reseta o valor de r0
       mov  r0,#0

       @ Escreve o valor codificado  r8,r9,r7,r10,r6,r5,r4
       add  r0,r0,r8
       lsl  r0,#1
       add  r0,r0,r9
       lsl  r0,#1
       add  r0,r0,r7
       lsl  r0,#1
       add  r0,r0,r10
       lsl  r0,#1
       add  r0,r0,r6
       lsl  r0,#1
       add  r0,r0,r5
       lsl  r0,#1
       add  r0,r0,r4
        
       pop  {r4-r11, lr}
       mov  pc, lr

@ Decodifica o valor de entrada usando o codigo de hamming.
@ parametros:
@  r0: valor de entrada (7 bits menos significativos)
@ retorno:
@  r0: valor decodificado (4 bits como especificado no enunciado).
@  r1: 1 se houve erro e 0 se nao houve.
decode:    
       push {r4-r11, lr}

       @ p1,p2,d1,p3,d2,d3,d4
        
       @ Separa os dados   r4<-d4   r5<-d3   r6<-d2   r7<-d1   r8<-p1   r9<-p2   r10<-p3
       and  r4,r0,#0b1
       and  r5,r0,#0b10
       and  r6,r0,#0b100
       and  r10,r0,#0b1000 
       and  r7,r0,#0b10000
       and  r9,r0,#0b100000
       and  r8,r0,#0b1000000
       lsr  r5,#1
       lsr  r6,#2
       lsr  r10,#3
       lsr  r7,#4
       lsr  r9,#5
       lsr  r8,#6

       @ Salva o conteudo original
        
       @ Verifica se houve erro r11<-(1)erro ou (0)sem erro
       eor  r11,r7,r6
       eor  r11,r11,r4
       eor  r11,r11,r8 
       
       eor  r11,r7,r6
       eor  r11,r11,r4
       eor  r11,r11,r8

       eor  r11,r7,r6
       eor  r11,r11,r4
       eor  r11,r11,r8

       pop  {r4-r11, lr}
       mov  pc, lr

@ Le uma sequencia de bytes da entrada padrao.
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de bytes.
@  r1: numero maximo de bytes que pode ser lido (tamanho do buffer).
@ retorno:
@  r0: numero de bytes lidos.
read:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #0         @ stdin file descriptor = 0
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho maximo.
    mov r7, #3         @ read
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Finaliza a execucao de um processo.
@  r0: codigo de finalizacao (Zero para finalizacao correta)
exit:    
    mov r7, #1         @ syscall number for exit
    svc 0x0

@ Converte uma sequencia de caracteres '0' e '1' em um numero binario
@ parametros:
@  r0: endereco do buffer de memoria que armazena a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@ retorno:
@  r0: numero binario
atoi:
    push {r4, r5, lr}
    mov r4, r0         @ r4 == endereco do buffer de caracteres
    mov r5, r1         @ r5 == numero de caracteres a ser considerado 
    mov r0, #0         @ number = 0
    mov r1, #0         @ loop indice
atoi_loop:
    cmp r1, r5         @ se indice == tamanho maximo
    beq atoi_end       @ finaliza conversao
    mov r0, r0, lsl #1 
    ldrb r2, [r4, r1]  
    cmp r2, #'0'       @ identifica bit
    orrne r0, r0, #1   
    add r1, r1, #1     @ indice++
    b atoi_loop
atoi_end:
    pop {r4, r5, lr}
    mov pc, lr

@ Converte um numero binario em uma sequencia de caracteres '0' e '1'
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@  r2: numero binario
itoa:
    push {r4, r5, lr}
    mov r4, r0
itoa_loop:
    sub r1, r1, #1         @ decremento do indice
    cmp r1, #0          @ verifica se ainda ha bits a serem lidos
    blt itoa_end
    and r3, r2, #1
    cmp r3, #0
    moveq r3, #'0'      @ identifica o bit
    movne r3, #'1'
    mov r2, r2, lsr #1  @ prepara o proximo bit
    strb r3, [r4, r1]   @ escreve caractere na memoria
    b itoa_loop
itoa_end:
    pop {r4, r5, lr}
    mov pc, lr    
