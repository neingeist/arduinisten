.INCLUDE "tn13def.inc"

	sbi DDRB, 1 ; PB1
loop:
	cbi PORTB, 1

loop1:
 	sbiw ZL, 1
	brne loop1

	sbi PORTB, 1

loop2:
	sbiw ZL, 1
	brne loop2

	rjmp loop
