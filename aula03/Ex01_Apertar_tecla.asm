; =========================================================
; tecla_imprime.asm - Le 1 tecla e mostra qual foi a tecla
; Emu8086 - EXE Template
; =========================================================
;
; OBJETIVO
; - Ler um unico caractere do teclado (com eco) e imprimi-lo.
; - Mostrar como usar rotinas do DOS via INT 21h para E/S.
;
; ESTRUTURA DO PROGRAMA
; - .model small     : modelo de memoria "small" (codigo+dados <= 64KB).
; - .stack 100h      : reserva 256 bytes para a pilha.
; - .data            : segmento de dados (variaveis e strings).
; - .code / main     : segmento de codigo; ponto de entrada "main".
;
; VARIAVEIS (em .data)
; - prompt : string terminada em '$' para ser impressa com AH=09h.
; - voce   : prefixo "Voce apertou: " (tambem terminada em '$').
; - crlf   : string com CR (13) e LF (10) para pular linha (terminada em '$').
;13 (decimal) = 0Dh = CR (carriage return- volta o cursor para a coluna 0 da linha atual)
;10 (decimal) = 0Ah = LF (line feed- desce uma linha mantendo a coluna)
;
; REGISTRADORES MAIS IMPORTANTES NESTE EXEMPLO
; - AX : usado para carregar o segmento de dados (@data) e encerrar o programa.
; - DS : deve apontar para o segmento de dados antes de usar AH=09h (strings).
; - DX : carrega o endereco (offset) de uma string a ser impressa (AH=09h).
; - AH : seleciona a funcao do INT 21h (ex.: 09h, 01h, 02h, 4Ch).
; - AL : resultado de leitura de caractere (AH=01h retorna o ASCII em AL).
; - BL : registrador geral usado aqui para guardar temporariamente o caractere lido.
; - DL : caractere a ser impresso por AH=02h (1 caractere).
;
; ROTINAS DO DOS VIA INT 21h UTILIZADAS
; - AH=09h : imprime string terminada em '$' apontada por DS:DX.
; - AH=01h : le 1 caractere do teclado **com eco** e retorna o ASCII em AL.
; - AH=02h : imprime 1 caractere contido em DL.
; - AH=4Ch : encerra o programa (AL pode conter codigo de retorno, aqui 00).
;
; OBSERVACOES IMPORTANTES
; - Strings usadas por AH=09h DEVEM terminar com o caractere '$' (24h).
; - CR (13) e LF (10) sao usados para "quebrar a linha" no terminal.
; - Este exemplo NAO trata teclas estendidas; assume entrada ASCII simples. 


;INT 21h eh a porta de chamadas de sistema do DOS. 
;Voce coloca um numero de funcao em AH (e, as vezes, parametros em outros registradores)
;, executa int 21h, o DOS faz o servico e retorna para a proxima instrucao. 
;Nao encerra o programa, a menos que voce peca explicitamente a funcao de terminar 
;(ex.: AH=4Ch).
; =========================================================

.model small                 ; // modelo de memoria pequeno (codigo+dados ate 64KB)
.stack 100h                  ; // reserva 256 bytes para a pilha (stack)
.data                        ; // inicio do segmento de dados

prompt  db 'Pressione uma tecla ...',13,10,'$'   ; // mensagem inicial + CR/LF
voce    db 13,10,'Voce apertou: $'               ; // prefixo para a tecla lida
crlf    db 13,10,'$'                             ; // quebra de linha conveniente

.code                        ; // inicio do segmento de codigo
main proc                    ; // rotulo do ponto de entrada

    mov ax, @data            ; // AX <- base do segmento de dados (simbolo @data)
    mov ds, ax               ; // DS aponta para o segmento de dados (obrigatorio p/ AH=09h)

    mov dx, offset prompt    ; // DX <- endereco (offset) da string "prompt"
    mov ah, 09h              ; // AH=09h -> imprimir string ate encontrar '$'
    int 21h                  ; // chamada de sistema do DOS (saida de string)

    mov ah, 01h              ; // AH=01h -> ler 1 caractere do teclado (com eco)
    int 21h                  ; // AL recebe o ASCII da tecla pressionada
    mov bl, al               ; // BL <- guarda a tecla lida para usar depois

    mov dx, offset voce      ; // DX <- endereco da string "voce" (prefixo)
    mov ah, 09h              ; // AH=09h -> imprimir string ate '$'
    int 21h

    mov dl, bl               ; // DL <- caractere a imprimir (o que estava em BL)
    mov ah, 02h              ; // AH=02h -> imprimir 1 caractere contido em DL
    int 21h

    mov dx, offset crlf      ; // DX <- "\r\n" (CR/LF) para nova linha
    mov ah, 09h              ; // AH=09h -> imprimir string ate '$'
    int 21h

    mov ax, 4C00h            ; // AH=4Ch -> encerrar programa, AL=00 (codigo de retorno)
    int 21h                  ; // retorna ao DOS

main endp                    ; // fim do procedimento principal
end  main                    ; // fim do modulo: ponto de entrada e 'main'
