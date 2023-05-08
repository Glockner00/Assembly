;
; Lab3-beta.asm
;
; Created: 02/05/2023 15:27:10
; Author : Olle, Axel
;

.def counter = r17		;sätter barar r17 som variabeln counter
.org $0000				;Sätter programmets startadress till 0x0000 aka första minnesadressen som avrbotten börjar

rjmp START

.org INT0addr			;Sätter adressen INTO-avbrottsvektorn "INT0addr" är en är en konstant. INT0 är för sekunder
rjmp INT0_handler				;Hoppar till när ett INTO-avbrott sker
 
.org INT1addr			;Sätter adressen INT1-avbrottsvektorn "INT1addr" är en är en konstant. INT1 är för minuter
rjmp INT1_handler				;Hoppar till när ett INT1-avbrott sker

START:
	ret					;vet inte hur loopen ska fungera

 INT0_handler:				;Här kommer vi hantera sekunder, så öka sekunder & uppdatera displayen
	inc sekunder

	cpi sekunder, 60	
	brne NO_SEC_RESET	;if (sekunder != 60) hoppa till NO_SEC_RESET
	
	clr sekunder 
	;call:a till funktion som uppdaterar minuter

	NO_SEC_RESET:
	ldi min_or_sec, 1	;laddar variabeln med 1 så displayen uppdaterar sekunder
	mov variabel_namn, sekunder
	call UPDATE_DISPLAY
	reti

 INT1_handler:				;Här kommer vi hantera minuter, så öka minuter & uppdatera displayen
	inc minuter

	cpi minuter, 60	
	brne NO_Smin_RESET	;if (minuter != 60) hoppa till NO_SEC_RESET
	clr minuter 

	NO_SEC_RESET:
	ldi min_or_sec, 0	;laddar variabeln med 0 så displayen uppdaterar minuter
	mov variabel_namn, minuter
	call UPDATE_DISPLAY
	reti

UPDATE_DISPLAY			;i tar in två argument här, siffran som ska uppdateras i BCD format & om det är sekunder eller minuter som ska uppdateras
	cpi min_or_sec, 1	;om min_or_sec == 1 så är det sekunder, annars minuter
	brne UPDATE_MINUTES

	;inte säker hur jag gör detta

	jmp UPDATE_DISPLAY_DONE

	UPDATE_SECONDS:
	;inte säker hur jag gör detta

	UPDATE_DISPLAY_DONE:
	;oavsett om minuter eller sekunder så skickar vi ut en signal i PORTA som är 1 som bara säger åt displayen att uppdatera sig.
	ret

.dseg					;Börjar definitionen av data-segmentet. Används för att lagra variabler och data som används i programmet
.org $200

TIME:					;Sätter storlek på time, vi kan ändra siffra beroende på
	.byte 4

.cseg					;Börjar definitionen av kod-segementet
.org $100				;Sätter startadressen för kodsegmentet till 0x0100

TAB: 
	.db 10,6,10,6		;TAB är en tabell med exempelsiffror från lektionen
 
BCD_CODE:				;BCD koden för siffror 0-9 där 0 är på plats noll & 9 på plats 10.
	.db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$FF,$67 