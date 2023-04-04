; Created: 03/04/2023 15:28:22
; Author : Olle Håkansson, Axel Glöckner.
; Labb 1 - IR 
INITSTACK:
	ldi r16, HIGH(RAMEND)	; Load the high byte of RAMEND into r16
	out SPH, r16			; Set the high byte of the stack pointer
    ldi r16, LOW(RAMEND)	; Load the low byte of RAMEND into r16
    out SPL, r16			; Set the low byte of the stack pointer

STARTBIT:
	ldi r29, 4      ; For looping.
	clr r16
	out DDRA, r16
	ldi r16, 0xFF
	out DDRB, r16

LETA:
	call DELAY 
	in r18, PINA    ; Read from PINA 
	andi r18, 0x01  ; Mask lsb
	brne CHECKBIT   ; if Z=1
	jmp LETA        ; else jmp LETA

CHECKBIT:
	in r20, PINA    ; read PINA
	andi r20, 0x01  ; mask lsb
	breq LETA       ; If z=1 contiune
	call DELAY      ; delay 8ms

;HITTA1:
;	jmp DELAY      ; delay 8ms
;	in r18, PINA   ; read from PINA
;	andi r18, 0x01 ; mask lsb
;	breq DATA      ; go to startbit if Z=1 .
;	jmp LETA       ; go back if there is no number.
;	ret

DATA:
	call DELAY     ; delay 8ms  8ms (läs) -> 8ms + 8ms = 16 ms 
	in r19, PINA   ; read PINA
	lsl r21        ; rotate r21 
	add r21, r19   ; add r19 to r20 (r20 stores the output)
	call DELAY     ; delay 8ms
	dec r29
	brne DATA      ; if r29 != 0
	out PORTB, r21 ; output the data in PORTB
	clr r21
	jmp STARTBIT

;DELAY 8ms
DELAY:
	sbi PORTB, 7                ; Set bit number seven in the I/O register to one.
	ldi r16, 100                ; Decimal base
		delayOuterLoop:
			ldi r17, 80
		delayInnerLoop:
			dec r17		        ; decrease r17 with one.
			brne delayInnerLoop	; if dec r17 gives 0 -> jump delayInnerLoop 
			dec r16				; decrease r16 with one
			brne delayOuterLoop	; check Z flag, if dec r17 gives 0 -> jump delayInnerLoop.
			cbi PORTB, 7		; clears bit in I/O registry
			ret			        ; return   har inget att peka på.