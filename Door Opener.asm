; Motion Sensing Automatic Door Opener
; Written for the Freescale Mc9S12C32 embedded microcontroller
; Written by Robert Palagano

; export symbols
        	XDEF Entry        		; export 'Entry' symbol
	        ABSENTRY Entry    		; for absolute assembly: mark this as application entry point
	        INCLUDE 'mc9s12c32.inc'		; include derivative specific macros

; CONSTANT DEFINITIONS
ROMStart  	EQU  $C000			; absolute address to place code/constant data
TC1MS     	EQU  1996  			; 1ms delay constant, adjust if necessary
TP1		EQU  %00000001			; constant to load into port T
TP2		EQU  %00000010			; constant to load into port T
input       	EQU  %00000100			; constant to load into port T
delay		EQU  10 			; how long to delay in ms
inicount  	EQU  240			; initial count

; variable/data section
          	ORG $0900			; location in memory to store data and variables
count       	ds.b 1      			; Variable used as a counter

; code section
	        ORG ROMStart
Entry:      	lds  #$1000   			; initialize the stack pointer

start      					; setup port T with needed input/output declarations
		bset  DDRT, #TP1
		bset  DDRT, #TP2
		bclr  DDRT, #input
					  
		ldd   #5000			; load D with '5000'
		jsr   WaitDms			; jump to subroutine to wait 5000 ms

						; wait for Motion detector to trigger
check       	ldaa  PTT			; load A with contents of port T
            	bita  #input			; A * input
            	bne   bithigh			; if = 0, jump to bithigh
            	bra   check			; branch back to check			  

bithigh     	movb #inicount, count		; move initial count into count
	        bclr PTT, #TP2			; clear bits in port T
forwards	bclr PTT, #TP1
        	ldd  #delay			; load D with '10'
          	jsr  WaitDms			; jump to subroutine and wait 10 ms
          
          	bset PTT, #TP2			; instructions to turn motor
          	ldd  #delay
          	jsr  WaitDms
          
       		bset PTT, #TP1
          	ldd  #delay
          	jsr  WaitDms
          
          	bclr PTT, #TP2
        	ldd  #delay
          	jsr  WaitDms
          
          	dec  count			; decrement count
		bne  forwards			; if count != 0, return to forwards

		ldd  #3000			; load D with '3000'
		jsr  WaitDms			; wait 3000 ms for person to enter door

		movb #inicount, count		; reinitialize count

	        bclr PTT, #TP2			; clear bits in port T
backwards 	bset PTT, #TP1    		; set bits in port T
  	        ldd  #delay          		; wait 10 ms
	        jsr  WaitDms			

	        bset PTT, #TP2   		; instructions to turn motor
	        ldd  #delay          
	        jsr  WaitDms			

		bclr PTT, #TP1    
	        ldd  #delay          
	        jsr  WaitDms			

		bclr PTT, #TP2    
	        ldd  #delay          
	        jsr  WaitDms
	        
        	dec  count			; decrement count
		bne  backwards			; if count != 0, return to backwards

		bra  check			; branch to check and wait for motion sensor

;***********************
; Begin of subr. WaitDms
; wait D ms
; Argu passed thru ACC. D
;***********************

WaitDms	  	pshd
msdlp	    	jsr   Dly1ms
	        subd  #1
	        bne   msdlp
	        puld
	        rts

;******************
; Begin of Subr. Dly1ms
; A one ms delay loop
;**********************

Dly1ms	  	pshx		      		;dump current X contents to STACK
	        ldx   #TC1MS	        
d1mslp	  	dex
	        bne   d1mslp	        
	        pulx          			;restore X contents from STACK
          	rts

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
          	ORG   $FFFE
          	FDB   Entry      		; Reset