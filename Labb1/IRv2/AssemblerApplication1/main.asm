; Authors, Axel Glöckner, Olle Håkansson
; 2023-04-06

INITSTACK:
	ldi r16, HIGH(RAMEND)	; Load the high byte of RAMEND into r16
	out SPH, r16			; Set the high byte of the stack pointer
	ldi r16, LOW(RAMEND)	; Load the low byte of RAMEND into r16
	out SPL, r16			; Set the low byte of the stack pointer

STARTBIT:
	ldi r18, 4			; for constructing a loop
	clr r16				; clear out r16
	out DDRA, r16		; set DDRA as input
	ldi r16, 0x8F		; set r16 with all ones
	out DDRB, r16		; set DDRA as output

FINDONE:
	in r16, PINA		; Read from PINA 
	andi r16, 0x01		; Mask lsb
	brne CHECKBIT		; if Z=1
	jmp FINDONE			; else -> try again.

CHECKBIT:
	call DELAY			; 8ms delay.
	in r16, PINA		; read PINA
	andi r16, 0x01		; mask lsb
	breq FINDONE		; If z=1 contiune

DATALOOP:
	call DELAY			; 8ms delay  
	call DELAY			; 8ms delay
	rol r17				; rotate r17 left for the next bit
	in r16, PINA		; read PINA
	andi r16, 0x01		; mask lsb
	add r17, r16		; r17 stores the output
	dec r18				; decrease the itteration by one
	brne DATALOOP		; if r29 == 0 -> break out
print:	
	call DELAY
	out PORTB, r17		; output the data in PORTB
	clr r17				; clear out r21
	jmp STARTBIT        ; get a new startbit

DELAY:					; Delay 8ms -> T/2 
	sbi PORTB, 7        ; set bit number seven in the I/O register to one.
	ldi r19, 100        ; 100 itterations
delayOuterLoop:
	ldi r20, 80			; 80 itterations
delayInnerLoop:
	dec r20		        ; decrease r17 with one.
	brne delayInnerLoop	; if dec r17 gives 0 -> jump delayInnerLoop 
	dec r19				; decrease r16 with one
	brne delayOuterLoop	; check Z flag, if dec r17 gives 0 -> jump delayInnerLoop.
	cbi PORTB, 7		; clears bit in I/O registry
	ret			        