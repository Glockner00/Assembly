INIT :  .def	N = r24			 ; ETT BEEPINTERVALL
		ldi     r16,HIGH(RAMEND) ; STACKPOINTER
		out     SPH,r16
		ldi     r16,LOW(RAMEND)
		out     SPL,r16			 ; INPUT
		ldi		r16, 0x00
        out		DDRA, r16
		ldi     r16,0x8F         ; OUTPUT 
		out		DDRB,r16


MORSE:	ldi		ZL, LOW(MESSAGE*2)  ; load the message, low (top of the stack)
		ldi		ZH, HIGH(MESSAGE*2) ; load the message, high (top of the stack)
		rcall	GET_CHAR			; get the next ASCII 

; MAIN LOOP FOR SENDING THE MESSAGE.
ONE_CHAR:	cpi		r18, 0x20	; compare with a space
			breq	SPACE		; branch if there is a space
			rcall	LOOKUP		; else go to lookup and translate the ASCII character to binary.
			rcall	SEND		; then send 

NO_CHAR:	rcall GET_CHAR ; look for an unknown character
			cpi r18, 0x00  ; compare wiht zero
			brne ONE_CHAR  ;
			rjmp MORSE	   ; 

SPACE:	ldi		r21, 0x07  ; load a blank
		ldi		r18, 0x20  ; load a space
		rcall	NO_BEEP	   ; call for a no beep
		rjmp	NO_CHAR	   ; jump to a non character

; TRANSLATE ASCII TO BINARY
LOOKUP:		push	ZL
			push	ZH
			ldi		ZH, HIGH(BTAB*2)
			ldi		ZL, LOW(BTAB*2)
			subi	r18, 0x40

; CONTINUE TO CHECK REGISTERS.
CONTINUE:	ldi r22, 1
			add ZL, r18
			brcc pc+2 ; is used to skip the next instruction (i.e., add ZH, r22) if the carry flag is not set
			add ZH, r22
			lpm r19, Z
			pop ZH
			pop ZL
			ret 

SEND:	

CHAR_DONE:

GET_CHAR:	lpm		r18, Z+
			ret

GET_BIT:

BEEP:

BEEPLOOP:

NO_BEEP:

CYCLE: 


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
MESSAGE:	.db "SOS",$00
 
.org $230
BTAB:	.db $00, $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8