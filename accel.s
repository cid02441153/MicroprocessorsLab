	#include <xc.inc>

global Read_Accel, Setup_Accel

extrn ACCEL_X_H, ACCEL_X_L
extrn ACCEL_Y_H, ACCEL_Y_L
extrn SPI_MasterTransmit

psect	accel_code,class=CODE
	
Setup_Accel:
    call Wake_Accel
    call Enable_Increment

Wake_Accel:
    
    banksel LATD
    bcf LATD, 0, b ; Set CS to low
    
    movlw 0x20
    call SPI_MasterTransmit ; Select register 0x20 := CTRL_REG6_XL
    
    movlw 0x60
    call SPI_MasterTransmit ; Send data 0x60 - 119Hz, ±2g
    
    banksel LATD
    bsf LATD, 0, b ; Set CS to high
    
    return
    
Read_Accel:
    
    banksel LATD
    bcf LATD, 0, b ; Set CS to low
    
    
    ; Registers 0x28, 0x29, 0x2A, 0x2B
    ; --> OUT_X_L_XL, OUT_X_H_XL, OUT_Y_L_XL, OUT_Y_H_XL
    ; IF_ADD_INC enabled earlier, so each dummy byte moves to the next register
    
    movlw 0xA8 ; Read starting at 0x28
    call SPI_MasterTransmit ; Select register 0x28 := OUT_X_L_XL
    
    movlw 0x00 ; Dummy byte
    call SPI_MasterTransmit ; Send dummy byte to read in value
    movwf ACCEL_X_L, A ; Store in memory
    
    movlw 0x00 ; Dummy byte
    call SPI_MasterTransmit ; Send dummy byte to read in value
    movwf ACCEL_X_H, A ; Store in memory
    
    movlw 0x00 ; Dummy byte
    call SPI_MasterTransmit ; Send dummy byte to read in value
    movwf ACCEL_Y_L, A ; Store in memory
    
    movlw 0x00 ; Dummy byte
    call SPI_MasterTransmit ; Send dummy byte to read in value
    movwf ACCEL_Y_H, A ; Store in memory
    
    banksel LATD
    bsf LATD, 0, b ; Set CS to high
    
    return
	
    
Enable_Increment:
    banksel LATD
    bcf LATD, 0, b ; Set CS to low
    
    ; Control Register 8 IF_ADD_INC = 1 loops over the registers
    movlw 0x22
    call SPI_MasterTransmit ; Points to register 0x22
    movlw 0x04
    call SPI_MasterTransmit ; Sets IF_ADD_INC bit to 1
    
    banksel LATD
    bsf LATD, 0, b ; Set CS to high
    
end