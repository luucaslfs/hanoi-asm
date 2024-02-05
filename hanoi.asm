section .data
    prompt db "Insira o num de discos(1-9): ", 0
    moveMsg db "Mover disco da Torre ", 0
    toMsg db " para Torre ", 0
    newline db 0xA, 0

section .bss
    num resb 1

section .text
global _start

_start:
    ; Solicita o número de discos ao usuário
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 29
    int 0x80

    ; Lê o número de discos
    mov eax, 3
    mov ebx, 0
    mov ecx, num
    mov edx, 1
    int 0x80

    ; Converte de ASCII para inteiro
    movzx eax, byte [num]
    sub eax, '0'

    ; Verifica se o número é válido
    cmp eax, 1
    jl _exit
    cmp eax, 9
    jg _exit

    ; Chama o procedimento recursivo
    push eax
    push 'C'
    push 'B'
    push 'A'
    call hanoi
    add esp, 16

_exit:
    ; Sai do programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

hanoi:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]  ; Número de discos
    cmp eax, 1
    jle fim_hanoi

    ; Mover n-1 discos do pino de origem para o pino auxiliar
    dec eax
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+20]
    push eax
    call hanoi
    add esp, 16

    ; Mover o disco do pino de origem para o pino de destino
    ; Código para imprimir o movimento aqui

    ; Mover n-1 discos do pino auxiliar para o pino de destino
    push dword [ebp+20]
    push dword [ebp+12]
    push dword [ebp+16]
    push eax
    call hanoi
    add esp, 16

fim_hanoi:
    mov esp, ebp
    pop ebp
    ret
