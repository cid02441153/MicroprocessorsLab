	#include <xc.inc>
	
global Setup_Accel, Read_Accel, SPI_MasterInit
	
psect	udata_acs ; Reserve data in access RAM
ACCEL_X_H: ds 1
ACCEL_X_L: ds 1
ACCEL_Y_H: ds 1
ACCEL_Y_L: ds 1
D0: ds 1
D1: ds 1
D2: ds 1


psect	code, abs
	
main:    
    org 0x0

setup:
    ; Set Port D, E, and F to outputs
    movlw 0x00
    movwf TRISF, A ; Port F shows Y axis rotation
    movwf TRISE, A ; Port E shows X axis rotation
    movwf TRISD, A
    
    call    SPI_MasterInit
    call    Setup_Accel
    
    call Delay
    
    goto start

start:
    
    
    
loop:
    ; Read data from accelerometer for X / Y rotation
    ; Store X / Y rotation in memory
    ; Output to Ports E and F
    
    
    call    Read_Accel
    
    ; Delay
    call Delay
    
    
    bra     loop ; infinite loop
    goto 0

Delay:
    movlw low highword(0x0FFFFF)
    movwf D2, A
    movlw high(0x0FFFFF)
    movwf D1, A
    movlw low(0x0FFFFF)
    movwf D0, A
    
    movlw 0x00
DLoop:
    decf D0, f, A
    subwfb D1, f, A
    subwfb D2, f, A
    bc DLoop
    return
    
end main