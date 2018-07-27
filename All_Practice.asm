;=========================================================
; ALL PRACTICE MODE
;=========================================================

!Str_Buf equ $0480

; Last track = 20 (instead of 7)
org $008B4F
	CMP #$14

; Last track = 20-1 (instead of 7-1)
org $008B5B
	LDA #$13

; Change a BNE to BRA
org $009A63
	DB $80

; Load shortcut routine from GP table rather than practice
org $00D619
	LDA $00DAC6, x

; "Adjust track name" as in setting the appropriate track number and variation (I/II/III)
org $00AC0D
Adjust_Track_Name:
	JSL Adjust_Track_Name_Hijack
	NOP
	NOP

; HOPEFULLY FIX ALL CASES OF WEIRDNESS ON TRACKS 8 TO 15
org $02C33F
	JSL Get_Track_Num_x4

org $03915C
	JSL Get_Track_Num_x4

org $039171
	JSL Get_Track_Num_x4

; FIX THE MASTER ENDINGS
org $039D58
DB 4,9,14 ; SI, WL2, FF

; Freespace - NEW CODE GOES HERE
org $02C1CC

;=========================================================
;=========================================================
Get_Track_Num_x4:
	LDA $0EEC
	ASL A
	ASL A
	RTL
;=========================================================

;=========================================================
;=========================================================
Adjust_Track_Name_Hijack:
	CMP #$09 ; A = $53 at this point
	BCC .one_digit
	LDA !Str_Buf
	SEC
	SBC #$04
	STA !Str_Buf ; Move text X starting position 4 pixels to the left
	LDY #$FF
-	INY
	LDA !Str_Buf+3,y
	BNE -

; Y is now the offset to the last character in !Str_Buf
-	LDA !Str_Buf+3,y
	STA !Str_Buf+4,y ; Shift each character right once
	DEY
	BPL -

	PHX

	LDX #$00

	LDA $53
	INC A

	%Divide($0A)
	
	PHA
	TXA

	CLC
	ADC #$80 ;
	STA !Str_Buf+3

	PLA

	CLC
	ADC #$80
	STA !Str_Buf+4

	PLX

	RTL

.one_digit
	ADC #$81 ; += '1'
	STA !Str_Buf+3
	RTL
;=========================================================