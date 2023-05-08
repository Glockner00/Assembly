INIT:   .equ	beepln = 20	 ; ETT BEEPINTERVALL
		ldi     r16,HIGH(RAMEND) ; STACKPOINTER
		out     SPH,r16
		ldi     r16,LOW(RAMEND)
		out     SPL,r16			 
		ldi     r16,0x01         ; OUTPUT 
		out		DDRB,r16

MORSE:	ldi		ZL, LOW(MESSAGE*2)  ; load the message, low (top of the stack)
		ldi		ZH, HIGH(MESSAGE*2) ; load the message, high (top of the stack)
		rcall	GET_CHAR

; MAIN LOOP FOR SENDING THE MESSAGE.
ONE_CHAR:	
	cpi	r18, 0x20	; compare with a space
	breq SPACE		; branch if there is a space
	rcall LOOKUP	; else go to lookup and translate the ASCII character to binary.
	rcall SEND
	call GET_CHAR
	call NO_BEEP
	call NO_BEEP
	cpi r18, 0x00
	breq END
	rjmp ONE_CHAR

END:
	RJMP END

LOOKUP:
	push ZL
	push ZH 
	ldi ZH, HIGH(BTAB*2)
	ldi ZL, LOW(BTAB*2)
	subi r18, 0x41
	ldi r22, 0
	add ZL, r18
	adc ZH, r22
	lpm r19, Z
	pop ZH
	pop ZL
	ret

SEND:
	rcall GETNEXTBIT
	breq SEND_EXIT
	brcs LONG_BEEP

SHORT_BEEP:
	ldi r22, beepln
	jmp BEEPLOOP

LONG_BEEP: 
	ldi r22, beepln*3
BEEPLOOP:
	rcall CYCLE
	dec r22
	brne BEEPLOOP
	rcall NO_BEEP_CYCLE
	jmp SEND

SEND_EXIT:
	ret

NO_BEEP: ; En ingen beep
	ldi r22, beepln
NOBEEPLOOP:
	rcall NO_BEEP_CYCLE
	dec r22
	brne NOBEEPLOOP
	rcall DELAY

NO_BEEP_EXIT:
	ret

SPACE:
	rcall NO_BEEP
	rcall NO_BEEP
	rcall NO_BEEP
	rcall NO_BEEP
	rcall NO_BEEP
	rcall NO_BEEP
	rcall NO_BEEP
	rcall GET_CHAR
	jmp ONE_CHAR

GET_CHAR:
	lpm r18, Z+
	ret

GETNEXTBIT:
	lsl r19
	ret	
	
CYCLE:
	sbi PORTB, 0
	rcall DELAY
	cbi PORTB, 0
	rcall DELAY
	ret

NO_BEEP_CYCLE:
	rcall DELAY
	rcall DELAY
	ret

DELAY:
            ldi		r16, 30
delayYttreLoop:
            ldi		r17, 40
delayInreLoop:
            dec		r17
            brne	delayInreLoop
            dec		r16
            brne	delayYttreLoop
            ret
           
.org $200
MESSAGE:	.db "SOS HEJ",$00
 
.org $230
BTAB:	.db  $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8