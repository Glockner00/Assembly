;
; AssemblerApplication2.asm
;
; Created: 4/17/2023 12:30:50 PM
; Author : axelg
;

INIT:
	.equ T = 25; definerar längden på en tidsenhet bram.
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPH, r16
	clr r16
	out DDRA, r16
	ldi r16, 0x8F
	out DDRB, r16

REPEAT:
	call CYCLE
	jmp REPEAT

CYCLE:
	sbi PORTA, 0
	call DELAY
	cbi PORTA, 0
	call DELAY
	ret

DELAY:
            ldi		r16,0x02
delayYttreLoop:
            ldi		r17,0x22
delayInreLoop:
            dec		r17
            brne	delayInreLoop
            dec		r16
            brne	delayYttreLoop
            ret

.org $200
MESSAGE: .db "SOS",$00

.org $230
BTAB: .db $00, $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8

