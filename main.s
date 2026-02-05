	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw 0xFF		    ; Hello my name is George! This is a push test!
	movwf TRISD, A		    ; Port D all inputs
	
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	
	bra 	test
loop:
	movff 	0x06, PORTC ; Move value from register 6 to Port C
	incf 	0x06, W, A ; Increment value of register 6, and store in W
test:
	
	movwf	0x06, A	    ; Test for end of loop condition
	
	movf PORTD, W, A    ; Read in value from Port D, store in Access
	
	cpfsgt 	0x06, A	    ; Compares register 6 to what is stored in W
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

	end	main
