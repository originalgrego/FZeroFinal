;=========================================
org $0396F3
Load_Top_Down_Cars_GFX:
	PHP
	SEP #$20
	LDA $0F51  ; Player car type (Master Ending, $52 is now zero -- WILL NOT NEED TO BE 00 AFTER WE'VE DONE CHECKPOINT ROUTING INSTEAD OF PLAYBACK INPUTS!)
	BIT #$10
	BEQ .FZ_top_down_GFX

	JSL GP2_Load_Top_Down_Cars_GFX
	PLP
	RTS

.FZ_top_down_GFX
	JSL FZ_Load_Top_Down_Cars_GFX
	PLP
	RTS
;=========================================
