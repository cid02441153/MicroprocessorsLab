	#include <xc.inc>
	
global SPI_MasterInit, SPI_MasterTransmit

psect	SPI_code,class=CODE
	
SPI_MasterInit: ; Initialises SPI (setting portD4 and portD6, etc)
    bcf	    CKE2
    
    movlw   (SSP2CON1_SSPEN_MASK) | (SSP2CON1_CKP_MASK) | (SSP2CON1_SSPM1_MASK)
    movwf   SSP2CON1, A
    
    bcf	    TRISD, PORTD_SDO2_POSN, A ; Set SDO2 to output
    bcf	    TRISD, PORTD_SCK2_POSN, A ; Set SCK2 to output
    bsf	    TRISD, 5, A ; Set SDI to input
    return
   
 SPI_MasterTransmit: ; Sends what is stored in working register down PortD4
    bcf	    PIR2, 5 ; Clear SPI interrupt flag
    movwf   SSP2BUF, A
    
 Wait_Transmit: ; Waits for the byte to be sent
    btfss   PIR2, 5
    bra	    Wait_Transmit
    bcf	    PIR2, 5
    
    movf SSP2BUF, W, A ; Moves received byte into working register for reading
    
    return

end