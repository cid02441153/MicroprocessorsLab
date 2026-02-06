	#include <xc.inc>

psect	code, abs
main:
	org 0x0
	
	movlw 0x00
	movwf TRISC, A	; Make Port C and output
	
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	
	goto	start
	; ******* My data and where to put it in RAM *
myTable:
	db	0x80, 0xC0, 0xE0, 0xF0, 0xF1, 0xF3, 0xF7, 0xFF, 0x7F, 0x3F
	db	0x1F, 0x0F, 0x0E, 0x0C, 0x08, 0x00
	myArray EQU 0x400	; Address in RAM for data
	counter EQU 0x20	; Address of counter variable
	align	2		; ensure alignment of subsequent instructions 
	; ******* Main programme *********************
start:
	
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A	; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A	; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A	; load low byte to TBLPTRL
	movlw	16		; 22 bytes to read
	movwf 	counter, A	; our counter register
loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
	movff	TABLAT, PORTC
	
	; ******* Define large number for delay *******
	movlw low highword(0xFFFFF)
	movwf 0x12, A
	movlw high(0xFFFFFF) 
	movwf 0x11, A 
	movlw low(0xFFFFFF) 
	movwf 0x10, A 
	call Delay
	decfsz	counter, A	; count down to zero
	bra	loop		; keep going until finished
	
    goto	0
	
; ******* Delay Subroutine *******
Delay: 
    movlw 0x00 ;move literal 0 to working reg
Dloop: 
    decf 0x10, f, A ; decrements lower byte by 0x11
    subwfb 0x11, f, A
    subwfb 0x12, f, A ; subtract w and borrow from f
    bc Dloop ; if carry bit, loop again
    return	
	

	end	main
