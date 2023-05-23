ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16
call HW_INIT

DATA:
	in r16, PINA
	cpi r16, 0xFF
	breq TOGGLE
	cpi r16, 9
	brmi DATA
	jmp PRINT
TOGGLE:
	cpi r17, 1
	breq ZERO
	ldi r17, 1
ZERO:
	ldi r17, 0

PRINT:
	cpi r17, 1
	breq DISPLAY2
	out DDRB, r16
DISPLAY2:
	out DDRD, r16
	jmp DATA

HW_INIT:
	ldi r16, 0x00
	out DDRA, r16
	ldi r16, 0x0F
	out DDRB, r16
	out DDRD, r16
	clr r17
	ret