COLD:
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	clr r18
	call HW_INIT

MAIN: 
	call DATA
	call PRINT
	jmp MAIN

DATA:
	in r16, PINA
	mov r17, r16
	cpi r17, 10
	brmi DATA_DONE
	mov r17, r16
	cpi r17, 0x0F
	brmi LOAD_NINE

TOGGLE_BIT:
	cpi r18, 0x01
	breq SET_ZERO
	ldi r18, 0x01
	jmp DATA

SET_ZERO:
	clr r18
	jmp DATA

LOAD_NINE:
	ldi r16, 9
DATA_DONE:
	ret

PRINT:
	cpi r18, 1
	breq LEFT
	out PORTD, r16
	jmp PRINT_DONE
LEFT:
	out PORTB, r16
PRINT_DONE: 
	ret

HW_INIT:
	ldi r16, 0
	out DDRA, r16
	ldi r16, 0x0F
	out DDRB, r16
	out DDRD, r16
	clr r16
	ret


