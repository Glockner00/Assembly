;
; Lab3-gammal.asm
;
; Created: 27/04/2023 11:26:18
; Author : olleh
;


; Replace with your application code

.def counter = r17
 
 .org $0000 ;ORG directive sets the location counter to an absolute value
 rjmp START

 .org INT0addr
 rjmp BCD
 
 .org INT1addr
 rjmp MUX 
 
START: ;Här startar vi lol
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, $FF
	out DDRA, r16
	out DDRB, r16
	clr r16
	
	CLR_COUNTER: ; Laddar Z med time och storar post inc. Rensa klocka och sätt position.
		ldi ZL, LOW(TIME)
		ldi ZH, HIGH(TIME)
			st Z+, r16
			st Z+, r16
			st Z+, r16
			st Z, r16

INIT_INT:   ldi r16, (1<<ISC01 | 0<<ISC00 | 1<<ISC11 | 0<<ISC10) ;Initsialiserar interupts
            out MCUCR, r16
            ldi r16, (1<<INT0 | 1<<INT1)
            out GICR, r16
            sei ;sets the bit and switches interrupts on
MAIN: ;Gå vidare vid int
            rjmp MAIN
 
MUX: ; Mux-prylar, vi väljer och skit. 
			push r16	
			in r16, SREG
			push r16
			push ZL
			push ZH
		
            ldi	ZL, LOW(TIME); Laddar ZL med time
            ldi	ZH, HIGH(TIME)
            add ZL, counter

            ld	r16, Z

            ldi ZL, LOW(2*BCD_CODE); Laddar ZL med BCD-code (7-segment-kodning)
            ldi ZH, HIGH(2*BCD_CODE)
            add ZL, r16

            lpm r16, Z ;load program memory
			out PORTB, r16
            out PORTA, counter
            inc counter
            cpi counter, 4 ; counter (r17) = 4 --> Mux_comp. Time offset
            brne MUX_COMP
            clr counter
			
MUX_COMP: ;Vi popar r16 och går tillbaka med flagga
            pop ZH
			pop ZL
			pop r16       
            out SREG, r16
			pop r16
            reti

BCD: ; BCD vi pushar r16 till stacken och laddar in Z och Y med tab och time
			push r16
			in r16, SREG
			push r16
			push ZL
			push ZH
			push YL
			push YH
            
            ldi ZH, HIGH(TAB*2); Laddar Z
            ldi ZL, LOW(TAB*2)
			ldi YH,HIGH(TIME); Laddar Y
            ldi YL,LOW(TIME)	

 
LOOP: ;Spin me right round baby right round. Letar efter uppklockning
	ld r16, Y
	inc r16
	st Y,r16
	lpm r18,Z
	cp r16, r18
	brne KLAR ;När r16 (Y+1) och r18 (Z) Är samma klockar vi upp.
	clr r16
	st Y,r16
	adiw ZH:ZL,1 ;Ökar med 1
	adiw YH:YL,1 ;Ökar med 1
	rjmp LOOP

KLAR: ; Samma som mux-comp typ men för loop
            pop YH
			pop YL
			pop ZH
			pop ZL
			pop r16
			out SREG, r16
			pop r16
            reti

.dseg ;Start data segment
.org $200
TIME: ;Sätter storlek på time
.byte 4
 
.cseg ;defines the start of a Code Segment.
.org $100
TAB: .db 10,6,10,6 ; TAB från lek.

 
BCD_CODE:
            .db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$FF,$67 ;0-9

