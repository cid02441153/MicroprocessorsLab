	#include <xc.inc>

psect	code, abs
main:
	org 0x0
	
	movlw 0x00
	movwf TRISC, A	; Make Port C and output
	movff TRISC, PORTC
	
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	goto	start
	; ******* My data and where to put it in RAM *
myTable:
	db	0x88, 0x44, 0x22, 0x11, 0x22, 0x44
	myArray EQU 0x400	; Address in RAM for data
	counter EQU 0x10	; Address of counter variable
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
	movlw	6		; 22 bytes to read
	movwf 	counter, A	; our counter register
loop:
        tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
	movff	TABLAT, PORTC
	decfsz	counter, A	; count down to zero
	movlw high(0xFFFF) 
	movwf 0x10, A 
	movlw low(0xFFFF) 
	movwf 0x11, A 
	call Delay 
	call Delay
	call Delay 
	call Delay
	call Delay 
	call Delay 
	
	bra	loop		; keep going until finished
	
; Delay Subroutine
Delay: 
    movlw 0x00 ;move literal 0 to working reg
Dloop: 
    decf 0x11, f, A ; decrements lower byte by 0x11
    subwfb 0x10, f, A ; subtract w and borrow from f
    bc Dloop ; if carry bit, loop again
    return	
	
    goto	0

	end	main
