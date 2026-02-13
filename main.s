	#include <xc.inc>

psect	code, abs
	
main:    
    call    SPI_MasterInit

setup:
    
    movlw 0x00
    movwf TRISE, A
    
    bcf CFGS
    bsf EEPGD
    goto start
    
myTable:
    db 0xF0, 0x10, 0xF0, 0x10, 0xF0, 0x10, 0xF0, 0x10
    
    myArray EQU 0x400
    counter EQU 0x20
    align 2

start:
    lfsr    0, myArray
    movlw   low highword(myTable)
    movwf   TBLPTRU, A
    movlw   high(myTable)
    movwf   TBLPTRH, A
    movlw   low(myTable)
    movwf   TBLPTRL, A
    movlw 8
    movwf counter, A
    
loop:

    tblrd*+
    movff   TABLAT, POSTINC0
    movf    TABLAT, W, A
    movwf   PORTE, A
    call    SPI_MasterTransmit
    
    ; Delay
    movlw low highword(0xFFFFFF)
    movwf 0x12, A
    movlw high(0xFFFFFF)
    movwf 0x11, A
    movlw low(0xFFFFFF)
    movwf 0x10, A
    call Delay
    
    decfsz  counter, A
    bra     loop
    
    
    goto 0

    
Delay:
    movlw 0x00
DLoop:
    decf 0x10, f, A
    subwfb 0x11, f, A
    subwfb 0x12, f, A
    bc DLoop
    return
    
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
	
end main