.model small
.stack 100h
.data
    ball_x db 40
    ball_y db 12
    ball_dx db 1
    ball_dy db 1
    paddle1_y db 10
    paddle2_y db 10
    score1 db 0
    score2 db 0
.code
start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; Inicializa o modo de vídeo
    mov ax, 03h
    int 10h

    ; Desenha o campo
    call draw_field

    ; Loop principal do jogo
main_loop:
    call move_ball
    call move_paddles
    call check_collision
    call draw_screen
    jmp main_loop

draw_field:
    ; Desenha a borda superior
    mov cx, 80
    mov dh, 0
    mov dl, 0
draw_top_border:
    mov ah, 09h
    mov al, '-'
    mov bh, 0
    mov bl, 07h  ; Texto branco
    int 10h
    inc dl
    loop draw_top_border

    ; Desenha a borda inferior
    mov cx, 80
    mov dh, 24  ; Supondo que a altura da tela seja 25 linhas
    mov dl, 0
draw_bottom_border:
    mov ah, 09h
    mov al, '-'
    mov bh, 0
    mov bl, 07h  ; Texto branco
    int 10h
    inc dl
    loop draw_bottom_border

    ret

move_ball:
    ; Apaga a bola da posição atual
    mov ah, 02h
    mov bh, 0
    mov dh, ball_y
    mov dl, ball_x
    int 10h

    ; Atualiza a posição da bola
    mov al, ball_x
    add al, ball_dx
    mov ball_x, al
    mov al, ball_y
    add al, ball_dy
    mov ball_y, al

    ; Desenha a bola na nova posição
    mov ah, 02h
    mov bh, 0
    mov dh, ball_y
    mov dl, ball_x
    int 10h

    ret

move_paddles:
    ; Verifica a entrada do usuário para mover as raquetes
    mov ah, 01h
    int 16h
    jz no_key

    mov ah, 00h
    int 16h
    cmp al, 'w'
    je move_paddle1_up
    cmp al, 's'
    je move_paddle1_down
    cmp al, 72  ; Seta para cima
    je move_paddle2_up
    cmp al, 80  ; Seta para baixo
    je move_paddle2_down
    jmp no_key

move_paddle1_up:
    dec paddle1_y
    jmp no_key

move_paddle1_down:
    inc paddle1_y
    jmp no_key

move_paddle2_up:
    dec paddle2_y
    jmp no_key

move_paddle2_down:
    inc paddle2_y
    jmp no_key

no_key:
    ret

check_collision:
    ; Verifica colisão com a borda superior
    mov al, ball_y
    cmp al, 0
    jne check_bottom_border
    ; Inverte a direção vertical da bola
    neg ball_dy

check_bottom_border:
    ; Verifica colisão com a borda inferior
    mov al, ball_y
    cmp al, 24  ; Supondo que a altura da tela seja 25 linhas
    jne check_left_paddle
    ; Inverte a direção vertical da bola
    neg ball_dy

check_left_paddle:
    ; Verifica colisão com a raquete esquerda
    mov al, ball_x
    cmp al, 2  ; Supondo que a raquete esquerda esteja na coluna 2
    jne check_right_paddle
    mov al, ball_y
    cmp al, paddle1_y
    jb check_right_paddle
    cmp al, paddle1_y + 3  ; Supondo que a raquete tenha 4 linhas de altura
    ja check_right_paddle
    ; Inverte a direção horizontal da bola
    neg ball_dx

check_right_paddle:
    ; Verifica colisão com a raquete direita
    mov al, ball_x
    cmp al, 77  ; Supondo que a raquete direita esteja na coluna 77
    jne check_goal
    mov al, ball_y
    cmp al, paddle2_y
    jb check_goal
    cmp al, paddle2_y + 3  ; Supondo que a raquete tenha 4 linhas de altura
    ja check_goal
    ; Inverte a direção horizontal da bola
    neg ball_dx

check_goal:
    ; Verifica se a bola passou das raquetes (gols)
    mov al, ball_x
    cmp al, 0
    jne check_right_goal
    ; Incrementa o placar do jogador 2
    inc score2
    ; Reinicia a posição da bola
    mov ball_x, 40
    mov ball_y, 12
    mov ball_dx, 1
    mov ball_dy, 1
    jmp end_check_collision

check_right_goal:
    cmp al, 79  ; Supondo que a largura da tela seja 80 colunas
    jne end_check_collision
    ; Incrementa o placar do jogador 1
    inc score1
    ; Reinicia a posição da bola
    mov ball_x, 40
    mov ball_y, 12
    mov ball_dx, -1
    mov ball_dy, 1

end_check_collision:
    ret

draw_screen:
    ; Limpa a tela com fundo preto
    mov ax, 0600h
    mov bh, 07h  ; Fundo preto, texto branco
    mov cx, 0
    mov dx, 184Fh  ; 80 colunas, 25 linhas
    int 10h

    ; Desenha a raquete esquerda (verde)
    mov cx, 4
    mov dh, paddle1_y
    mov dl, 2
draw_paddle1:
    mov ah, 09h
    mov al, '|'
    mov bh, 0
    mov bl, 02h  ; Texto verde
    int 10h
    inc dh
    loop draw_paddle1

    ; Desenha a raquete direita (verde)
    mov cx, 4
    mov dh, paddle2_y
    mov dl, 77
draw_paddle2:
    mov ah, 09h
    mov al, '|'
    mov bh, 0
    mov bl, 02h  ; Texto verde
    int 10h
    inc dh
    loop draw_paddle2

    ; Desenha a bola (branca)
    mov ah, 09h
    mov al, 'O'
    mov bh, 0
    mov bl, 07h  ; Texto branco
    mov dh, ball_y
    mov dl, ball_x
    int 10h

    ret

    ; Finaliza o programa
    mov ax, 4C00h
    int 21h
end start
