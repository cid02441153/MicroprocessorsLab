#include <xc.inc>
    
global  KeyPad_Setup, KeyPad_Read

psect	udata_acs   ; reserve data space in access ram
columns:    ds	1
rows:	    ds  1
keys:	    ds	1

psect	keypad_code,class=CODE
KeyPad_Setup:
    movlb   15
    bsf	    REPU
    movlb   0
    clrf    LATE
    setf    TRISE
    clrf    PORTD
    
    return
    
KeyPad_Read:
    call Keypad_read_row
    call Keypad_read_col
    call Keypad_decode
    return
    
Keypad_read_row:
    movlw   0x0F
    movwf   TRISE   ; Set pins 4-7 to outputs
    call    Keypad_Delay
    movf    PORTE, W, A
    movwf   columns, A 
    
Keypad_read_col:
    movlw   0xF0
    movwf   TRISE   ; Set pins 4-7 to outputs
    call    Keypad_Delay
    movf    PORTE, W, A
    movwf   rows, A

Keypad_decode:
    movf    columns, W, A
    iorwf   rows, W, A	    ; Exclusive or (2 nibbles -> 1 byte)
    movwf   keys, A
    movwf   PORTD, A
test_no_key:
    movlw   0xFF
    cpfseq  keys, A
    bra	    test_key_1
    retlw   0x00
test_key_1:
    movlw   01110111b
    cpfseq  keys, A
    bra	    test_key_F
    retlw   '1'
    
test_key_F:
    movlw   11101110b
    cpfseq  keys, A
    retlw   0xff
    retlw   'F'	    ; returns error if no keys were found

