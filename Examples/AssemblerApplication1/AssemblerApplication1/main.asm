	;
	; --- Testprogram med lite kommentarer.
	; --- Kompilera med F7, börja enkelstegning med F11 
	; --- under Build- respektive Debug-menyerna ovan
	;

	/* Detta är också en kommentar */
	// Liksom detta (till slutet av raden)
	// (Mer finns att läsa på www.avr-asm-tutorial.net/avr_en/beginner )

	; ---	Man kan döpa om register med .def (define)

	.def	index	 = r16
	.def	offset   = r17

	; ---	Man kan och sätta konstanter med .equ (equate)

	.equ	minVariabel = $60 ; Början på SRAM

	; ---	Man kan säga var i programminnet koden 
	; ---	ska läggas med .org (origin)
	
	; --- Programmet körs alltid från rad 0

	.org	0		; Programstart här!
	jmp	START		; Första programraden
				; (man BEHÖVER inte göra hoppet)
				; (det är bara exempel på .org)

	nop
	nop			; Kod här hoppas över alltså
	nop

	; --- Programmet nedan gör bara nonsens för att visa lite instruktioner
	; --- Vid simulering: Titta i processorfönstret (Debug/Windows/Processor)
	; --- Se också SRAM i (Debug/Windows/Memory/Memory 1), rad 0x0060 påverkas
	
START:				
	ldi	r16,99		; r16 = decimal konstant 
	ldi	r17,$14		; r17 = hexadecimal konstant
	add	r16,r17		; r17 = r17+r16
	sts	$60,r16		; Lägg resultatet i minnet SRAM

	; --- Nu kommer samma som ovan men med fördefinierade namn enligt förut

	ldi	index,99	 
	ldi	offset,$14	
	add	index,offset	
	sts	minVariabel,index

	; --- Visst blev det något mer läsbart? Till och med utan kommentarer.

	; --- Nytt exempel. Lagra minsta av r20 och r21 i r20

comp:
	ldi	r20,46		; ena talet	
	ldi	r21,23		; andra talet
	cp	r20,r21		; r20 - r21, uppdatera flaggor (ZNVCH)
	brpl	R21MINST	; hoppa om (r20-r21) > 0, dvs enbart N-flaggan
	jmp	KLAR		; kommer vi hit tydligen var r20 minst...
R21MINST:
	mov	r20,r21		; ...annars var r21 minst
KLAR:	
	nop			; här är r20=min(r20,r21)
	nop

	; --- Fortsätter med lite minnespetande

	; --- Sätt Z-pekaren till att peka på minVariabel i SRAM

	ldi	ZH,HIGH(minVariabel)	; HIGH($0060)=00
	ldi	ZL,LOW(minVariabel)	; LOW($0060)=60

	ld	r20,Z		; hämta det som Z=ZH:ZL pekar på
				; dvs det som sts ovan lade dit
	inc	r20		; r20++
	st	Z,r20		; lägg tillbaks det i SRAM
	adiw	Z,$10		; Peka $10 bytes längre fram i minnet
	st	Z,r20		; Lägg r20 där också

	; --- Avslutar med (nästan) DELAY från lab1

	; --- För att "sbi PORTB,7" ska funka måste port B
	; --- konfigureras som utgång först.
CONFIG:
	ldi	r16,$80		; DataDirectionRegisterB = $80 = "1000 0000" 
	out	DDRB,r16	; bit 7 utgång, alla andra ingång
	
	; --- Öppna fönstret I/O View och klicka på PORTB för att se
	; --- hur bit 7 blir 1 vid sbi (set bit) och 0 vid cbi (clear bit)
	; --- I labben är sbi/cbi på andra ställen men principen är densamma
	; --- Här är läge att sätta brytpunkter (F9) 
	; --- och sedan köra fullfart (F5) till nästa brytpunkt (spar tid!)

DELAY:
	ldi	r16,21
delayYttreLoop:
	sbi	PORTB,7
	ldi	r17,$ff
delayInreLoop:
	dec	r17
	brne	delayInreLoop
	cbi	PORTB,7
	dec	r16
	brne	delayYttreLoop
FOREVER:
	jmp	FOREVER		; Fastna här för alltid.