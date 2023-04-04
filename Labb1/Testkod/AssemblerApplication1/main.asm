; Created: 03/04/2023 15:28:22
; Author : olleh

	ldi r16, HIGH(RAMEND)	; Load the high byte of RAMEND into r16
	out SPH, r16			; Set the high byte of the stack pointer
    ldi r16, LOW(RAMEND)	; Load the low byte of RAMEND into r16
    out SPL, r16			; Set the low byte of the stack pointer

SIFFRA:
	call STARTBIT
	call LETA
	call DATA
	jmp SKRIVUT

STARTBIT:
	ldi r29,  4 ; vi anger r16 med värdet 4 så vi endast loopar igenom data 4 gånger.				
	sbi DDRB, 0
	sbi DDRB, 1
	sbi DDRB, 2
	sbi DDRB, 3
	sbi DDRB, 7
	ret

LETA:
	in r18, PINA
	andi r18, 0x01 ; Mask lsbÅ
	brne HITTA1    ; if Z=1
	jmp LETA
	ret

HITTA1:
	jmp DELAY      ; delay 8ms
	in r18, PINA   ; read from PINA
	andi r18, 0x01 ; mask lsb
	breq DATA      ; go to startbit if Z=1 .
	jmp LETA       ; go back if there is no number.
	ret

CHECKBIT:
	in r20, PINA
	andi r20, 0x01
	breq DATA
	
	;while som kollar när startbiten = 1. När startbiten blir =1 så ska vi till data.
	;if(startbit=0) { call delay }
	;else jmp checkbit

DATA:
	;while r16>=0 läs in en bit && dubbeldelay
	call DELAY
	call DELAY
	in r19, PINA
	andi r19,0x01
	add r21, r19
	lsl r21
	dec r29
	brne DATA ; if r29!=0
	out PORTB, r21
	jmp STARTBIT

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

SKRIVUT:
	;skicka ut allt till korrekt pins.
    
