ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16
call HW_INIT

DATA:
	clr r17
	in r16, PINA
	cpi r16, 10
	brpl PRINT
	ldi r17, 1
	subi r16, 10 

PRINT:
	out PORTB, r17
	out PORTD, r16
	jmp DATA

HW_INIT:
	ldi r16, 0x00
	out DDRA, r16
	ldi r16, 0x0F
	out DDRB, r16
	out DDRD, r16
	ret