;============================================================================
; Performs division via subtraction on the A register
; The X register is used to calculate the quotient, and should be set to #$00 to start
; 
; In: A contains the dividend
; Out: A contains the remainder, X contains the quotient
;============================================================================
macro Divide(DIVISOR)
.loop
	CMP #<DIVISOR>
	BMI .finish

	SEC
	SBC #<DIVISOR>
	INX
	BRA .loop
.finish
endmacro
