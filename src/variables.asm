

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

KILL_LOCATION   equ 37

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
    defs 24,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff
    defb 0xff,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff
    defb 0xff,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff
    defb 0xff,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff
    defb 0xff,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff
    defb 0xff,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff
    defb 0xf6,0xff,0xa2,0xff,0xf6,0xff,0xa2,0xff,0xf6,0xff
    defb 0xff,0xff
    defs 24,0xff

next_puyo: defs 2,0

player_score: defs 4,0

high_score: defs 4,0

puyos_cleared: defb 0

next_puyos: defb 0, 0

drop_timer: defb 0

current_speed: defb 0

; Active airborne puyo pair
curr_pair: defb 14,%00000000    ; current pair position
prev_pair: defb 82,%00000011    ; previous position of current pair
pair_color: defb %00100001

; Chain power table
; Used for scoring
chain_table:
    defw 4, 20, 24, 32, 48, 96, 160, 240, 320, 480, 700, 800, 900, 999

; Drop time table
; Defines number of frames before the puyo is dropped to the next half row
drop_table:
    defb 25, 23, 20, 16, 13, 10, 7

; Translation table from board position to pixel coordinates
board_to_coord_tab:
    defs 192,0xfb
