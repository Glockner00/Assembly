; DEMOLAX-2

ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16
call HW_INIT

MAIN:
	call COUNTER
	call PRINT
	jmp MAIN

COUNTER:
	in r16, PORTA
	cpi r16, 0
	breq DONE

	inc r17
	mov r18, r17
	subi r18, 15
	brpl TOO_HIGH
	jmp DONE

TOO_HIGH:
	ldi r17, 15

DONE:
	ret

PRINT:
	in r16, PORTB
	cpi r16, 0
	breq PRINT_DONE

	out PORTC, r17

PRINT_DONE:
	ret

HW_INIT:
	ldi r16, 0x0F
	out DDRC, r16
	ldi r16, 0
	out DDRA, r16
	out DDRB, r16
	ret