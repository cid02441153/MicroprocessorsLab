#include <xc.inc>
    
global  KeyPad_Setup, KeyPad_Read

psect	udata_acs   ; reserve data space in access ram
columns:    ds	1
rows:	    ds  1
keys:	    ds	1
keypad_delay:	    ds	1

psect	keypad_code,class=CODE
KeyPad_Setup:
    
    movlb   15
    bsf	    REPU
    movlb   0
    
    movlw 0x00
    movwf TRISE, A
    movwf TRISD, A
    
    movlw 0xFF
    movwf keypad_delay, A
    
    return
    
KeyPad_Read:
    call Keypad_read_row
    call Keypad_read_col
    call Keypad_decode
    return
    
Keypad_read_row:
    clrf LATE
    
    movlw   0xF0
    movwf   TRISE   ; Set pins 4-7 to outputs
    
    call    Keypad_Delay
    movf    PORTE, W, A
    movwf   columns, A
    
    return
    
Keypad_read_col:
    clrf LATE
    
    movlw   0x0F
    movwf   TRISE   ; Set pins 0-3 to outputs
    
    call    Keypad_Delay
    
    movf    PORTE, W, A
    movwf   rows, A
    
    return

Keypad_decode:
    movf    columns, W, A
    xorwf   rows, W, A	    ; Exclusive or (2 nibbles -> 1 byte)
    movwf   keys, A
    movwf   PORTD, A
test_no_key:
    movlw   0xFF
    cpfseq  keys, A
    bra	    test_key_0
    retlw   0xBB
test_key_0:
    movlw   0xBE
    cpfseq  keys, A
    bra	    test_key_1
    retlw   0x00
test_key_1:
    movlw   0x77
    cpfseq  keys, A
    bra	    test_key_2
    retlw   0x01
test_key_2:
    movlw   0xB7
    cpfseq  keys, A
    bra	    test_key_3
    retlw   0x02
test_key_3:
    movlw   0xD7
    cpfseq  keys, A
    bra	    test_key_4
    retlw   0x03
test_key_4:
    movlw   0x7B
    cpfseq  keys, A
    bra	    test_key_5
    retlw   0x04
test_key_5:
    movlw   0xBB
    cpfseq  keys, A
    bra	    test_key_6
    retlw   0x05
test_key_6:
    movlw   0xDB
    cpfseq  keys, A
    bra	    test_key_7
    retlw   0x06
test_key_7:
    movlw   0x7D
    cpfseq  keys, A
    bra	    test_key_8
    retlw   0x07
test_key_8:
    movlw   0xBD
    cpfseq  keys, A
    bra	    test_key_9
    retlw   0x08
test_key_9:
    movlw   0xDD
    cpfseq  keys, A
    bra	    test_key_A
    retlw   0x09
test_key_A:
    movlw   0x7E
    cpfseq  keys, A
    bra	    test_key_B
    retlw   0x0A
test_key_B:
    movlw   0xDE
    cpfseq  keys, A
    bra	    test_key_C
    retlw   0x0B
test_key_C:
    movlw   0xEE
    cpfseq  keys, A
    bra	    test_key_D
    retlw   0x0C
test_key_D:
    movlw   0xED
    cpfseq  keys, A
    bra	    test_key_E
    retlw   0x0D
test_key_E:
    movlw   0xEB
    cpfseq  keys, A
    bra	    test_key_F
    retlw   0x0E
test_key_F:
    movlw   0xE7
    cpfseq  keys, A
    retlw   0xFF
    retlw   0x0F    ; returns error if no keys were found

Keypad_Delay:
    movlw 0xFF
    movwf keypad_delay
Delay_Loop:
    decfsz keypad_delay, A
    bra Delay_Loop
    return