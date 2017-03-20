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

BIT_VISIT       equ 3
BIT_DELETE      equ 7
NUM_TO_CLEAR    equ 4
DELETE_COLOR    equ 5
EMPTY_COLOR     equ 0
WALL_COLOR      equ 7
COLOR_BITS      equ 7
VISIBLE_END     equ 84

LEVEL_UP        equ 30
MAX_LEVEL       equ 10


WALL_LEFT       equ 0x08    ; cp c
WALL_RIGHT      equ 0x78    ; cp c
WALL_BOTTOM     equ 0xB0    ; cp b
HIDDEN_ROW      equ 0x00    ; cp b

BIT_P equ 7
BIT_H equ 4
BIT_J equ 3
BIT_D equ 2
BIT_S equ 1
BIT_A equ 0

BIT_UP      equ 7
BIT_RIGHT   equ 6
BIT_DOWN    equ 5
BIT_LEFT    equ 4

INPUT_LONG_DELAY equ 128
INPUT_SHORT_DELAY equ 16


KILL_LOCATION   equ 74  ; Based on byte representation

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
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00
    defb 0xff,0xff
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00
    defb 0xff,0xff
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00
    defb 0xff,0xff
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00
    defb 0xff,0xff
    ; has empty cell
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00
    defb 0xf6,0x00,0xa2,0x00,0xf6,0x00,0xa2,0x00,0x00,0x00
    defb 0xff,0xff
    defs 24,0xff

next_pair: defb 0

player_score: defs 3,0

high_score: defs 3,0

puyos_cleared: defb 0

is_paused: defb 0

; Drop variables
drop_timer: defb 0
drops_spawned: defb 0
current_level: defb 1

; Active airborne puyo pair
curr_pair: defb 43,%00000010    ; current pair position
prev_pair: defb 82,%00000011    ; previous position of current pair
pair_color: defb %00100001

; Input Variables
curr_input: defb 0
prev_input: defb 0              ; no buttons pressed at beginning
LR_timer: defb 0
D_timer: defb 0
rotate_timer: defb 0

; Clearing Variables
old_stack: defs 2, 0
curr_idx: defb 0
curr_addr: defs 2, 0
board_idx: defb 0
prev_matches: defs 4,0

clear_stack_space: defs 254,0   ; space for stack, as stack goes upwards
clear_stack: defs 2, 0

; Scoring Variables
cleared_colors: defb 0
cleared_count: defb 0
chain_count: defb 0

; Chain power table
; Used for scoring
chain_table:
    defw 4, 20, 24, 32, 48, 96, 160, 240, 320, 480, 700, 800, 900, 999

; Drop time table
; Defines number of frames before the puyo is dropped to the next half row
drop_table:
    defb 32, 32, 28, 25, 22, 20, 18, 15, 13, 11,  8
    ;Lv.  0   1   2   3   4   5   6   7   8   9  10

; Translation table from board position to pixel coordinates
board_to_coord_tab:
    defs 192,0xfb


