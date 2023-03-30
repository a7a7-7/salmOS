; bootloader.asm (parent directory : bootmgr)
; Made by 0x000000EF
; SalmOS code

org 0x7C00															; Code start address
bits 16															; 16 bits realmode
	
%define ENDL 0x0D, 0x0A 												; ENDL = end line = newline chracter 

start:

	JMP main
	

; Prints some strings on screens
; Params:
; 	- ds:si point to string

print_str:
	; Save registers we will modify
	PUSH si
	PUSH ax

.loop:
	; String print logic
	LODSB															; Load next charater (make esi pointer to direct next array element (DWORD))

	OR al, al														; If next character is null
	JZ .done														; End printing

	MOV ah, 0x0E													; Move ah to 0Eh -> print to the screen in TTY mode
	MOV bh, 00h														; Set background color		
    INT 10h															; Make interupt with INT intrusion (string print interupt (10h or 0x10))

	JMP .loop														; If next chracter is not null, keep running
	
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
	MOV al, 00h 													; Number of line to move/scroll
	MOV bh, 0CEh													; Set screen color 
	MOV ch, 0d														; Row start point
	MOV cl, 0d														; Col start point
	MOV dh, 24d														; Row end point
	MOV dl, 79d														; Col end point

	INT 10h

	; Set cursur at 0,0
	MOV bx, 00h
	MOV cx, 0d
	MOV dx, 0d

	call set_cursur

	RET

; Set cursur function
; Params:
;  - bx, cx, dx
; each register take charge page, row, col  

set_cursur:

	MOV ah, 02h
	MOV bh, bx
	MOV dh, cx
	MOV dl, dx

	INT 10h

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

	; Print boot message
	MOV si, boot_msg													; Move boot message to si to print Boot_msg 
	CALL print_str													; Call string print function	
	
	HLT 															; Halt cpu
	
.hlt_:

	JMP .hlt_														; Halt cpu as do inf loop


; Data Section
boot_msg: DB 'starting salmOS - made by 0x000000EF', ENDL, 0 						; Declar String that include new line character(ENDL)

TIMES 510-($-$$) DB 0
DW 0AA55h
