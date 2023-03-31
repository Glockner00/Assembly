;
; AssemblerApplication2.asm
;
; Created: 3/30/2023 10:13:59 AM
; Author : axelg
;


; Replace with your application code
start:
    ;Uppgift 1
	;ldi r16, 198
	;ldi r17, $64 
	;ldi r18, $93 

	;Uppgift 2
	;mov r18, r16

;Uppgift 3
	;ldi ZH, high(110)
	;ldi ZL, low(110)
	;lpm
	;ldi ZH, high(112)
	;ldi ZL, low(112)
	;st Z, R0

;uppgift 3
	;lds r16, 0x110
	;sts 0x112, r16

;Uppgift 4
	;ldi r16,1
	;ldi r17,2
	;ldi r18,3
	
	;sts $110, r16
	;sts $111, r17

	;lds r19, $110
	;lds r20, $111

	;adc r19,r20
	;sts $112, r19

;uppgift 5
	;lds r16, $110
	;lsl r16
	;sts $111, r16

;uppgift 6
	;ldi r16, $93
	;andi r16, $0F

;uppgift 7
	;ldi r16, $93
	;ori r16, $E0

;uppgift 8
	
;uppgift 9

;uppgift 10

;uppgift 11

;uppgift 12


