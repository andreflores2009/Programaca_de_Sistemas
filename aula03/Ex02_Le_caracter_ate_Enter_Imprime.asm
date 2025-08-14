; ================================================================
; eco_linha.asm - Le caracteres ate ENTER e imprime a linha de volta
; Emu8086 - EXE Template
; ================================================================
;
; OBJETIVO
; - Ler varios caracteres do teclado (um por vez, com eco) ate o usuario
;   pressionar ENTER (CR = 13 decimal) e depois imprimir a linha digitada.
;
; VISAO GERAL DO FLUXO
; 1) Mostra um prompt de entrada (INT 21h, AH=09h).
; 2) Entra em um laco (read_loop):
;    - Le 1 caractere com eco (INT 21h, AH=01h) -> retorno vem em AL.
;    - Se AL == 13 (ENTER), encerra a leitura.
;    - Caso contrario, armazena AL no buffer e avanca o indice (SI).
;    - Protege contra overflow do buffer (limite 119, pois 1 byte e do '$').
; 3) Ao finalizar a leitura, grava '$' no fim do buffer para usar AH=09h.
; 4) Imprime o prefixo "Voce digitou: " (AH=09h).
; 5) Imprime o conteudo do buffer (AH=09h).
; 6) Imprime CR/LF (quebra de linha) usando a string crlf (AH=09h).
; 7) Encerra o programa com AH=4Ch.
;
; VARIAVEIS (segmento .data)
; - msgIn  : string terminada com '$' para o prompt inicial.
; - msgOut : string com CR, LF e o prefixo "Voce digitou: " (terminada em '$').
; - buf    : buffer de 120 bytes para armazenar os caracteres digitados.
; - crlf   : string contendo CR (13), LF (10) e '$' para pular linha facilmente.
;
; POR QUE AS STRINGS TERMINAM COM '$'
; - A rotina de impressao INT 21h, AH=09h le bytes a partir de DS:DX
;   ate encontrar o caractere '$' (24h). Por isso, toda string exibida
;   por AH=09h precisa terminar com '$'.
;
; REGISTRADORES UTILIZADOS
; - AX : configurar DS com @data (mov ax, @data) e encerrar (AX=4C00h).
; - DS : deve apontar para o segmento de dados ao usar AH=09h.
; - DX : recebe o offset (endereco) da string a ser impressa com AH=09h.
; - SI : indice do proximo byte livre dentro de buf (buf[SI]).
; - AH : seleciona a funcao do INT 21h (01h, 09h, 4Ch).
; - AL : recebe o caractere lido por AH=01h (caractere ASCII).
;
; CONTROLE DE FIM DE LINHA
; - ENTER corresponde ao caractere CR (Carriage Return) = 13 decimal (0Dh).
; - No laco, se AL == 13, finalizamos a leitura e colocamos '$' no fim do buf.
;
; PROTECAO CONTRA OVERFLOW
; - O buffer tem 120 bytes. Usamos ate o indice 119 para dados e reservamos
;   1 byte final para o '$'. Logo, quando SI chegar a 119, paramos de ler. 
;O ? significa “sem inicializacao” (valor indefinido em tempo de execucao).

;db 120 dup(?) cria 120 bytes de espaco no segmento de dados, 
;sem gravar nenhum valor neles no arquivo objeto.

;
; OBSERVACOES
; - Este exemplo NAO trata teclas estendidas; assume entrada ASCII simples.
; - Se voce quiser ler uma linha "de uma vez so", poderia usar INT 21h AH=0Ah,
;   que preenche um buffer no formato do DOS (primeiro byte = tamanho max,
;   segundo byte = tamanho lido, seguido pelos caracteres). Aqui fazemos
;   leitura caractere-a-caractere para fins didaticos.
; ================================================================

; -----------------------------------------------------------------
; eco_linha.asm - Le caracteres ate ENTER e imprime a linha de volta
; Emu8086 - EXE Template
; -----------------------------------------------------------------

.model small                       ; // modelo de memoria pequeno
.stack 100h                        ; // pilha de 256 bytes
.data                              ; // segmento de dados

msgIn   db 'Digite uma linha e pressione ENTER:',13,10,'$' ; // prompt
msgOut  db 13,10,'Voce digitou: $'                         ; // prefixo
buf     db 120 dup (?)                                      ; // buffer p/ ate 120 chars
crlf    db 13,10,'$'                                        ; // quebra de linha

.code
main proc

    mov ax, @data                  ; // carrega base do segmento de dados
    mov ds, ax                     ; // DS aponta p/ dados

    mov dx, offset msgIn           ; // mostra o prompt de entrada
    mov ah, 09h
    int 21h

    xor si, si                     ; // SI = 0 (colocar no indice zero do buffer)

read_loop:
    mov ah, 01h                    ; // AH=01h -> ler 1 caractere (com eco)
    int 21h                        ; // AL = caractere ASCII
    cmp al, 13                     ; // ENTER? (ASCII 13 = CR)
    je  finish_read                ; // se sim, sai do laco

    mov buf[si], al                ; // armazena caractere no buffer
    inc si                         ; // avanca o indice
    cmp si, 119                    ; // protege contra overflow (119 max, deixa 1 p/ '$')
    jb  read_loop                  ; // jb=Jump if Below, se ainda cabe, se si<119, continua lendo
    ; se encher o buffer, para de ler como se fosse ENTER
    jmp finish_read                ; // sai

finish_read:
    mov byte ptr buf[si], '$'      ; // termina a string com '$' p/ AH=09h

    mov dx, offset msgOut          ; // imprime prefixo "Voce digitou: "
    mov ah, 09h
    int 21h

    mov dx, offset buf             ; // imprime o conteudo digitado
    mov ah, 09h
    int 21h

    mov dx, offset crlf            ; // nova linha
    mov ah, 09h
    int 21h

    mov ax, 4C00h                  ; // encerra programa
    int 21h

main endp
end main
