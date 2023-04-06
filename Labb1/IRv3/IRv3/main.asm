STARTBIT: 
	ldi r16, 0xFF
	out DDRB, r16

INITSTACK:
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

FINDONE:
	in r16, PINA 
	cpi r16, 0x01
	brne FINDONE

VALID:
	call DELAY
	in r16, PINA
	cpi r16, 0x01
	brne FINDONE

DATA:
	ldi r17, 4
	clr r18
loop: 
	call DELAY
	call DELAY
	rol r18
	in r19, PINA
	andi r19, 0x01
	add r18, r19
	dec r17
	brne loop

PRINT:
	call DELAY
	out PORTB, r18
	jmp FINDONE

DELAY:				
	sbi	PORTB,7
	ldi	r24,10		
delayYttreLoop:
	ldi	r25,0x1F
delayInreLoop:
	dec	r25
	brne delayInreloop
	dec	r24
	brne delayYttreLoop
	cbi	PORTB, 7
	ret