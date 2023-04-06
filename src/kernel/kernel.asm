; Copyright (C) 2023 name of 0x000000EF-0x000000EF

; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

; bootloader.asm (parent directory : bootmgr)
; Made by 0x000000EF
; salmOS bootloader code

org 0x7C00															; Code start address
bits 16																; 16 bits realmode
	
%define ENDL 0x0D, 0x0A 											; ENDL = end line = newline chracter 

start:

	; Jump to main label
	JMP main
	
; Prints some strings on screens
; Params:
; 	- ds:si point to string

print_str:
	; Save registers we will modify
	PUSH si
	PUSH ax
	PUSH bx

	; Get current cursur position
	MOV ah, 03h														; 03h -> get cursur position
	MOV bh, 0
	INT 10h
	MOV bx, ax														; Save current position in bx

.loop:
	; String print logic
	LODSB															; Load next charater (make esi pointer to direct next array element (DWORD))

	OR al, al														; If next character is null
	JZ .done														; End printing

	CMP al, 0x0A 													; If next chracter is newline
	JE .newline														; MOVe cursur to begining of next line

	; Otherwise, print chracter at current cusur position
	MOV ah, 0Eh 													; MOVe ah to 0Eh -> print to the screen in TTY mode
	MOV bh, 00h														; Set background color		
    INT 10h															; Make interupt with INT intrusion (string print interupt (10h or 0x10))

	JMP .loop														; If next chracter is not null, keep running

.newline:
	; MOVe cursur to beginning of next line
	INC dh															; Increment row by 1
	CALL set_cursur 
	JMP .loop
	
.done:
	; Function end logic
	; Pop all register that used in String print function
	POP bx
	POP ax
	POP si
	RET

clear_screen:
	; Clear Screen with soft wear bios interrupt
	MOV ah, 06h														; 06h -> scroll up screen
	MOV al, 00h 													; Number of line to MOVe/scroll
	MOV bh, 000Fh													; Set screen color 
	MOV ch, 0d														; Row start point
	MOV cl, 0d														; Col start point
	MOV dh, 24d														; Row end point
	MOV dl, 79d														; Col end point

	INT 10h

	; Set cursur at 0,0

	MOV bh, 0 														; Set page 0
	MOV dh, 0 														; Set row 0
	MOV dl, 0 														; Set col 0

	CALL set_cursur													; Set cursur												

	RET

; Set cursur function
; Params:
;  - bh, cl, dl
; each register take charge : page, row, col  

set_cursur:

	MOV ah, 02h														; 02h -> set cursur
	INT 10h															; Make video interupt

	RET

; Draw Salmon fillet pattern
; Params
;  - edi, bx
; each register take charge : pattern start point, how many pattern
; *WARNING!!!* 
; edi must be 0 or Even number

fillet_pattern: 
	
	MOV ax, 0xB800
	MOV es, ax

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0f

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0f

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0f

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0C

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0C

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0C

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0C

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0C

	INC edi

	MOV byte [es:edi], 0xDB

	INC edi

	MOV byte [es:edi], 0x0C

	INC edi

	DEC bx 

	JZ .done

	JMP fillet_pattern

.done:
	RET

main:
	; Setup data segment
	MOV ax, 0 														; Beacause ds & es can't be written value directly
	MOV ds, ax
	MOV es, ax

	; Setup stacks
	MOV ss, ax														; Stack segment init
	MOV sp, 0x7C00													; Stack pointer set in more detail stack grows downwards from we are loaded in memory -> set stack start address not to overwrite our OS code										

	; Clear all of screen
	CALL clear_screen
	

	; Set cursur
	MOV bh, 0
	MOV dh, 11
	MOV dl, 22
	CALL set_cursur

	; Print salmon pattern in boot screen
	MOV edi, 0
	MOV bx, 400
	CALL fillet_pattern

	; Print boot message
	MOV si, boot_msg1												; MOVe boot message to si to print boot_msg1
	CALL print_str													; Call string print function
	
	HLT 															; Halt cpu
	
.hlt_:
	; Halt logic
	JMP .hlt_														; Halt cpu as do inf loop


; Data Section
boot_msg1: DB 'starting salmOS - made by 0x000000EF',ENDL, 0 		; Declar String that include new line character(ENDL)
boot_msg2: DB 'starting...',ENDL, 0 		

TIMES 510-($-$$) DB 0 												; Generate a block of 0 byte that extends from current location in memory to the 510th byte in the 512-byte boot sector				
								
DW 0AA55h															; Bootable disk signature
