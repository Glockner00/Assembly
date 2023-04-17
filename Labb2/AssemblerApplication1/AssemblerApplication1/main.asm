INIT:
	.def N = r23 ; definerar längden på en tidsenhet bram.
	ldi r16, HIGH(RAMMEND)
	out SPH, r16
	ldi r16, LOW(RAMMEND)
	out SPH, r16
	ldi r16, 0x01
	out DDRB, r16

;Load the message inshallah på gud wallah inballlakbekmiki
MORSE:
	ldi ZL, LOW(MESSAGE*2)
	ldi ZH, HIGH(MESSAGE*2)
	call GET_CHAR

GET_CHAR:
	lpm r18, Z+
	ret

ONE_CHAR:
	
		
SPACE:
	ldi r21, 0x07
	ldi r18, 0x20
	call NO_BEEP
	rjmp NO_CHAR

NO_CHAR:
	call GET_CHAR
	cpi r18, 0x00


BEEP:

NOBEEP:


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