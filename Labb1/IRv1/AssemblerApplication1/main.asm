; IR - labb1
; Created: 3/31/2023 10:00:56 AM
; Author : Axel Glöckner, Olle Håkansson
; pekare för rcall ! :! : !: !: !:
ldi r16, HIGH(RAMEND)		; Load the high byte of RAMEND into r16
	out SPH, r16			; Set the high byte of the stack pointer
    ldi r16, LOW(RAMEND)	; Load the low byte of RAMEND into r16
    out SPL, r16			; Set the low byte of the stack pointer
MAIN:
	; sbi - set bit in I/O register
	; DDRB Data Direction Register B, controlls the data direction (input/output)
	; for the pins in port B. If DDRB is set to 1/0 -> corresponding pin is output/input.
	STARTBIT:       ; For PB.
		ldi r25, 8
		sbi DDRB, 0 ; PB0 as output
		sbi DDRB, 1 ; PB1 as output
		sbi DDRB, 2 ; PB2 as output
 		sbi DDRB, 3 ; PB3 as output
		sbi DDRB, 7 ; PB7 as output.

	SEARCH:

	FIND1:
		in r20, PINA	; Read from PINA
		ANDI r20, 0x01  ; Maskar msb
		brne CHECKBIT   ; if Z==0, if there has been a one.
		
	CHECKBIT:           ; T/2 = 8ms
		call DELAY 

	VALID:
		in r20, PINA   ; Read from PINA
		ANDI r20, 0x01 ; maskar msb
		brne DATA      ; Move to DATA if Z==0, if there has been a one
		call FIND1      ; Otherwise jump to FIND1

	DATA: 
		ldi r21, 4

	DATALOOP:
		dec r25
		breq DONE		;Move to DONE if Z==o
		call DELAY     ; Delay 8 ms
		call DELAY     ; Delay 8 ms
		in r22, PORTA   ; Read from PORTA
		ANDI R22, 0x01  ; maskar msb
		ADD r23, r22    ; Add r22 to r23
		ror r23         ; Rotate so i doesnt wirte over lmao
		ror r23		    ; Rotate to avoid putting it in carry
		dec r21         ; Count down
		brne DATALOOP
		
		rol r23
		rol r23
		rol r23
		rol r23
		rol r23		   ; Rotate msb to index 0
		out PORTB, r23 ; send r23 out of PORTB

	DELAY:
		sbi PORTB, 7   ; Set bit number seven in the I/O register to one.
		ldi r16, 100   ; Decimal base

		delayOuterLoop:
			ldi r17, 80
		
		delayInnerLoop:
			dec r17		        ; decrease r17 with one.
			brne delayInnerLoop	; if dec r17 gives 0 -> jump delayInnerLoop 
			dec r16				; decrease r16 with one
			brne delayOuterLoop	; check Z flag, if dec r17 gives 0 -> jump delayInnerLoop.
			cbi PORTB, 7		; clears bit in I/O registry
				ret			        ; return   har inget att peka på.
	DONE:
