;DEMO-LAX5

COLD:
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
	mov r17, r16
	cpi r17, 0
	breq TOGGLE
	jmp DATA_DONE 

TOGGLE:
	cpi r18, 0x01
	breq SET_ZERO
	ldi r18,0x01
	jmp DATA

SET_ZERO:
	clr r18
	jmp DATA 

DATA_DONE:
	ret

PRINT: 
	out PORTD, r16
	cpi r18, 0x01
	breq INVERT
	out PORTB, r17
	jmp PRINT_DONE

INVERT:
	com r17 
	out PORTB, r17
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

