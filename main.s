#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message
extrn	KeyPad_Setup, KeyPad_Read, LCD_Write_Hex 
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
temp:	    ds 1
ARG1L:	    ds 1
ARG1H:	    ds 1
ARG2L:	    ds 1
ARG2H:	    ds 1
RES0:	    ds 1
RES1:	    ds 1
RES2:	    ds 1
RES3:	    ds 1
    
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
	
	movlw 0x00
	movwf counter, A
	
	call display_calc
	
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	
loop: 	

	goto	$		; goto current line in code

 
display_calc: 
	movlw 0x04 
	movwf ARG1H, A 
	
	movlw 0xD2 
	movwf ARG1L, A 
	
	movlw 0x41 
	movwf ARG2H, A 
	
	movlw 0x8A 
	movwf ARG2L, A 
	
	call mult_16 
	
	movf RES3, W, A
	call LCD_Write_Hex

	movf RES2, W, A
	call LCD_Write_Hex

	movf RES1, W, A
	call LCD_Write_Hex

	movf RES0, W, A
	call LCD_Write_Hex
	
	return


mult_16: ; two numbers stored in va11
	; step 1: low nibble * low nibble
	movf	ARG1L, W, A
	mulwf	ARG2L, A ; Stored in PRODH:PRODL
	
	movff	PRODH, RES1
	movff	PRODL, RES0
	
	; step 2: high nibble * high nibble
	movf	ARG1H, W, A
	mulwf	ARG2H, A ; Stored in PRODH:PRODL
	
	movff	PRODH, RES3
	movff	PRODL, RES2
	
	; At this point:
	; RES3:RES2 stores high nibble * high nibble
	; RES1:RES0 stores low nibble * low nibble
	
	; step 3: low nibble * high nibble
	movf	ARG1L, W, A
	mulwf	ARG2H, A ; Stored in PRODH:PRODL
	
	movf	PRODL, W, A
	addwf	RES1, F, A
	movf	PRODH, W, A
	addwfc	RES2, F, A
	clrf	WREG, A
	addwfc	RES3, F, A
	
	; step 4: high nibble * low nibble
	movf	ARG1H, W, A
	mulwf	ARG2L, A ; Stored in PRODH:PRODL
	
	movf	PRODL, W, A
	addwf	RES1, F, A
	movf	PRODH, W, A
	addwfc	RES2, F, A
	clrf	WREG, A
	addwfc	RES3, F, A
	
	

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst

	
	