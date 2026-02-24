#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi
    
psect data_acs
delay_count: ds 1

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi
	
start:	call	DAC_Setup

loop: 
    
    call move_right
    bra loop 
    
move_left:
    movlw 0x80
    cpfsgt TMR0L
    return
    
    movlw 0x44
    cpfsgt  TMR0H ; compare w and f, skip if greater than 
    return
    
    bcf PORTD, 2, A
    return
    
move_right:
    movlw 0x16
    cpfsgt TMR0L
    return
    
    movlw 0x3A
    cpfsgt  TMR0H ; compare w and f, skip if greater than 
    return
    
    bcf PORTD, 2, A
    return

delay:
    movlw 0xFF
    movwf delay_count
delayloop:
    decfsz delay_count, F
    bra delayloop
    return

	end	rst
