;==================================
; SRAM fixes for F-Zero Final, expands the SRAM so that more leagues and tracks can be supported.
; Also modifies how SRAM address offsets are calculated, the original game used a table of addresses, now
; a calculation is done to determine offset.  Finally, the SRAM mirror that was stored in system ram was disabled,
; all SRAM modifications are now made directly to SRAM.
;==================================

!SRAM_OFFSET equ $0EED
!MASTER_UNLOCK_BITS equ $70FFFA

;==================================
; Expand the SRAM
org $00FFD8
	DB $04

;==================================
; SRAM now ends at $701000 instead of $700200
org $02C4E0
	LDX #$0FFF

;==================================
; Hijack the "SRAM init" routine so it doesn't
; check for corrupted checksums or copy the
; whole $700000 SRAM to "SRAM_Buffer" ($7F4800)
org $02C4B9
SRAM_Init_Hijack:
	CMP #$02
	BEQ .all_good
	JSR Reset_SRAM ; SRAM is corrupted (was not initialized yet), reset it
.all_good
	PLP
	RTL

;==================================
; Hijack the "reset SRAM" routine
org $02C588
	LDX #$0005
	JSR Reset_SRAM
	LDA #$00
	STA !MASTER_UNLOCK_BITS
	RTS

org $02C508 ; Previously a "reset SRAM" routine, now freespace
Reset_SRAM:
	LDX #$0005
	LDY.w #55*10 ; Clear space reserved for 10 leagues!
	-	LDA #$09
		STA $700000,x
		INX
		LDA #$59
		STA $700000,x
		INX
		LDA #$99
		STA $700000,x
		INX
		DEY
		BNE -
	RTS

;==================================
; Make "Save_Cup_SRAM" now just an RTS, since "SRAM_Buffer" is not used anymore
org $02C5C1
	RTS

;==================================
; Access SRAM directly instead of
; using the "SRAM_Buffer" ($7F4800)
org $00AB52
	LDA $700000,x
org $00AB5C
	LDA $700001,x
org $00AB66
	LDA $700002,x

org $00CF9A
	LDA $700000,x
org $00CFA0
	LDA $700001,x
org $00CFA6
	LDA $700002,x

org $02C3A6
	LDA $700000,x
org $02C3B8
	CMP $700001,x
org $02C3C1
	CMP $700002,x

org $02C439
	LDA $700000,x
	STA $700003,x

org $02C44B
	STA $700000,x
org $02C452
	STA $700001,x
org $02C459
	STA $700002,x

org $02C46A
	STA $700000,x
org $02C471
	STA $700001,x
org $02C478
	STA $700002,x

org $02C5A9
	STA $700000,x
org $02C5B0
	STA $700000,x
org $02C5B7
	STA $700000,x

; SEE BELOW FOR $038216
; SEE BELOW FOR $03824D
; SEE BELOW FOR $038313
; SEE BELOW FOR $038337
; SEE BELOW FOR $03834F

org $0387EB
	LDA !MASTER_UNLOCK_BITS

org $038E77
	LDA $700000,x
org $038E7E
	LDA $700000,x

org $038E94
	LDA $700000,x
org $038E9D
	LDA $700001,x
org $038EA7
	LDA $700002,x

org $038F6B
	LDA $700000,x

org $039BE8
	LDA !MASTER_UNLOCK_BITS
org $039BF1
	ORA $039C0D,x
	BRA $0C   ; Same as a whole lot of NOPs (STILL NEED TO VERIFY IF THIS IS CORRECT, LUL)

;==================================
; Don't need to call "Save_Cup_SRAM" anymore...
org $02C3C9
	BRA $01 ; NOP*3, previously JSR $C5C1

org $02C422
	BRA $01 ; NOP*3, previously JSR $C5C1

;==================================
; Use a new routine to calculate the SRAM offset of a track
org $02C332
	JSL Set_SRAM_Offset
	PLP
	RTL

org $02C3D2
	LDX !SRAM_OFFSET

org $02C5A1
	LDX !SRAM_OFFSET

org $038244
Load_Records_Screen:
	JSR Hijack_Get_First_Track_Record
	STA $F2
	BRA .skip_shit
org $038259
.skip_shit

org $03830C
Get_Valid_Records_Upper_Option:
	TAY
	JSR Get_Record_Existance_For_Track
	BPL .try_next_track
	RTS
org $038301
.try_next_track

org $038330
Get_Valid_Records_Lower_Option:
	TAY
	JSR Get_Record_Existance_For_Track
	BPL .try_next_track
	RTS
org $038320
.try_next_track

org $038348
Set_Records_Option_If_Valid:
	TAY
	JSR Get_Record_Existance_For_Track
	BRA .skip_shit
org $038355
.skip_shit

org $038CB6
	JSR Hijack_Load_Records_Menu
	BRA $02 ; NOP*4

;==================================
; Use an additive method to get the SRAM offset for
; each track, instead of using a table of 15 entries
org $03820B
	JSR Hijack_Get_First_Track_Record ; JSR since there's enough freespace in bank 03
	RTS

;==================================
; In:
;   X - League number
;   Y - Track number
; Out:
;   A/X - SRAM offset
;==================================
org $02C5C1 ; Old "Copy buffer to SRAM" routine, now unused since accesses are made directly to SRAM
Get_SRAM_Offset:
	REP #$10
	PHY
	SEP #$10    ; \ Clear high byte from indexes
	REP #$30    ; / (YEP! That's a thing from the 65816!)
	LDA #$0005  ; Start at offset 0005 because of the SRAM header
	CLC         ; CLC only here since this should be impossible to roll over from 0xFFFF -> 0x0000
	.loop_league
		DEX
		BMI   .loop_track
		ADC.w #33*5
		BRA   .loop_league
	.loop_track
		DEY
		BMI   .ret
		ADC.w #33
		BRA   .loop_track
.ret
	TAX
	PLY
	RTL

Set_SRAM_Offset:
	LDA $58
	BNE .practice_mode
	LDY $53
	LDX $90
	BRA .get_and_set_offset

.practice_mode
	LDX #$00
	LDA $53
	%Divide($05)
	TAY ; Track number in Y  (remainder of division)
	TXA ; League number in X (quotient of division)
.get_and_set_offset
	JSL Get_SRAM_Offset ; Use the new "Get_SRAM_Offset" routine
	STX !SRAM_OFFSET
	RTL

;==================================
; New routines in freespace
;==================================
; Gets the first track where there is a record
org $039E80
Hijack_Get_First_Track_Record:
	PHP
	REP #$10
	LDX #$0005
	LDY #$0000
	-	SEP #$20
		LDA $700000,x ; $038216
		BMI .found_record
		REP #$20
		INY
		CPY.w #20     ; Last track index
		BCS .found_record
		TXA
		CLC
		ADC.w #33
		TAX
		BRA -
.found_record
	TYA
	PLP
	RTS

;==================================
; Modify the "Load_Records_Menu" routine
Hijack_Load_Records_Menu:
	PHY
	TYA
	LSR A
	TAY
	LDX #$0000
	JSL Get_SRAM_Offset
	PLY
	DEX
	LDA $700000,x
	RTS

;==================================
; Find out if a record exists for a track
;
; In:
;   Y - Track number
;==================================
Get_Record_Existance_For_Track:
	LDX #$00
	JSL Get_SRAM_Offset
	SEP #$20
	LDA $700000,x ; $03834F
	SEP #$10
	RTS
