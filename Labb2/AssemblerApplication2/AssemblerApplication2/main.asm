;.def counter = r17		; Sätter barar r17 som variabeln counter
.org $0000				; Sätter programmets startadress till 0x0000 aka första minnesadressen som avrbotten börjar

.org INT0addr			; Hanterar tid
rjmp INT0_handler				; Hoppar till när ett INTO-avbrott sker
 
.org INT1addr			; Uppdaterar displayen
rjmp INT1_handler				; Hoppar till när ett INT1-avbrott sker

INIT:					; initiera stackpekare och clear 4 bytes för time.
	ldi r16,HIGH(RAMEND); STACKPOINTER
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
	clr r16

	ldi r16, (1<<ISC01)|(1<<ISC11)
	out MCUCR, r16
	ldi r16, (1<<int0)|(1<<int1)
	out GICR, r16
	clr r16

	sei

MAIN:
	call INT1_handler
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

INT0_DONE:
	;cpi r19, 0

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
	ldi ZH, HIGH(TIME)
	ldi ZL, LOW(TIME)
	ld r18, Z
	call LOOKUP
	out PORTA, r18

INT1_DONE:
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

.dseg					; Börjar definitionen av data-segmentet. Används för att lagra variabler och data som används i programmet
.org $200

TIME: 				; Sätter storlek på time, vi kan ändra siffra beroende på
	.byte 4

.cseg					; Börjar definitionen av kod-segementet
.org $100				; Sätter startadressen för kodsegmentet till 0x0100

TAB: 
	.db 10,6,10,6		;TAB är en tabell med exempelsiffror från lektionen
 
BCD_CODE:				;BCD koden för siffror 0-9 där 0 är på plats noll & 9 på plats 10.
	.db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$FF,$67 