; Exemplo simples - Soma dois numeros e exibe o resultado
; Cada linha e comentada para ajudar no entendimento.

.model small         ; Define o modelo de memoria como "small" (pequeno), 
                     ; onde codigo e dados ficam em segmentos separados.
    
    
    
.stack 100h          ; Define a pilha com 256 bytes (100h em hexadecimal).
                     ; O 'h' indica que o numero esta no formato hexadecimal.
  
  
  
.data                ; Secao de dados - aqui definimos as variaveis.
    num1 db 5        ; Primeiro numero, definido como 5.
    num2 db 3        ; Segundo numero, definido como 3.
    resultado db 0   ; Variavel para armazenar o resultado da soma, inicialmente 0.
    msg db 'Resultado: $' ; Mensagem que sera exibida na tela.
                          ; O '$' no final indica o fim da string (necessario para o DOS).
  
  
  
  
.code                ; Secao de codigo - onde as instrucoes sao executadas.
start: 
    mov ax, @data    ; Carrega o endereco da secao de dados (@data) no registrador 'ax'.
    mov ds, ax       ; Move o valor de 'ax' para o registrador de segmento de dados 'ds'.
                     ; Isso inicializa o segmento de dados para acesso as variaveis.

    mov al, num1     ; Carrega o valor de 'num1' (5) no registrador 'al'.
    add al, num2     ; Soma o valor de 'num2' (3) ao valor que ja esta em 'al' (5).
                     ; Agora 'al' contem o resultado da soma (8).
     
     
    mov resultado, al ; Armazena o valor de 'al' (8) na variavel 'resultado'.
  
  
  
    ; Exibindo a string "Resultado: "
    mov ah, 09h      ; Carrega o codigo da funcao de interrupcao 09h do DOS em 'ah'.
                     ; Essa funcao exibe uma string na tela.

    lea dx, msg      ; Carrega o endereco da string 'msg' no registrador 'dx'.
                     ; O comando 'lea' (Load Effective Address) pega o endereco da variavel.

    int 21h          ; Executa a interrupcao 21h, que chama o servico do DOS para exibir a string.
                     ; A string "Resultado: " sera exibida na tela.
   
   
   
   
    ; Exibindo o numero do resultado
    mov ah, 02h      ; Carrega o codigo da funcao de interrupcao 02h do DOS em 'ah'.
                     ; Essa funcao exibe um unico caractere na tela.

    mov dl, resultado ; Carrega o valor do resultado (8) no registrador 'dl', 
                      ; que e usado para exibir o caractere.

    add dl, 30h      ; Converte o valor numerico (8) para o correspondente caractere ASCII.
                     ; '30h' e o valor ASCII do caractere '0', entao somamos para obter o caractere '8'.

    int 21h          ; Executa a interrupcao 21h novamente, agora para exibir o numero (caractere) na tela.
   
   
   
   
    ; Finalizando o programa
    mov ah, 4Ch      ; Carrega o codigo da funcao 4Ch do DOS, que encerra o programa.
    int 21h          ; Executa a interrupcao 21h para finalizar o programa.
  
  
  
end start            ; Indica o final do programa e define o ponto de entrada (start).
