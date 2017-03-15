

; ==================================================================
; FILE: layout.asm
; ------------------------------------------------------------------
;   Contains routines to draw entire screen layout and game area.
; ==================================================================


; ------------------------------------------------------------------
; init_title: Show title screen, play theme music.
; ------------------------------------------------------------------
; Input: None
; Output: None
; ------------------------------------------------------------------
; Registers polluted: a, b, c, d, e, h, l
; ------------------------------------------------------------------
init_title:
	call $0daf			    ; clear the screen.
	ld hl,title_graphic	    ; load title graphic data (top 2/3)
	ld de,16384             ; MAGIC - 0x4000
	ld bc,4096              ; copy 4096 bytes graphic data to screen
	ldir
	ld hl,title_attribute   ; load title attr
	ld	de,22528		    ; MAGIC
	ld bc,512			    ; copy 512 bytes of attr only
	ldir
    ret

; ------------------------------------------------------------------
; init_background: Draw initial background with play area.
; ------------------------------------------------------------------
; Input: None
; Output:
; ------------------------------------------------------------------
; Registers polluted: a, b, c, d, e, h, l
; ------------------------------------------------------------------
init_background:
    ld a,BACKGROUND_ATTR            ; load gameplay background attribute
    ld (23693),a                    ; set our screen colours.
    call 3503                       ; clear the screen.
    ld a,2                          ; 2 = upper screen.
    call 5633                       ; open channel.
    ld hl,background_data           ; fill entire screen with background
    call fill_screen_data
    ld bc,PREVIEW_COORDS_TOP        ; clear preview area
    call erase_puyo_2x2
    ld bc,PREVIEW_COORDS_TOP
    ld hl,puyo_none
    call load_2x2_data
    ld bc,PREVIEW_COORDS_BOTTOM
    call erase_puyo_2x2
    ld bc,PREVIEW_COORDS_BOTTOM
    ld hl,puyo_none
    call load_2x2_data
    ld bc,TOPLEFT_VISIBLE           ; clear play area
init_background_clear:
    ld hl,TOTAL_ROWS+TOTAL_ROWS-4   ; push loop counter = (visible rows)*2
    push hl
init_background_clear_loop:
    call get_attr_address           ; get attr addr of left cell
    ld h,TOTAL_COLUMNS+TOTAL_COLUMNS-5  ; column counter = (visible cols)*2-1
    xor a
    ld (de),a
init_background_clear_row_loop:
    inc de
    ld (de),a
    dec h
    cp h
    jp nz,init_background_clear_row_loop
    ld a,8
    add a,b
    ld b,a
    pop hl
    dec hl
    push hl
    xor a
    cp l
    jp nz,init_background_clear_loop
    pop hl
    ret

; ------------------------------------------------------------------
; TODO: score layout
; ------------------------------------------------------------------
; Input:
; Output:
; ------------------------------------------------------------------
; Registers polluted:
; ------------------------------------------------------------------

; ------------------------------------------------------------------
; draw_curr_pair: Update current airborne puyo pair on the screen
; ------------------------------------------------------------------
; Input: None
; Output: Erase previous position, draw new position of puyo pair
; ------------------------------------------------------------------
; Registers polluted: a, b, c, d, e, h, l
; ------------------------------------------------------------------
; Note: This routine assumes that the puyo positions are valid,
;       although it will check for hidden row.
; ------------------------------------------------------------------
draw_curr_pair:
    ; push coordinates: curr pivot, curr 2nd, prev pivot, prev 2nd
    ld d,2
    ld hl,curr_pair+1       ; get current position info
    ld a,(hl)
    push af
    dec hl
draw_curr_pair_calc:
    ld a,(hl)
    ld c,a                  ; calculate coord of pivot & push
    ld b,0
    call get_board_to_coord
    call is_wall_hidden            ; check if pivot is wall
    cp 0
    jp z,draw_curr_pair_push_1  ; if not wall, push normally, else push 0xffff
    ld bc,0xffff
draw_curr_pair_push_1:
    pop af
    push bc
    and %00000011           ; calculate coord of 2nd
    ld e,a
    ld a,0x03
    cp e
    jp z,draw_curr_pair_left
    dec a
    cp e
    jp z,draw_curr_pair_down
    dec a
    cp e
    jp z,draw_curr_pair_right
draw_curr_pair_up:          ; b-16
    ld a,b
    ld e,16
    sub e
    ld b,a
    jp draw_curr_pair_wall_check
draw_curr_pair_right:       ; c+16
    ld a,16
    add a,c
    ld c,a
    jp draw_curr_pair_wall_check
draw_curr_pair_down:        ; b+16
    ld a,16
    add a,b
    ld b,a
    jp draw_curr_pair_wall_check
draw_curr_pair_left:        ; c-16
    ld a,c
    ld e,16
    sub e
    ld c,a

draw_curr_pair_wall_check:  ; if current cell is wall or hidden, push 0xffff
    call is_wall_hidden
    cp 0
    jp z,draw_curr_pair_push_2  ; if not wall, push normally, else push 0xffff
    ld bc,0xffff
draw_curr_pair_push_2:
    push bc
    ld hl,prev_pair+1
    ld a,(hl)
    push af
    dec hl
    xor a
    dec d
    cp d
    jp nz,draw_curr_pair_calc
    pop af

    ; finished pushing, pop to erase and draw next
    pop bc                  ; erase previous position first
    ld a,0xff
    cp b
    jp z,draw_curr_pair_erase_skip_1   ; if wall, ignore
    call erase_puyo_2x2
draw_curr_pair_erase_skip_1:
    pop bc
    ld a,0xff
    cp b
    jp z,draw_curr_pair_erase_skip_2   ; if wall, ignore
    call erase_puyo_2x2
draw_curr_pair_erase_skip_2:
    pop bc
    ld a,0xff
    cp b
    jp z,draw_curr_pair_draw_skip_1
    ld a,(pair_color)       ; draw curr 2nd puyo
    and 0x07
    or %01000000
    ld l,a
    push bc
    call load_2x2_attr
    pop bc
    ld hl,puyo_none
    call load_2x2_data
draw_curr_pair_draw_skip_1:
    pop bc
    ld a,0xff
    cp b
    jp z,draw_curr_pair_draw_skip_2
    ld a,(pair_color)       ; draw curr pivot puyo
    srl a
    srl a
    srl a
    or %01000000
    ld l,a
    push bc
    call load_2x2_attr
    pop bc
    ld hl,puyo_none
    call load_2x2_data
draw_curr_pair_draw_skip_2:
    ret

; ------------------------------------------------------------------
; refresh_board: update play area from board map
; ------------------------------------------------------------------
; Input: None
; Output: all cell pixel data & attr in play area updated
; ------------------------------------------------------------------
; Registers polluted: a, b, c, d, e, h, l
; ------------------------------------------------------------------
refresh_board:
    ld bc,TOPLEFT_VISIBLE   ; clear play area
    call init_background_clear

    ld de,0xffff            ; push stack end marker
    push de
    ld c,BOARD_SIZE         ; setup initial counter and values
    ld b,13                 ; row counter -- to ignore hidden row
    ld e,0                  ; position index
    ld hl,player_board
refresh_board_write:        ; read all cell values, push existing ones to stack
    xor a                   ; clear a for comparison
    dec b                   ; decrement row counter, check for hidden row
    cp b
    jp z,refresh_board_hidden   ; if hidden row, do not push, refresh b
    ld d,(hl)               ; load current map cell
    ld a,d
    and 0x07
    jp z,refresh_board_next ; if cell empty, do not push
    xor 0x07
    jp z,refresh_board_next ; if cell is wall, do not push
refresh_board_push:
    push de                 ; push: cell value (d) & position number (e)
    ld a,d                  ; push: attribute (d) & position (e)
    and 0x07                ; color
    or 0x40                 ; set to bright
    ld d,a
    push de
    jp refresh_board_next
refresh_board_hidden:
    ld b,TOTAL_ROWS
refresh_board_next:
    inc hl                  ; increment pointer to cell in boardmap
    inc hl
    inc e                   ; increment position index
    xor a
    dec c                   ; decrement cell counter, check if reached last cell
    cp c
    jp nz,refresh_board_write

refresh_board_read:
    pop de                  ; pop values, compare to 0xff
    ld a,0xff
    cp e
    jp z,refresh_board_done
refresh_board_draw:
    ld b,0                  ; put coordinates in bc
    ld c,e
    call get_board_to_coord
    push bc
    ld l,d
    call load_2x2_attr
    pop bc
    pop de                  ; calculate sprite address
    ld a,d                  ; should be puyo_none + orientation*32
    and 0xf0
    sla a
    ld e,a
    ld a,d
    ld d,0
    and 0x80
    cp 0
    jp z,refresh_board_calc
    ld d,1
refresh_board_calc:
    ld hl,puyo_none
    add hl,de
    call load_2x2_data      ; draw puyo
    jp refresh_board_read   ; repeat until stack marker reached
refresh_board_done:
    ret

; ------------------------------------------------------------------
; is_wall_hidden: check if given board coordinates are wall/hidden
; ------------------------------------------------------------------
; Input: bc - coordinates (as given by get_board_to_coord)
; Output: e - zero if not wall/hidden, 0xff otherwise
; ------------------------------------------------------------------
; Registers polluted: a
; ------------------------------------------------------------------
is_wall_hidden:
    ld a,WALL_LEFT
    cp c
    jp z,is_wall_hidden_true
    ld a,WALL_RIGHT
    cp c
    jp z,is_wall_hidden_true
    ld a,WALL_BOTTOM
    cp b
    jp z,is_wall_hidden_true
    ld a,HIDDEN_ROW
    cp b
    jp z,is_wall_hidden_true
    ld a,0
    ret
is_wall_hidden_true:
    ld a,0xff
    ret

; ------------------------------------------------------------------
; drop_floats: drop all floating puyo down
; ------------------------------------------------------------------
; Input: None
; Output: puyo dropped with animation (delay),
;         player_board updated with all puyos settled
; ------------------------------------------------------------------
; Registers polluted: a, b, c, d, e, h, l
; ------------------------------------------------------------------
drop_floats:
    ; read the boardmap from bottom right visible cell, push & mark on boardmap
    ld hl,player_board+83+83
    ld c,83
    ld b,0
    ld e,TOTAL_ROWS
drop_floats_read:
    ld a,11                     ; check if finished top left cell
    cp c
    jp z,drop_floats_animate
    dec c
    dec hl
    dec hl
    dec e                       ; check if finished column
    xor a
    cp e
    jp z,drop_floats_read_wall
    ld a,(hl)                   ; read current cell
    and 0x07
    ld d,a
    xor a
    cp d
    jp nz,drop_floats_occupied  ; if cell occupied, don't inc space counter
    inc b                       ; if space, inc space count, go to next cell
    jp drop_floats_read
drop_floats_occupied:
    xor a
    cp b
    jp z,drop_floats_read       ; if already settled, skip
    ld a,b                      ; mark # of spaces to drop on boardmap
    and 0x0f
    inc hl
    ld (hl),a
    dec hl
    jp drop_floats_read
drop_floats_read_wall:
    ld e,TOTAL_ROWS
    ld b,0
    jp drop_floats_read

drop_floats_animate:
    ; finish reading all board, start animation
    ; hl - cell address in boardmap
    ; bc - cell coordinates
    ; de - floating cell count
    ; d - space count (cell 2nd byte)
    ld de,0xffff                ; push marker to indicate first run
    push de
    ld hl,player_board+22+22+1  ; start animation from bottom row
    ld bc,0xa018
drop_floats_animate_loop:
    ld a,0x78                   ; check if finished row
    cp c
    jp z,drop_floats_animate_wall_right
    ld d,(hl)                   ; load space count
    xor a
    cp d
    jp z,drop_floats_animate_next_cell  ; if zero, skip
    pop de                      ; check floating cell count
    ld a,0xff
    cp e
    jp z,drop_floats_animate_reset_count
drop_floats_animate_inc_count:  ; if not sentinel, increment
    inc de
    ld a,0xfa
    jp drop_floats_animate_process
drop_floats_animate_reset_count:    ; if sentinel, set to 1
    ld de,1
    ld a,0xfb
drop_floats_animate_process:
    push de                     ; push floating cell count
    push bc                     ; push current cell coordinates
    push hl                     ; push current cell 2nd byte addr
    push hl                     ; push current cell 2nd byte addr
    xor a                       ; check if hidden row
    cp b
    jp z,drop_floats_animate_draw   ; if is, don't erase
    push bc
    call erase_puyo_2x2         ; else erase position
    pop bc
drop_floats_animate_draw:
    pop hl                      ; pop current cell 2nd byte addr
    dec hl                      ; get cell color, load attr at bottom cell
    ld a,(hl)
    and 0x07
    or %01000000
    ld l,a
    ld a,16
    add a,b
    ld b,a
    push bc                     ; push bottom cell coordinates
    call load_2x2_attr
    pop bc                      ; pop bottom cell coordinates to draw puyo
    ld hl,puyo_none
    call load_2x2_data
    pop hl                      ; pop current cell 2nd byte addr
    dec hl                      ; load current cell color
    ld a,(hl)
    and 0x07
    ld (hl),0                   ; clear current cell color
    inc hl                      ; get space count of current byte
    ld d,(hl)
    inc hl                      ; store current color into bottom cell
    ld (hl),a
    inc hl
    dec d                       ; dec space count, write to bottom cell
    ld (hl),d
    dec hl
    dec hl
    ld (hl),0                   ; clear space count of this cell
    pop bc                      ; pop current cell coordinates
drop_floats_animate_next_cell:
    ld a,16                     ; go to next cell on the right
    add a,c
    ld c,a
    ld de,TOTAL_ROWS+TOTAL_ROWS
    add hl,de
    jp drop_floats_animate_loop
drop_floats_animate_wall_right:
    xor a                       ; check if finished hidden row
    cp b
    jp z,drop_floats_animate_loopback
    ; delay
    push bc                     ; push current cell coordinates
    ld b,DROP_FLOATS_DELAY
    xor a
drop_floats_animate_delay:
    dec b
    cp b
    jp nz,drop_floats_animate_delay
    pop bc                      ; pop current cell coordinates
    ; end delay
    ld a,b                      ; move bc to beginning of next row
    ld b,16
    sub b
    ld b,a
    ld c,0x18
    ld de,73+73                 ; distance b/t right wall cell & first visible
    sbc hl,de                   ;   cell on the next row
    jp drop_floats_animate_loop
drop_floats_animate_loopback:
    pop de
    ld a,0xff
    cp e
    jp nz,drop_floats_animate   ; loopback if not done
    ret

; ------------------------------------------------------------------
; draw_preview: display preview of next puyo pair
; ------------------------------------------------------------------
; Input: None
; Output: Next pair color displayed next to play area.
; ------------------------------------------------------------------
; Registers polluted: a, b, c, d, e, h, l
; ------------------------------------------------------------------
draw_preview:
    ld hl,next_pair             ; get colors
    ld a,(hl)
    srl a
    srl a
    srl a
    and 0x07
    or 0x40
    push af
    ld a,(hl)
    and 0x07
    or 0x40
    ld l,a
    ld bc,PREVIEW_COORDS_TOP
    call load_2x2_attr
    pop af
    ld l,a
    ld bc,PREVIEW_COORDS_BOTTOM
    call load_2x2_attr
    ret

