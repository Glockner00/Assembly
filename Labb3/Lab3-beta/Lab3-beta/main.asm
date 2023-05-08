;
; Lab3-beta.asm
;
; Created: 02/05/2023 15:27:10
; Author : Olle, Axel
;

.def counter = r17		;s�tter barar r17 som variabeln counter
.org $0000				;S�tter programmets startadress till 0x0000 aka f�rsta minnesadressen som avrbotten b�rjar

rjmp START

.org INT0addr			;S�tter adressen INTO-avbrottsvektorn "INT0addr" �r en �r en konstant. INT0 �r f�r sekunder
rjmp INT0_handler				;Hoppar till n�r ett INTO-avbrott sker
 
.org INT1addr			;S�tter adressen INT1-avbrottsvektorn "INT1addr" �r en �r en konstant. INT1 �r f�r minuter
rjmp INT1_handler				;Hoppar till n�r ett INT1-avbrott sker

START:
	ret					;vet inte hur loopen ska fungera

 INT0_handler:				;H�r kommer vi hantera sekunder, s� �ka sekunder & uppdatera displayen
	inc sekunder

	cpi sekunder, 60	
	brne NO_SEC_RESET	;if (sekunder != 60) hoppa till NO_SEC_RESET
	
	clr sekunder 
	;call:a till funktion som uppdaterar minuter

	NO_SEC_RESET:
	ldi min_or_sec, 1	;laddar variabeln med 1 s� displayen uppdaterar sekunder
	mov variabel_namn, sekunder
	call UPDATE_DISPLAY
	reti

 INT1_handler:				;H�r kommer vi hantera minuter, s� �ka minuter & uppdatera displayen
	inc minuter

	cpi minuter, 60	
	brne NO_Smin_RESET	;if (minuter != 60) hoppa till NO_SEC_RESET
	clr minuter 

	NO_SEC_RESET:
	ldi min_or_sec, 0	;laddar variabeln med 0 s� displayen uppdaterar minuter
	mov variabel_namn, minuter
	call UPDATE_DISPLAY
	reti

UPDATE_DISPLAY			;i tar in tv� argument h�r, siffran som ska uppdateras i BCD format & om det �r sekunder eller minuter som ska uppdateras
	cpi min_or_sec, 1	;om min_or_sec == 1 s� �r det sekunder, annars minuter
	brne UPDATE_MINUTES

	;inte s�ker hur jag g�r detta

	jmp UPDATE_DISPLAY_DONE

	UPDATE_SECONDS:
	;inte s�ker hur jag g�r detta

	UPDATE_DISPLAY_DONE:
	;oavsett om minuter eller sekunder s� skickar vi ut en signal i PORTA som �r 1 som bara s�ger �t displayen att uppdatera sig.
	ret

.dseg					;B�rjar definitionen av data-segmentet. Anv�nds f�r att lagra variabler och data som anv�nds i programmet
.org $200

TIME:					;S�tter storlek p� time, vi kan �ndra siffra beroende p�
	.byte 4

.cseg					;B�rjar definitionen av kod-segementet
.org $100				;S�tter startadressen f�r kodsegmentet till 0x0100

TAB: 
	.db 10,6,10,6		;TAB �r en tabell med exempelsiffror fr�n lektionen
 
BCD_CODE:				;BCD koden f�r siffror 0-9 d�r 0 �r p� plats noll & 9 p� plats 10.
	.db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$FF,$67 