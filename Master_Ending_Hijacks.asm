;=========================================
;=========================================
FZ_Load_Top_Down_Cars_GFX:
	LDA #$80
	STA $2115
	REP #$30
	LDA #$5000
	STA $2116
	LDY #$0140
	LDX #$0000
	-	LDA.l $02CB80,x ; Where top down FZ cars graphics are stored
		STA $2118
		INX
		INX
		DEY
		BPL -
	SEP #$20
	STZ $52  ; Needed so playback goes correctly
	RTL
;=========================================

;=========================================
;=========================================
GP2_Load_Top_Down_Cars_GFX:
	LDA $0F51
	AND #$0F
	STA $0F51
	
	LDA #$80
	STA $2115
	REP #$30
	LDA #$5000
	STA $2116
	LDY #$0140
	LDX #$0000
	-	LDA.l Top_Down_GP2_Cars_GFX,x
		STA $2118
		INX
		INX
		DEY
		BPL -
	RTL
;=========================================
