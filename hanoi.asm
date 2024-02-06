section .data
    prompt db "Insira o num de discos(1-9): ", 0  ; 
    moveMsg db "Mover disco da Torre ", 0         ; 
    toMsg db " para Torre ", 0                    ; 
    newline db 0xA, 0                             ; 

section .bss
    num resb 1                                    ; Reserva 1 byte de espaço para armazenar o número de discos

section .text
global _start                                    ; 

_start:
    ; Solicita o número de discos ao usuário
    mov eax, 4                                    ; syscall para sys_write
    mov ebx, 1                                    ; define o descritor de arquivo para stdout
    mov ecx, prompt                               ; endereço da string prompt para ser escrita
    mov edx, 29                                   ; tamanho da string prompt
    int 0x80                                      ; executa a syscall

    ; Lê o número de discos
    mov eax, 3                                    ; syscall para sys_read
    mov ebx, 0                                    ; define o descritor de arquivo para stdin
    mov ecx, num                                  ; endereço onde o input será armazenado
    mov edx, 1                                    ; número de bytes a serem lidos
    int 0x80                                      ; executa a syscall

    ; Converte de ASCII para inteiro
    movzx eax, byte [num]                         ; move o byte lido para eax com zero extend
    sub eax, '0'                                  ; subtrai '0' para converter de ASCII para inteiro

    ; Verifica se o número é válido
    cmp eax, 1                                    ; compara se o número é menor que 1
    jl _exit                                      ; se sim, salta para _exit
    cmp eax, 9                                    ; compara se o número é maior que 9
    jg _exit                                      ; se sim, salta para _exit

    ; Chama o procedimento recursivo
    push eax                                      ; empilha o número de discos
    push 'C'                                      ; empilha o identificador do pino destino
    push 'B'                                      ; empilha o identificador do pino auxiliar
    push 'A'                                      ; empilha o identificador do pino de origem
    call hanoi                                    ; chama a função hanoi
    add esp, 16                                   ; limpa a pilha após a chamada

_exit:
    ; Sai do programa
    mov eax, 1                                    ; syscall para sys_exit
    xor ebx, ebx                                  ; define o status de saída como 0
    int 0x80                                      ; executa a syscall

hanoi:
    push ebp                                      ; salva o base pointer atual na pilha
    mov ebp, esp                                  ; atualiza o base pointer para o topo da pilha

    mov eax, [ebp+8]                              ; move o número de discos para eax
    cmp eax, 1                                    ; verifica se é o caso base (1 disco)
    jle fim_hanoi                                 ; se sim, vai para fim_hanoi

    ; Mover n-1 discos do pino de origem para o pino auxiliar
    dec eax                                       ; decrementa eax (n-1)
    push dword [ebp+16]                           ; empilha pino auxiliar
    push dword [ebp+12]                           ; empilha pino de destino
    push dword [ebp+20]                           ; empilha pino de origem
    push eax                                      ; empilha n-1
    call hanoi                                    ; chama hanoi recursivamente
    add esp, 16                                   ; limpa a pilha

    ; Mover o disco do pino de origem para o pino de destino
    push dword [ebp+20]                           ; empilha pino de destino
    push dword [ebp+12]                           ; empilha pino de origem
    call imprime                                  ; chama a função para imprimir o movimento
    add esp, 8                                    ; limpa a pilha

    ; Mover n-1 discos do pino auxiliar para o pino de destino
    push dword [ebp+20]                           ; empilha pino de destino
    push dword [ebp+12]                           ; empilha pino de origem
    push dword [ebp+16]                           ; empilha pino auxiliar
    push eax                                      ; empilha n-1
    call hanoi                                    ; chama hanoi recursivamente
    add esp, 16                                   ; limpa a pilha

imprime:
    push ebp                                      ; salva o base pointer atual na pilha
    mov ebp, esp                                  ; atualiza o base pointer para o topo da pilha

    ; Imprime a mensagem de movimento
    mov eax, 4                                    ; syscall para sys_write
    mov ebx, 1                                    ; define o descritor de arquivo para stdout

    ; Imprime a torre de origem
    mov ecx, moveMsg                              ; endereço da mensagem de movimento
    mov edx, 23                                   ; comprimento da mensagem de movimento
    int 0x80                                      ; executa a syscall

    mov ecx, [ebp+8]                              ; endereço da torre de origem
    mov edx, 1                                    ; define o comprimento para 1
    int 0x80                                      ; executa a syscall

    ; Imprime ' para Torre '
    mov ecx, toMsg                                ; endereço da mensagem 'para Torre'
    mov edx, 13                                   ; comprimento da mensagem 'para Torre'
    int 0x80                                      ; executa a syscall

    ; Imprime a torre de destino
    mov ecx, [ebp+12]                             ; endereço da torre de destino
    mov edx, 1                                    ; define o comprimento para 1
    int 0x80                                      ; executa a syscall

    ; Imprime uma nova linha
    mov ecx, newline                              ; endereço da quebra de linha
    mov edx, 2                                    ; define o comprimento para 2
    int 0x80                                      ; executa a syscall

    pop ebp                                       ; restaura o base pointer anterior
    ret                                           ; retorna da função

fim_hanoi:
    mov esp, ebp                                  ; restaura o stack pointer
    pop ebp                                       ; restaura o base pointer anterior
    ret                                           ; retorna da função
