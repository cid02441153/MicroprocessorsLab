#include <xc.inc>
ANCON3 equ 0xF4A

psect udata_acs
D1: ds 1
D2: ds 1
D3: ds 1
ACCEL_X_H: ds 1
POS_H:     ds 1 
POS_L:     ds 1 
TEMP:      ds 1

psect code, abs
main:
    org 0x0000
    goto setup

setup:
    banksel OSCCON
    movlw 0x70
    movwf OSCCON, b      ; 16MHz
    
    ; 1. Digital Setup
    banksel ANCON3
    clrf ANCON3, b       

    banksel TRISD
    bcf TRISD, 2, b      ; RD2 -> SERVO
    bcf TRISD, 0, b      ; CS
    bcf TRISD, 6, b      ; SCK
    bcf TRISD, 4, b      ; SDO
    bsf TRISD, 5, b      ; SDI

    banksel TRISE
    clrf TRISE, b        ; LEDs Output
    banksel LATE
    movlw 0xAA           ; Pattern to show PIC is alive
    movwf LATE, b

    banksel LATD
    bsf LATD, 0, b       ; CS High
    
    ; 2. SPI Setup
    banksel SSP2CON1
    clrf SSP2CON1, b
    movlw 0x32           ; SPI Enable
    movwf SSP2CON1, b

    ; 3. Wait for Sensor to power up
    call Delay_Rest
    call LSM9DS1_Wakeup

loop:
    ; 4. Read Sensor
    call LSM9DS1_ReadX

    ; 5. Show Data on LEDs
    banksel LATE
    movf ACCEL_X_H, W, c
    movwf LATE, b

    ; 6. Calculate Pulse (Target 1.5ms = 1000 Ticks)
    ; If the motor spins constantly, we might be sending too many ticks.
    ; Let's use a conservative 1.5ms center.
    movlw 0xE8           
    movwf POS_L, c
    movlw 0x03           
    movwf POS_H, c

    movf ACCEL_X_H, W, c
    movwf TEMP, c
    
    tstfsz TEMP, c
    call Apply_Gain

Send_Pulse:
    ; 7. PWM (RD2)
    banksel LATD
    bsf LATD, 2, b       
    call Delay_us        
    banksel LATD
    bcf LATD, 2, b       
    
    call Delay_Rest      
    bra loop

Apply_Gain:
    ; Gain x16 (Quick Swap)
    ; This is safer than x64 for a first test
    swapf TEMP, W, c
    andlw 0xF0
    movwf TEMP, c
    
    btfss ACCEL_X_H, 7, c
    bra Pos_Move

Neg_Move:
    ; Absolute value of swapped temp
    comf TEMP, f, c
    incf TEMP, f, c
    movf TEMP, W, c
    subwf POS_L, f, c
    btfss STATUS, 0, c
    decf POS_H, f, c
    return

Pos_Move:
    movf TEMP, W, c
    addwf POS_L, f, c
    btfsc STATUS, 0, c
    incf POS_H, f, c
    return

Delay_us:
    movff POS_L, D1
    movff POS_H, D2
L_us:
    decfsz D1, f, c
    bra L_us
    decfsz D2, f, c
    bra L_us
    return

Delay_Rest:
    movlw 0x22
    movwf D3, c
DR1: movlw 0xFF
    movwf D2, c
DR2: clrwdt
    decfsz D2, f, c
    bra DR2
    decfsz D3, f, c
    bra DR1
    return

LSM9DS1_Wakeup:
    banksel LATD
    bcf LATD, 0, b
    movlw 0x20
    call SPI_Xchg
    movlw 0x60           
    call SPI_Xchg
    banksel LATD
    bsf LATD, 0, b
    return

LSM9DS1_ReadX:
    banksel LATD
    bcf LATD, 0, b
    movlw 0xA9           
    call SPI_Xchg
    movlw 0x00
    call SPI_Xchg
    movwf ACCEL_X_H, c
    banksel LATD
    bsf LATD, 0, b
    return

SPI_Xchg:
    movwf SSP2BUF, c
W_S: btfss SSP2STAT, 0, c
    bra W_S
    movf SSP2BUF, W, c
    return

end main