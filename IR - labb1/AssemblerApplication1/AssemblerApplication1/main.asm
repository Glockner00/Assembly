;
; AssemblerApplication1.asm
;
; Created: 3/30/2023 9:13:37 AM
; Author : axelg
; inshallah
;
; Replace with your application code
start:
	DELAY:
		sbi PORTB, 7
		ldi r16, 10
	
	delayYttreLoop:
		ldi r17, $1F
	
	delayInreLoop:
		dec r17
		brne delayInreLoop
		dec r16
		brne delayYttreLoop
		cbi PORTB, 7
		ret