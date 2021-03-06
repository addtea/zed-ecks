#target tap

; sync bytes:
headerflag:     equ 0
dataflag:       equ 0xff

; some Basic tokens:
tCLEAR		equ     $FD             ; token CLEAR
tLOAD		equ     $EF             ; token LOAD
tCODE		equ     $AF             ; token CODE
tPRINT		equ     $F5             ; token PRINT
tRANDOMIZE	equ     $F9             ; token RANDOMIZE
tUSR		equ     $C0             ; token USR


pixels_start	equ	0x4000		; ZXSP screen pixels
attr_start	equ	0x5800		; ZXSP screen attributes
printer_buffer	equ	0x5B00		; ZXSP printer buffer
code_start	equ	32768           ; org 32768

; ---------------------------------------------------
;		a Basic Loader:
; ---------------------------------------------------

#code PROG_HEADER,0,17,headerflag
	defb    0
	defb    "mloader   "
	defw    variables_end-0
	defw    10
	defw    program_end-0

#code PROG_DATA,0,*,dataflag

; 10 CLEAR 32767
        defb    0,10                    ; line number
        defb    end10-($+1)             ; line length
        defb    0                       ; statement number
        defb    tCLEAR                  ; token CLEAR
        defm    "32767",$0e0000ff7f00   ; number 32767, ascii & internal format
end10:  defb    $0d                     ; line end marker

; 20 LOAD "" CODE 32768
        defb    0,20                    ; line number
        defb    end20-($+1)             ; line length
        defb    0                       ; statement number
        defb    tLOAD,'"','"',tCODE     ; token LOAD, 2 quotes, token CODE
        defm    "32768",$0e0000008000   ; number 32768, ascii & internal format
end20:  defb    $0d                     ; line end marker

; 30 RANDOMIZE USR 32768
        defb    0,30                    ; line number
        defb    end30-($+1)             ; line length
        defb    0                       ; statement number
        defb    tRANDOMIZE,tUSR         ; token RANDOMIZE, token USR
        defm    "32768",$0e0000008000   ; number 32768, ascii & internal format
end30:  defb    $0d                     ; line end marker

program_end:

variables_end:

; ---------------------------------------------------
;		a machine code block:
; ---------------------------------------------------

#code CODE_HEADER,0,17,headerflag
	defb    3			; Indicates binary data
	defb    "mcode     "	  	; the block name, 10 bytes long
	defw    code_end-code_start	; length of data block which follows
	defw    code_start		; default location for the data
	defw    0       		; unused


#code CODE_DATA, code_start,*,dataflag

