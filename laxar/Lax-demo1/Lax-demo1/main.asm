; DEMO-LAX 1

ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16

MAIN:
	call HW_INIT
	call DELAY
	call DATA
	call PRINT
	jmp MAIN

DATA:
	in r16, PINA
	mov r17, r16
	subi r17, 10
	BRMI LESS_TEN
	BRPL MORE_TEN

MORE_TEN:
	ldi r18, 1
	jmp DONE
	
LESS_TEN:
	clr r18
	mov r17, r18
DONE:
	ret

PRINT:
	call DELAY
	out PORTB, r17
	out PORTC, r18
	ret

HW_INIT:
	ldi r16, 0x0F
	out DDRB, r16
	out DDRC, r16
	ret

DELAY:
	ldi r16, 10
delayYttreLoop:
	dec r16
	cpi r16, 0
	brne delayYttreLoop
	ldi r16, 10
delayInreLoop:
	dec r16
	cpi r16, 0
	brne delayInreLoop
	ret