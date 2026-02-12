	#include <xc.inc>

psect	code, abs
	
main:    
    call    SPI_MasterInit    

loop:
    
    call    Update_Shift_Register
    
    ; Delay
    movlw low highword(0xFFFFFF)
    movwf 0x12, A
    movlw high(0xFFFFFF)
    movwf 0x11, A
    movlw low(0xFFFFFF)
    movwf 0x10, A
    call Delay
    
    bra     loop

Delay:
    movlw 0x00
DLoop:
    decf 0x10, f, A
    subwfb 0x11, f, A
    subwfb 0x12, f, A
    bc DLoop
    return
    
Update_Shift_Register:
    movlw   0xFF              ; The data you want to display
    call    SPI_MasterTransmit ; This sends the 8 bits
    
    return
    
    goto    0
    
SPI_MasterInit:
    bcf	    CKE2
    
    movlw   (SSP2CON1_SSPEN_MASK) | (SSP2CON1_CKP_MASK) | (SSP2CON1_SSPM1_MASK)
    movwf   SSP2CON1, A
    
    bcf	    TRISD, PORTD_SDO2_POSN, A
    bcf	    TRISD, PORTD_SCK2_POSN, A
    return
   
 SPI_MasterTransmit:
    movwf   SSP2BUF, A
    
 Wait_Transmit:
    btfss   PIR2, 5
    bra	    Wait_Transmit
    bcf	    PIR2, 5
    return
	
    end	    main
