; ==================================================================
; FILE: variables.asm
; ------------------------------------------------------------------
;   Contains macros and variables used across the whole project.
; ==================================================================

; ------------------------------------------------------------------
; Macros/Constants
; ------------------------------------------------------------------

TOPLEFT_HIDDEN  equ 0x0008
TOPLEFT_VISIBLE equ 0x1018
TOTAL_ROWS      equ 12
TOTAL_COLUMNS   equ 8
BOARD_SIZE      equ 96

WALL_LEFT       equ 0x08    ; cp c
WALL_RIGHT      equ 0x78    ; cp c
WALL_BOTTOM     equ 0xB0    ; cp b
HIDDEN_ROW      equ 0x00    ; cp b

KILL_LOCATION   equ 74  ; Based on byte representation

DROP_FLOATS_DELAY   equ 191

; Puyo Pairs
; In order:
; BB,BR,BG,BY,RB,RR,RG,RY,GB,GR,GG,GY,YB,YR,YG,YY
; Storage Format:
; 00AAABBB -> A is first color, B is second color
PUYO_PAIRS:
    defb 0x09, 0x0A, 0x0C, 0x0E
    defb 0x11, 0x12, 0x14, 0x16
    defb 0x21, 0x22, 0x24, 0x26
    defb 0x31, 0x32, 0x34, 0x36

EMPTY_BOARD:
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
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defs 24,0xff

; ------------------------------------------------------------------
; Graphics Attributes
; ------------------------------------------------------------------

BACKGROUND_ATTR     equ 3
PUYO_BLUE           equ 65
PUYO_RED            equ 66
PUYO_GREEN          equ 68
PUYO_YELLOW         equ 70

val_puyo_blue:      defb 65
val_puyo_red:       defb 66
val_puyo_green:     defb 68
val_puyo_yellow:    defb 70

; ------------------------------------------------------------------
; Variables/Tables
; ------------------------------------------------------------------

player_board:
    ;defs 192,0
    defs 24,0xff
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00
    defb 0xff,0xff
    ; has empty cell
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    ; has empty cell
    defb 0xf6,0x00,0xa2,0x00,0x00,0x00,0x00,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00
    defb 0xff,0xff
    ; has empty cell
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0x00,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    defb 0xff,0xff
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00
    defb 0xff,0xff
    defs 24,0xff

next_pair: defs 2,0

player_score: defs 4,0

high_score: defs 4,0

puyos_cleared: defb 0

next_puyos: defb 0, 0

drop_timer: defb 0

current_speed: defb 0

; Active airborne puyo pair
curr_pair: defb 43,%00000010    ; current pair position
prev_pair: defb 82,%00000011    ; previous position of current pair
pair_color: defb %00100001

; Chain power table
; Used for scoring
chain_table:
    defw 4, 20, 24, 32, 48, 96, 160, 240, 320, 480, 700, 800, 900, 999

; Drop time table
; Defines number of frames before the puyo is dropped to the next half row
drop_table:
    defb 32, 23, 20, 16, 13, 10, 7

; Translation table from board position to pixel coordinates
board_to_coord_tab:
    defs 192,0xfb


