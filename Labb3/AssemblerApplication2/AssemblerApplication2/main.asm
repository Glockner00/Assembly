.org $0000		

.dseg					
.org $200
TIME: 				
	.byte 4

MUX_COUNT: 
	.byte 1
.cseg
			
.org INT0addr			
rjmp INT0_handler		
.org INT1addr			
rjmp INT1_handler		

INIT:					
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16			 
	clr r16

	sts TIME, r16
	sts TIME+1, r16
	sts TIME+2, r16
	sts TIME+3, r16

	ldi r16, 0xFF
	out DDRA, r16
	ldi r16, 0b11

	ldi r16, (1<<ISC01)|(1<<ISC11)
	out MCUCR, r16
	ldi r16, (1<<int0)|(1<<int1)
	out GICR, r16
	clr r16

	sei

MAIN:
	rjmp MAIN

INT0_handler:
	ldi r19, 2
	push r16
	in r16, SREG
	push r16
	ldi XL, LOW(TIME)
	ldi XH, HIGH(TIME)

LOOP:
	ld r17, X
	inc r17
	cpi r17, 10
	brne INT0_DONE 
	clr r17
	st X+, r17
	ld r17, X
	inc r17
	cpi r17, 6
	brne INT0_DONE
	clr r17
	st X+, r17
	dec r19
	brne LOOP
	
	int0_done:
		st X, r17
		pop r16
		out SREG, r16
		pop r16
		reti

INT1_handler:
	push ZL
	push ZH 
	push r16
	in r16, SREG
	push r16
	lds r29, MUX_COUNT
	ldi ZH, HIGH(TIME)
	ldi ZL, LOW(TIME)
	add ZL, r29
	ld r18, Z
	call LOOKUP
	out PORTA, r18
	out PORTB, r29
	inc r29
	andi r29, 0x03
	sts MUX_COUNT, r29

	int1_done:
		pop r16
		out SREG, r16
		pop r16
		pop ZH
		pop ZL
		reti

LOOKUP:
	push ZL
	push ZH
	ldi ZH, HIGH(BCD_CODE*2)
	ldi ZL, LOW(BCD_CODE*2)
	add ZL, r18
	lpm r18, Z
	pop ZH
	pop ZL
	ret
				
.org $100				

BCD_CODE:				
	.db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$FF,$67 