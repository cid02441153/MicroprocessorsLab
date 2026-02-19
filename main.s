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
MAGNITUDE: ds 1
SKIP_CNT:  ds 1 ; Counter for pulse skipping

psect code, abs
main:
    org 0x0000
    goto setup

setup:
    banksel OSCCON
    movlw 0x70
    movwf OSCCON, b      ; 16MHz
    banksel ANCON3
    clrf ANCON3, b       
    banksel TRISD
    bcf TRISD, 2, b      ; RD2 -> SERVO
    bcf TRISD, 0, b      ; CS
    bcf TRISD, 6, b      ; SCK
    bcf TRISD, 4, b      ; SDO
    bsf TRISD, 5, b      ; SDI
    banksel TRISE
    clrf TRISE, b
    banksel LATD
    bsf LATD, 0, b       ; CS High
    banksel SSP2CON1
    movlw 0x32           
    movwf SSP2CON1, b
    
    clrf SKIP_CNT, c
    call Delay_Rest
    call LSM9DS1_Wakeup

loop:
    call LSM9DS1_ReadX

    ; 1. SHOW RAW DATA ON LEDS
    banksel LATE
    movf ACCEL_X_H, W, c
    movwf LATE, b

    ; 2. MAGNITUDE & DEADZONE
    movf ACCEL_X_H, W, c
    movwf MAGNITUDE, c
    btfsc MAGNITUDE, 7, c
    negf MAGNITUDE, c    

    movlw 4
    cpfslt MAGNITUDE, c  
    bra Pulse_Logic
    bra loop             ; Board flat = No signal

Pulse_Logic:
    ; 3. PULSE SKIPPING (The Speed Secret)
    ; We only send a pulse if SKIP_CNT >= (20 - MAGNITUDE)
    ; Large magnitude = Smaller wait = Faster speed
    incf SKIP_CNT, f, c
    
    movf MAGNITUDE, W, c
    sublw 20             ; Max wait of 20 cycles
    cpfslt SKIP_CNT, c
    bra Send_Pulse       ; Time to move!
    
    call Delay_Rest      ; Just wait, don't pulse
    bra loop

Send_Pulse:
    clrf SKIP_CNT, c     ; Reset skip counter
    
    ; 4. DIRECTIONAL PULSE
    ; We send a fixed "Step" pulse (1.0ms or 2.0ms)
    ; Since frequency handles speed, we don't need variable width.
    btfss ACCEL_X_H, 7, c
    bra Go_Right

Go_Left:
    movlw 0xE8           ; 1.0ms
    movwf POS_L, c
    movlw 0x03
    movwf POS_H, c
    bra Execute

Go_Right:
    movlw 0xD0           ; 2.0ms
    movwf POS_L, c
    movlw 0x07
    movwf POS_H, c

Execute:
    banksel LATD
    bsf LATD, 2, b       
    call Delay_us        
    banksel LATD
    bcf LATD, 2, b       
    
    call Delay_Rest      
    bra loop

; --- Support ---
Delay_us:
    movff POS_L, D1
    movff POS_H, D2
Lus: decfsz D1, f, c
    bra Lus
    decfsz D2, f, c
    bra Lus
    return

Delay_Rest:
    movlw 0x15           ; Faster loop for higher resolution skipping
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
WS: btfss SSP2STAT, 0, c
    bra WS
    movf SSP2BUF, W, c
    return

end main