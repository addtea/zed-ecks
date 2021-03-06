begin_test:

rotate_ccw_test_1:
    ld a, 1                         ; test_1 = blue
    call 8859

    ld a, 18
    ld (curr_pair), a               ; check left wall kick
    ld a, 0x0
    ld (curr_pair+1), a

    call rotate_ccw
    ld a, (curr_pair)
    cp 30
    jp nz, test_fail

    ld a, (curr_pair+1)
    cp 0x3
    jp nz, test_fail

    ld a, (prev_pair)
    cp 18
    jp nz, test_fail

    ld a, (prev_pair+1)
    cp 0x0
    jp nz, test_fail

rotate_ccw_test_2:
    ld a, 3                         ; test_2 = magenta
    call 8859

    ld a, 34
    ld (curr_pair), a               ; check floor kick
    ld a, 0x3
    ld (curr_pair+1), a

    call rotate_ccw
    ld a, (curr_pair)
    cp 33
    jp nz, test_fail
    ld a, (curr_pair+1)
    cp 0x2
    jp nz, test_fail

    ld a, (prev_pair)
    cp 34
    jp nz, test_fail
    ld a, (prev_pair+1)
    cp 0x3
    jp nz, test_fail

rotate_ccw_test_3:
    ld a, 5                         ; test_3 = cyan
    call 8859

    ld a, 43
    ld (curr_pair), a               ; rotating down->right
    ld a, 0x2                       ; with a column of puyos directly right
    ld (curr_pair+1), a

    call rotate_ccw
    ld a, (curr_pair)
    cp 31
    jp nz, test_fail
    ld a, (curr_pair+1)
    cp 0x1
    jp nz, test_fail

    ld a, (prev_pair)
    cp 43
    jp nz, test_fail
    ld a, (prev_pair+1)
    cp 0x2
    jp nz, test_fail

rotate_ccw_test_4:
    ld a, 6                         ; test_4 = yellow
    call 8859

    ld a, 25                        ; rotation with no obstacles
    ld (curr_pair), a
    ld a, 0x3
    ld (curr_pair+1), a

    call rotate_ccw
    ld a, (curr_pair)
    cp 25
    jp nz, test_fail
    ld a, (curr_pair+1)
    cp 0x2
    jp nz, test_fail

    ld a, (prev_pair)
    cp 25
    jp nz, test_fail
    ld a, (prev_pair+1)
    cp 0x3
    jp nz, test_fail
test_end:                           ; green = success
    ld a, 4
    call 8859
    jp test_end

test_fail:
    jp test_fail

rotate_ccw:
    ld a, (curr_pair)               ; store curr location into previous
    ld (prev_pair), a
    ld a, (curr_pair+1)             ; get orientation
    cp 0x01                         ; if right, no checks needed
    jp z, rotate_ccw_end
    cp 0x00
rotate_ccw_u:
	jp nz,rotate_ccw_l
    ld a, (curr_pair)
    ld c, 12                        ; need to check left
    sub c
    ld c, a
    call get_puyo
    cp 0
    jp z, rotate_ccw_end
    ld hl, curr_pair                ; something exists, move right
    ld a, (hl)
    ld c, 12
    add a, c
    ld (hl), a

	jp rotate_ccw_end

rotate_ccw_l:
	cp 0x03
	jp nz,rotate_ccw_d

    ; check if puyo exists below
    ld a, (curr_pair)
    inc a                           ; get index of below
    ld c, a
    call get_puyo
    cp 0
    jp z, rotate_ccw_end      ; if nothing, rotation is fine
    ; something exists, need to shift puyo upward
    ; NOTE: This means players can keep rotating upward
    ; May cause strange issues unless we reset the drop timer
    ld hl, curr_pair
    dec (hl)
    jp rotate_ccw_end
rotate_ccw_d:
	; check if puyo exists to the right
    ld a, (curr_pair)
    ld c, 12
    add a, c
    ld c, a
    call get_puyo
    cp 0
    jp z, rotate_ccw_end      ; if nothing, rotation is fine
    ; something exists, need to shift curr_pair left
    ld hl, curr_pair
    ld a, (hl)
    ld c, 12
    sub c
    ld (hl), a

rotate_ccw_end:
	; 11->10->01->00->11
	; decrement last two bits
    ld hl, curr_pair
    inc hl                          ; hl now points to orientation byte
    ld a, (hl)
    ld (prev_pair+1), a             ; store old orientation
    dec a                           ; update orientation
    and 0x03
    ld (hl), a
	ret




get_puyo:
    ld hl, player_board
    ld b, 0
    sla c                           ; translate index to byte location
    add hl, bc                      ; point to spot
    ld a, (hl)                      ; load puyo
    ret

curr_pair: defb 43,%00000010    ; current pair position
prev_pair: defb 82,%00000011    ; previous position of current pair
pair_color: defb %00100001


player_board:
    defs 24,0xff
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00
    defb 0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00,0xff,0x00
    defb 0xff,0xff
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defs 24,0xff

