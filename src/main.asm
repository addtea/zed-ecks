
; ------------------------------------------------------------------
; Main test driver
; ------------------------------------------------------------------
    call populate_coord_tab ; begin game setup
    ;call init_title         ; load title screen
    ;call start_theme_music  ; play title music
    call init_background    ; load play area layout

    ; test draw_curr_pair with input
    ;call reset_board
    ;call draw_curr_pair
    ;call inf_loop

    call gen_puyos
    call draw_preview
    call drop_floats
    call connect_puyos
    call refresh_board
    call check_clears
    call clear_puyos
    call refresh_board
    call draw_curr_pair
    ;call write_pair_to_board

inf_loop:                   ; infinite loop to not exit program
    ;call play_check_input
    ;ld c,PRESS_DELAY
    ;call blink_delay
    jp inf_loop

; ------------------------------------------------------------------
; Test drop loop (no user input, new board representation)
; ------------------------------------------------------------------
test_init:
    ld a,25
    ld (drop_timer),a
test_play_drop_loop:


; ------------------------------------------------------------------
; Main Game Loop
; ------------------------------------------------------------------

play_init:
    call reset_game
    call gen_puyos

play_main_loop:
    call gameover_detect
    cp 0
    jp nz, gameover
    call spawn_puyos
    call reset_drop_timer

play_drop_loop:
    ;call redraw_board          ; update the board with the new puyos
    call play_check_input       ; move or rotate the puyo if required

    ld hl, (drop_timer)         ; update timer
    dec hl
    ld (drop_timer), hl
    cp 0
    call z, check_active_below  ; check if next row is occupied
    cp 0
    jp z, play_drop_loop        ; puyo hasn't moved down a row yet


    ; puyo has stopped
    ; drop remaining floating puyos
    call drop_floats

play_clear_loop:            ; start clearing chain
    call process_clears
    cp 0
    jp nz, play_clear_loop
    jp play_main_loop

reset_game:
    ret
