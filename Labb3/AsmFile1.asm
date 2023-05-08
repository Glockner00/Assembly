;
; Labb3.asm
;
; Created: 2023-05-02 15:23:38
; Author : Arvid Ivarsson, Elias Sandgren & Filip Weibahr
;
.dseg

TIME:
	.byte 4

MUX_COUNT:
	.byte 1
.cseg

.org 0
rjmp COLD
.org INT0addr
rjmp BCD
.org INT1addr
rjmp MUX

; Initierar stacken
COLD:
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	clr r16
	sts TIME, r16
	sts TIME+1, r16
	sts TIME+2, r16
	sts TIME+3, r16

; Initierar h�rdvaran
INIT:
	ldi r16, $FF
	out DDRA, r16
	ldi r16, 0b11
	out DDRB, r16
	clr r16

ldi r16, (1<<ISC01)|(1<<ISC11)
out MCUCR, r16

ldi r16, (1<<int0)|(1<<int1)
out GICR, r16

sei

clr r16
clr r18

clt ; Clearar T-flaggan

MAIN:
jmp MAIN

BCD:
	push YH
	push YL
	push r16

	ldi YH, HIGH(TIME)
	ldi YL, LOW(TIME)
counter:
	ld r16, Y
	inc r16
	cpi r16, 10 ;max +1
	brne klar 
	clr r16
	st Y+, r16 ;B�rjar r�kna p� tiotal sekunder/minuter

	ld r16, Y
	inc r16
	cpi r16, 6 ;max +1
	brne klar 
	clr r16
	st Y+, r16
	
	brts reset_timer ;Om vi r�knat klart minuter --> resetta
	set ;T=1 --> Vi har b�rjat r�kna minuter
	rjmp counter ;B�rjar r�kna minuter ist�llet ; Byt kanske till BCD. Vet ej om det funkar nu
	
reset_timer:
	clt
	ldi YH, HIGH(TIME)
	ldi YL, LOW(TIME)

klar: ; Klar = Beh�ver inte �ka n�gon siffra p� annan position (pga carry)
	st Y, r16
	clt

	pop r16
	pop YL
	pop YH
	reti

MUX:
	call DISPLAY
	reti

DISPLAY:
	push r17
	push ZL
	push ZH ;Pushar och poppar register f�r att kunna anv�nda dom utanf�r subrutinens
	in r17, SREG
	push r17

	lds r18, MUX_COUNT
	ldi ZL, LOW(TIME)
	ldi ZH, HIGH(TIME)
	add ZL, r18
	ld r17, Z ;Laddar r17 med en siffra
	call LOOKUP

	out PORTB, r18
	out PORTA, r17
	inc r18
	andi r18, $3
	sts MUX_COUNT, r18
	
skip_mux_reset:
	pop r17
	out SREG, r17
	pop ZH
	pop ZL
	pop r17
	ret

LOOKUP:
	push ZL ;push och pop f�r att �teranv�nda Z-pekaren
	push ZH

	ldi ZL, LOW(HEX_TABLE*2) ;Z-pekaren b�rjar kolla p� position 0 i HEX_TABLE
	ldi ZH, HIGH(HEX_TABLE*2)
	add ZL, r17
	lpm r17, Z ;�vers�tter siffran till korrekt hex-talet

	pop ZH
	pop ZL
	ret

; Tabell f�r vad som ska visas p� 7-segdisplayen
HEX_TABLE:
	.db $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F
	;	 0	  1	   2    3    4    5    6    7    8    9