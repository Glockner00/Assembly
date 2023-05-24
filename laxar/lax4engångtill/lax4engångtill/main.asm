ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16
call HW_INIT
DATA:
	in r16, PINA
	cpi r16, 0x0F
	breq TOGGLE
	cpi r16, 9
	brmi NINE
	jmp PRINT
TOGGLE:
	com r18
	jmp PRINT
NINE:
	ldi r16, 9
PRINT:
	cpi r18, 0
	breq SWITCH
	out DDRB, r16
	jmp DATA
SWITCH:
	out DDRD, r16
	jmp DATA
HW_INIT:
	clr r18
	ldi r16, 0x00
	out DDRA, r16
	ldi r16, 0x0F
	out DDRB, r16
	out DDRD, r16
	ret