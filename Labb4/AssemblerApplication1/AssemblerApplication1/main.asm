; --- lab4_skal . asm
.equ VMEM_SZ = 5 ; # rows on display
.equ AD_CHAN_X = 0 ; ADC0 = PA0 , PORTA bit 0 X - led
.equ AD_CHAN_Y = 1 ; ADC1 = PA1 , PORTA bit 1 Y - led
.equ GAME_SPEED = 70 ; inter - run delay ( millisecs )
.equ PRESCALE = 7 ; AD - prescaler value
.equ BEEP_PITCH = 20 ; Victory beep pitch
.equ BEEP_LENGTH = 100 ; Victory beep length
.equ DELAY_LENGTH = 150
; ---------------------------------------
; --- Memory layout in SRAM
.dseg
.org SRAM_START

POSX : .byte 1 ; Own position
POSY : .byte 1
TPOSX : .byte 1 ; Target position
TPOSY : .byte 1
LINE : .byte 1 ; Current line
VMEM : .byte VMEM_SZ ; Video MEMory
SEED : .byte 1 ; Seed for Random
; ---------------------------------------
; --- Macros for inc / dec - rementing
; --- a byte in SRAM
.macro INCSRAM ; inc byte in SRAM
lds r16 , @0
inc r16
sts @0 , r16
.endmacro
.macro DECSRAM ; dec byte in SRAM
lds r16 , @0
dec r16
sts @0 , r16

.endmacro
; ---------------------------------------
; --- Code
.cseg
.org $0
jmp START
	.org INT0addr

jmp MUX

START:
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	call HW_INIT
	call CLEAR_SRAM
	call DELAY
	call WARM
RUN:
	call JOYSTICK
	call ERASE
	call UPDATE
	call DELAY
;*** Vanta en stund sa inte spelet gar for fort ***
;*** Avgor om traff ***

CHECK_HIT:		
	lds		r16, POSX
	lds		r17, TPOSX
	cp		r16, r17 ;compare
	brne	NO_HIT ; om x inte är samma
	lds		r16, POSY
	lds		r17, TPOSY
	cp		r16, r17
	brne	NO_HIT	;om y inte är samma
	call	BEEP
	call	WARM
NO_HIT:
	jmp RUN

; ---------------------------------------
; --- Multiplex display
; --- Uses : r16
MUX:
	push r16 ; rad 
	in r16, SREG
	push r16
	push XL
	push XH
	push r17 ; kol
READ:
	clr r16
	lds r16, LINE 
CLEAR_DISPLAY:
	clr r17
	out PORTB, r17 ; släcker föregående kolumn, slipper skuggningar
	out PORTA, r16 ; skickar ut en rad
INC_LINE:
	INCSRAM LINE ; macro för att öka en rad.
	lds r16, LINE
	cpi r16, VMEM_SZ ; 5
	brne READ_VMEM
	clr r16 ; clear om vi har fått fem rader
READ_VMEM:
	sts LINE, r16
	lsl r16
	lsl r16
	out PORTA, r16
	lsr r16
	lsr r16
	ldi XH, HIGH(VMEM)
	ldi XL, LOW(VMEM)
	add XL, r16
	clr r16
	adc XH, r16
	ld r16, X
	out PORTB, r16
	INCSRAM SEED
	pop r17
	pop XH
	pop XL
	pop r16
	out SREG, r16
	pop r16
	
;*** skriv rutin som handhar multiplexningen och ***
;*** utskriften till diodmatrisen . Oka SEED . ***
	reti
; ---------------------------------------
; --- JOYSTICK Sense stick and update POSX , POSY
; --- Uses :

JOYSTICK :
;*** skriv kod som okar eller minskar POSX beroende ***
;*** pa insignalen fran A/D - omvandlaren i X - led ... ***
;*** ... och samma for Y - led ***
	push r16
JOYSTICK_X:
	ldi r16, AD_CHAN_X
	call ADC8
	cpi r16, $03 ;Höger   
	breq JOYSTICK_INC_X ;Höger upp
	cpi r16, $00; Vänster		/00
	breq JOYSTICK_DEC_X; Vänster ned
	jmp JOYSTICK_Y
JOYSTICK_INC_X:
	INCSRAM POSX
	jmp JOYSTICK_Y
JOYSTICK_DEC_X:
	DECSRAM POSX
JOYSTICK_Y:
	ldi r16, AD_CHAN_Y
	call ADC8
	cpi r16, $03 ;Uppåt
	breq JOYSTICK_INC_Y; Uppåt upp
	cpi r16, $00; Nedåt
	breq JOYSTICK_DEC_Y; Nedåt ned
	jmp JOY_LIM
JOYSTICK_INC_Y:
	INCSRAM POSY
	jmp JOY_LIM
	JOYSTICK_DEC_Y:
	DECSRAM POSY
JOY_LIM:
	call LIMITS ; Gå inte utanför bana §
JOYSTICK_DONE:
	pop r16
	ret
; ---------------------------------------
; --- LIMITS Limit POSX , POSY coordinates
; --- Uses : r16 , r17
LIMITS :
	lds r16 , POSX ; variable
	ldi r17 ,7 ; upper limit +1
	call POS_LIM ; actual work
	sts POSX , r16
	lds r16 , POSY ; variable
	ldi r17 ,5 ; upper limit +1
	call POS_LIM ; actual work
	sts POSY , r16
	ret
POS_LIM :
	ori r16 ,0 ; negative ?
	brmi POS_LESS ; POSX neg = > add 1
	cp r16 , r17 ; past edge
	brne POS_OK
	subi r16 ,2
POS_LESS :
	inc r16
POS_OK :
	ret

; ---------------------------------------
; --- UPDATE VMEM
; --- with POSX /Y , TPOSX /Y
; --- Uses : r16 , r17 , Z
UPDATE :
	clr ZH
	ldi ZL , LOW ( POSX )
	call SETPOS
	clr ZH
	ldi ZL , LOW ( TPOSX )
	call SETPOS
	ret
; --- SETPOS Set bit pattern of r16 into * Z
; --- Uses : r16 , r17 , Z
; --- 1 st call Z points to POSX at entry and POSY at exit
; --- 2 nd call Z points to TPOSX at entry and TPOSY at exit

SETPOS :
	ld r17 , Z + ; r17 = POSX
	call SETBIT ; r16 = bitpattern for VMEM + POSY
	ld r17 , Z ; r17 = POSY Z to POSY
	ldi ZL , LOW ( VMEM )
	add ZL , r17 ; Z= VMEM + POSY , ZL = VMEM +0..4
	ld r17 , Z ; current line in VMEM
	or r17 , r16 ; OR on place
	st Z , r17 ; put back into VMEM
	ret
; --- SETBIT Set bit r17 on r16
; --- Uses : r16 , r17
SETBIT :
	ldi r16 , $01 ; bit to shift

SETBIT_LOOP :
	dec r17
	brmi SETBIT_END ; til done
	lsl r16 ; shift
	jmp SETBIT_LOOP

SETBIT_END :
	ret
; ---------------------------------------
; --- Hardware init
; --- Uses :

HW_INIT :
;*** Konfigurera hardvara och MUX - avbrott enligt ***
;*** ditt elektriska schema . Konfigurera ***
;*** flanktriggat avbrott pa INT0 ( PD2 ). ***
	
	ldi r16, 0b00011100
	out DDRA, r16	;Insignalen för joystick är nu A0 & A1. Vi sätter A2, A3 & A4 till A, B & C resp på led matrixen

	ldi r16, 0xFF	
	out DDRB, r16	;Utsignalen för led matrixen ärB0-B6 , B0 är lsb B6 är msb. B7 utsignal för högtalaren
	clr r16

	ldi r16, (1<<ISC01)|(1<<ISC11)	;D2 eller D3 är insignal för avbrott, kopplas till 1khz på klocka
	out MCUCR, r16
	ldi r16, (1<<int0)
	out GICR, r16
	
	ldi r16, (1<<ADEN)    ; HW INIT 
	out ADCSRA,r16 ; enables ADCSRA, HW INIT 
	clr r16

	sei ; display on
	ret

; ---------------------------------------
; --- WARM start . Set up a new game .
; --- Uses :

WARM :
	;*** Satt startposition ( POSX , POSY )=(0 ,2) ***
	push r16
	ldi r16, 0
	sts POSX, r16
	ldi r16, 2
	sts POSY, r16
TPOS:
	push r0
	push r0
	call RANDOM ; RANDOM returns TPOSX , TPOSY on stack
	;*** Satt startposition ( TPOSX , TPOSY ) ***
	pop r16
	sts TPOSY, r16
	pop r16
	sts TPOSX, r16
DONE:
	call ERASE
	pop r16
	ret
; ---------------------------------------
; --- RANDOM generate TPOSX , TPOSY
; --- in variables passed on stack .
; --- Usage as :
; --- push r0
; --- push r0
; --- call RANDOM
; --- pop TPOSX
; --- pop TPOSY
; --- Uses : r16

RANDOM :
	in r16 , SPH
	mov ZH , r16
	in r16 , SPL
	mov ZL , r16
	lds r16 , SEED
RANDOM_X:
	andi r16, 0x03
	cpi r16, 4
	brpl DECFOUR_X
	jmp RANDOM_Y
DECFOUR_X:
	subi r16, 4
RANDOM_Y:
	std Z+3, r16
	andi r16, 0x03
	cpi r16, 4
	brpl DECFOUR_Y
	jmp STORE
DECFOUR_Y:
	subi r16, 4
STORE:
	std Z+4, r16
	ret

	;*** Anvand SEED for att berakna TPOSX ***
	;*** Anvand SEED for att berakna TPOSY ***
	;*** ; store TPOSX 2..6
	;*** ; store TPOSY 0..4
	ret
; ---------------------------------------
; --- ERASE videomemory
; --- Clears VMEM .. VMEM +4
; --- Uses :

ERASE :
;*** Radera videominnet ***
	ldi r18, 0
	sts VMEM, r18
	sts VMEM+1, r18
	sts VMEM+2, r18
	sts VMEM+3, r18
	sts VMEM+4, r18
	ret

CLEAR_SRAM: ;Rensar hela RAM-minnet för nollställning
	push r16
	clr r16
	sts POSX, r16
	sts POSY, r16
	sts TPOSX, r16
	sts TPOSY, r16
	call ERASE
	sts SEED, r16
	pop r16
	ret


DELAY:
            ldi		r16, DELAY_LENGTH
delayYttreLoop:
            ldi		r17, 0xFF
delayInreLoop:
            dec		r17
            brne	delayInreLoop
            dec		r16
            brne	delayYttreLoop
            ret
ADC8: ;För att kunna använda joystick, från analog till digital

ADC8_SETUP:
	andi r16, (1 << MUX2) | (1 << MUX1) | (1 << MUX0)
	ori r16, (1 << REFS0)
	out ADMUX, r16
	ldi r16, (1 << ADEN)
	ori r16, PRESCALE
	out ADCSRA, r16
ADC8_CONVERT:
	in r16, ADCSRA
	ori r16, (1 << ADSC)
	out ADCSRA, r16
ADC8_WAIT:
	in r16, ADCSRA
	sbrc r16, ADSC
	rjmp ADC8_WAIT
	in r16, ADCH
	ret

; ---------------------------------------
; --- BEEP ( r16 ) r16 half cycles of BEEP - PITCH
; --- Uses :

BEEP:
	push	r16
	push	r17
	cli
	ldi		r16, BEEP_LENGTH
outer_beep:
	ldi		r17, BEEP_PITCH
	sbi		PORTB, 7
inner_beep1:
	dec		r17
	brne	inner_beep1
	cbi		PORTB, 7
	ldi		r17, BEEP_PITCH
inner_beep2:
	dec		r17
	brne	inner_beep2
	dec		r16
	brne	outer_beep
	sei
	pop		r17
	pop		r16
	ret

