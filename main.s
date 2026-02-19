#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Clear, LCD_Move_Cursor, LCD_Line2, LCD_Write_Character
extrn	KeyPad_Setup, KeyPad_Read
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
temp:	    ds 1
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	movlw 0xFF 
	movwf delay_count, A 
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	call KeyPad_Setup
	
loop: 	
	
	call KeyPad_Read
	
	movwf temp, A
	
	movlw 0x00
	cpfseq temp, A
	call check_err
	
	bra loop

	goto	$		; goto current line in code
	
check_err:
	movlw 0xFF
	cpfseq temp, A
	call write_char
	return
	
write_char:
	movf temp, W, A
	call LCD_Write_Character
	return
	

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst