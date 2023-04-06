INITSTACK:
	ldi r16, HIGH(RAMEND)	; Load the high byte of RAMEND into r16
	out SPH, r16			; Set the high byte of the stack pointer
	ldi r16, LOW(RAMEND)	; Load the low byte of RAMEND into r16
	out SPL, r16			; Set the low byte of the stack pointer

STARTBIT:
	ldi r29, 4      ; for constructing a loop
	clr r16			; clear out r16
	out DDRA, r16   ; set DDRA as input
	ldi r16, 0xFF   ; set r16 with all ones
	out DDRB, r16   ; set DDRA as output

FIND:
	in r18, PINA    ; Read from PINA 
	andi r18, 0x01  ; Mask lsb
	brne CHECKBIT   ; if Z=1
	jmp FIND        

CHECKBIT:
	call DELAY
	in r20, PINA    ; read PINA
	andi r20, 0x01  ; mask lsb
	breq FIND       ; If z=1 contiune

DATA:
	call DELAY      
	call DELAY      
	lsl r21         ; rotate r21 left for the next bit
	in r19, PINA    ; read PINA
	andi r19, 0x01
	add r21, r19    ; add r19 to the result in r20 (r20 stores the output)
	dec r29		    ; decrease the itteration by one
	brne DATA       ; if r29 != 0
	call DELAY
	out PORTB, r21  ; output the data in PORTB
	clr r21         ; clear out r21
	jmp STARTBIT    ; get a new startbit

DELAY:
	sbi PORTB, 7        ; set bit number seven in the I/O register to one.
	ldi r16, 10         
delayOuterLoop:
	ldi r17, 0x1F			
delayInnerLoop:
	dec r17		        ; decrease r17 with one.
	brne delayInnerLoop	; if dec r17 gives 0 -> jump delayInnerLoop 
	dec r16				; decrease r16 with one
	brne delayOuterLoop	; check Z flag, if dec r17 gives 0 -> jump delayInnerLoop.
	cbi PORTB, 7		; clears bit in I/O registry
	ret			        