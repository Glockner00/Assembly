ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16
call HW_INIT

MAIN:
	call DATA
	call PRINT
	jmp MAIN

DATA:
	in r16, PINA
	cpi r16, 0
	breq INVERT

INVERT:
	cpi r17, 1
	breq ZERO
	ldi r17, 1
ZERO:
	ldi r17, 0		

DATA_DONE:
	ret

PRINT:
	cpi r17, 1
	breq INV
	jmp PR
INV:
	mov r18, r16
	com r18

PR:
	out PORTD, r18
	out PORTB, r16
	ret

HW_INIT:
	ldi r16, 0x00
	out DDRA, r16
	ldi r16, 0x0F
	out DDRB, r16
	out DDRD, r16
	ret 