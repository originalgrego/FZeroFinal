;=============================================================
; Extra tasty macros for GP2 method calls
;=============================================================

; Stores the players car selection on the stack and masks off the GP2 car selection bit (#$10) for GP2 method calls
macro Mask_Method_Pre()
	PHA
	PHP
	SEP #$20
	LDA !PLAYER_CAR_SELECTION
	PHA
	AND #$0F
	STA !PLAYER_CAR_SELECTION
endmacro

; Restores the players car selection after a GP2 method call
macro Mask_Method_Post()
	SEP #$20
	PLA
	STA !PLAYER_CAR_SELECTION
	PLP
	PLA
endmacro

; Sets the bank for a GP2 method call in addition to masking player car selection
macro GP2_Method_Pre(BANK_ADDR_S)
	PEA <BANK_ADDR_S>
	PLB
	%Mask_Method_Pre()
endmacro

; Restores the bank and car selection after a GP2 method call
macro GP2_Method_Post()
	%Mask_Method_Post()
	PLB
endmacro

; Macro to select the correct method to call based on whether the player is using a GP2 vehicle
macro Method_Select(TEST_VALUE, FZ_LABEL)
	lda !PLAYER_CAR_SELECTION
	bit <TEST_VALUE>
	bne .do_gp2
	
	BRA <FZ_LABEL>
	
.do_gp2
endmacro

; Masks the loading of !PLAYER_CAR_SELECTION
macro Mask_Car_Load(MASK)
	LDA !PLAYER_CAR_SELECTION
	AND <MASK>
endmacro
;=============================================================

;=========================================================
; Masks the prestart accel car loading
;=========================================================
Hijack_Prestart_Accel:
	%Mask_Car_Load(#$0F)
	TAX
	
	LDA $0b20

	JML $00fa2a
;=========================================================
	
;=========================================================
; Masks car loading while initializing ai vehicles
;=========================================================
Hijack_Init_AI_Cars:
	%Mask_Car_Load(#$0F)

	ASL A
	ASL A

	JML $00d2f3
;=========================================================

;=========================================================
; Hijacks Init_Player_Car to load palettes for GP2/FZ vehicles, this is moved from Load_Track_Pal for convenience.
; Special handling is required for master endings as the player's car selection moves to $0F51.
;=========================================================
Hijack_Init_Player_Car:
	JSR Load_Base_Vehicle_Palettes_FZ

	%Method_Select(#$10, .check_for_master_ending)
	
	LDA $58
	BEQ .not_practice
	
	JSR Load_Vehicle_Palette_Prep
	LDY #$0680
	MVN $00,$1F
	SEP #$30

	BRA .continue_gp2
	
.not_practice
	JSR Load_GP2_Vehicle_Palette
	
.continue_gp2
	%GP2_Method_Pre($0010)
	JSL Init_Player_Car_GP2
	%GP2_Method_Post()
	
	JML Init_Player_Car_FZ_Exit
	
.check_for_master_ending
	LDA $0F50
	BEQ .do_fz_init_player_car ; If not Playing master ending, skip GP2 palette
	LDA $0F51
	BIT #$10
	BEQ .exit ; If master ending car is an FZ car, skip GP2 palette
	
	; A copy of "Load_GP2_Vehicle_Palette", but a little different
	REP #$30
	LDA $0F51
	JSR Load_Vehicle_Palette_Prep_A
	MVN $00,$1F
	SEP #$30
	; A copy of "Load_GP2_Vehicle_Palette", but a little different
	
	bra .exit
	
.do_fz_init_player_car

	LDA $58
	BEQ .exit
	
	JSR Load_Vehicle_Palette_Prep
	LDY #$0680
	MVN $00,$0F
	SEP #$30
	
.exit
	JML Init_Player_Car_FZ
;=========================================================

;=========================================================
; Loads the palette for the FZ car selection screen
;=========================================================
Load_Car_Select_Screen_Palette_FZ:

	REP #$30

	LDA #$00fd
	LDX #$e102
	LDY #$0502
	MVN $00, $0e

	SEP #$30
	
	JSR Load_Base_Vehicle_Palettes_FZ

	RTS
;=========================================================

;=========================================================
; Loads the palette for the GP2 car selection screen
;=========================================================
Load_Car_Select_Screen_Palette_GP2:

	REP #$30

	LDA #$00fd
	LDX #$e102
	LDY #$0502
	MVN $00, $1e

	SEP #$30
	
	JSR Load_Base_Vehicle_Palettes_GP2

	RTS
;=========================================================

;=========================================================
; Loads all base vehicle palettes for FZ
;=========================================================
Load_Base_Vehicle_Palettes_FZ:
	REP #$30

	LDA #$00ff
	LDX #$cd00
	LDY #$0600
	MVN $00,$0f
	
	SEP #$30

	RTS
;=========================================================

;=========================================================
; Loads all base vehicle palettes for GP2
;=========================================================
Load_Base_Vehicle_Palettes_GP2:
	REP #$30

	LDA #$00ff
	LDX #$cd00
	LDY #$0600
	MVN $00,$1f
	
	SEP #$30

	RTS
;=========================================================

;=========================================================
; Loads a single GP2 vehicle's palette into the players palette slot
;=========================================================
Load_GP2_Vehicle_Palette:
	JSR Load_Vehicle_Palette_Prep

	MVN $00,$1f

	SEP #$30
	
	RTS
;=========================================================

;=========================================================
; Loads a single FZ vehicle's palette into the players palette slot
;=========================================================
Load_FZ_Vehicle_Palette:
	JSR Load_Vehicle_Palette_Prep

	MVN $00,$0f

	SEP #$30
	
	RTS
;=========================================================
	
;=========================================================
; Common method for loading vehicle palettes
;=========================================================
Load_Vehicle_Palette_Prep:
	REP #$30
	
	LDA !PLAYER_CAR_SELECTION

Load_Vehicle_Palette_Prep_A: ; Receives CAR TYPE in A
	AND #$000f
	
	CLC
	ASL a ; Multiply by 32!
	ASL a
	ASL a
	ASL a
	ASL a
	
	PHA
	
	ADC #$cd80
	TAX
	
	PLA 
	
	ADC #$0680
	TAY
	
	LDA #$001f
	
	RTS
;=========================================================

;=========================================================
; Mask player car selection for the rest of Draw_Car_5_Out_Of_Race
;=========================================================
Hijack_Draw_Car_5_Out_Of_Race:
	LDA !PLAYER_CAR_SELECTION
	STA $113b
	AND #$0F
	
	JML $00ed0a
;=========================================================

;=========================================================
; Hijacks Draw_All_Cars to draw the player using the correct method
;=========================================================
Hijack_Draw_All_Cars:
	; Original code from $00f33f
	LDA $0c70
	STA $1a
	LDA $0c80
	STA $1c
	; Original code from $00f33f
	
	%Method_Select(#$10, .do_fz_draw_player_cars)
	
	%GP2_Method_Pre($0010)
	JSL Draw_Player_Car_GP2_L
	%GP2_Method_Post()
	
	JML Skip_Draw_Player_Car_FZ_Call

.do_fz_draw_player_cars
	JML Draw_Player_Car_FZ_Call
;=========================================================


;=========================================================
; Hijack Load_Player_Spr_Arrangement to use the correct method
;=========================================================
Hijack_Load_Player_Spr_Arrangement:
	%Method_Select(#$0010, .do_fz_load_PLAyer_spr)
	
	%Mask_Method_Pre()
	JSL Load_Player_Spr_Arrangement_GP2_L
	%Mask_Method_Post()
	
	JML Load_Player_Spr_Arrangement_FZ_Exit
	
.do_fz_load_PLAyer_spr
	; Original code from $00D71D
    SEP #$30
    PEA $0002
    PLB
	; Original code from $00D71D

	JML Load_Player_Spr_Arrangement_FZ_Continue
;=========================================================

;=========================================================
; Hijack Updt_Player_Anim to use the correct method
;=========================================================
Hijack_Updt_Player_Anim:
	%Method_Select(#$10, .do_fz_updt_PLAyer_anim)

	%GP2_Method_Pre($0010)
	JSL Updt_Player_Anim_GP2_L
	%GP2_Method_Post()
	
	JML Updt_Player_Anim_Exit

.do_fz_updt_PLAyer_anim
	JML Updt_Player_Anim
;=========================================================

;=========================================================
; Hijack Upload_Player_GFX to use the correct method
;=========================================================
Hijack_Upload_Player_GFX:
	%Method_Select(#$10, .do_fz_upload_PLAyer_gfx)
	
	%GP2_Method_Pre($0010)
	JSL Upload_Player_GFX_GP2_L
	%GP2_Method_Post()
	
	JML Upload_Player_GFX_FZ_Exit

.do_fz_upload_PLAyer_gfx
	JML Upload_Player_GFX_FZ
;=========================================================

;=========================================================
; Hijack Upload_Jump_GFX to use the correct method
;=========================================================
Hijack_Upload_Jump_GFX:
	SEP #$20
	
	%Method_Select(#$10, .do_fz_upload_jump_gfx)
	
	%GP2_Method_Pre($0010)
	JSL Upload_Jump_GFX_GP2_L
	%GP2_Method_Post()
	
	JML Upload_Jump_GFX_FZ

.do_fz_upload_jump_gfx
	JML Upload_Jump_GFX_FZ
;=========================================================

;=========================================================
; Hijack Load_Misc_Colors_Engine_Fire to use the correct method
;=========================================================
Hijack_Load_Misc_Colors_Engine_Fire:
	%Method_Select(#$10, .do_fz_load_misc_colors)
	
	%GP2_Method_Pre($0010)
	JSL Load_Misc_Colors_Engine_Fire_GP2_L
	%GP2_Method_Post()
	
	JML Load_Misc_Colors_Engine_Fire_FZ_Exit

.do_fz_load_misc_colors
	JML Load_Misc_Colors_Engine_Fire_FZ
;=========================================================

;=========================================================
; Hijack Update_Cars_Values to use the correct method
;=========================================================
Hijack_Update_Cars_Values:
	; Original code from $00915d
	LDA $0b00,x
	BPL .skip
	BIT #$10
	BEQ .continue
	; Original code from $00915d

	JML Update_Cars_Values_FZ_Move_Offscreen
	
.skip
	JML Update_Cars_Values_FZ_Skip
	
.continue
	CPX #$00
	BNE .do_fz_update_cars

	%Method_Select(#$10, .do_fz_update_cars)

	%GP2_Method_Pre($0010)
	JSL $108f06
	%GP2_Method_Post()

	JML Update_Cars_Values_FZ_Continue
	
.do_fz_update_cars
	JML Update_Cars_Values_FZ_Methods
;=========================================================

;=========================================================
; Hijack Updt_Player_Values to use the correct method
;=========================================================
Hijack_Updt_Player_Values:

	LDA $c3
	BEQ .continue
	
	JML Updt_Player_Values_FZ_Race_Ended

.continue
	%Method_Select(#$10, .do_fz_updt_player_values)

	%GP2_Method_Pre($0010)
	JSL Updt_Player_Values_GP2_Methods
	%GP2_Method_Post()
	
	JML Updt_Player_Values_FZ_Exit

.do_fz_updt_player_values
	JML Updt_Player_Values_FZ_Methods
;=========================================================

;=========================================================
; Hijack Updt_Player_Engine_Fire to use the correct method
;=========================================================
Hijack_Updt_Player_Engine_Fire:
	%Method_Select(#$10, .do_fz_updt_player_engine_fire)
	
	%GP2_Method_Pre($0010)
	JSL Update_Player_Engine_Fire_GP2_L
	%GP2_Method_Post()
	
	JML Updt_Player_Engine_Fire_FZ_Exit
	
.do_fz_updt_player_engine_fire
	JML Updt_Player_Engine_Fire_FZ
;=========================================================

;=========================================================
; Hijack Flash_Player_Lap_Finish to use the correct method
;=========================================================
Hijack_Flash_Player_Lap_Finish:
	%Method_Select(#$10, .do_fz_flash_player_lap)

	%GP2_Method_Pre($0010)
	JSL Flash_Player_Lap_Finish_GP2_L
	%GP2_Method_Post()

	JML Flash_Player_Lap_Finish_FZ_Exit

.do_fz_flash_player_lap	
	JML Flash_Player_Lap_Finish_FZ
;=========================================================

;=========================================================
; Hijack Select_Car_Set_Index to load the correct car selection screen palette
;=========================================================
Hijack_Select_Car_Set_Index:
	STX $5a
	LDA $03867b,x

	PHA

	%Method_Select(#$10, .is_fz)
	
	PLA
	ORA #$10
	STA !PLAYER_CAR_SELECTION
	
	JSR Load_Car_Select_Screen_Palette_GP2
	
	BRA .exit
	
.is_fz
	PLA
	STA !PLAYER_CAR_SELECTION
	
	JSR Load_Car_Select_Screen_Palette_FZ
	
.exit
	SEP #$30

	JML $038670
;=========================================================

;=========================================================
; Hijack Select_Car_Set_Car to load the correct car selection screen palette
;=========================================================
Hijack_Select_Car_Set_Car_Select_Palette:
	
	LDA !PLAYER_CAR_SELECTION
	PHA
	
	BIT #$10
	BEQ .load_fz_palette
	
	JSR Load_Car_Select_Screen_Palette_GP2
	
	BRA .continue
	
.load_fz_palette
	JSR Load_Car_Select_Screen_Palette_FZ
	
.continue
	PLA

	PHX

	TAX
	
	AND #$0F
	STA !PLAYER_CAR_SELECTION
	
	; Original code from $0388EA
	LDA !PLAYER_CAR_SELECTION
	ASL A
	ADC !PLAYER_CAR_SELECTION
	ASL A
	; Original code from $0388EA
	
	STX !PLAYER_CAR_SELECTION
	
	PLX

	JML $0388f0
;=========================================================

;=========================================================
; Hijack Select_Player_Car_GM to handle R or L being clicked and reload the screen with the other set of vehicles
;=========================================================
Hijack_Select_Player_Car_GM:
	
	LDA $68
	BIT #$20
	BEQ .not_select
	
	JML $038650
	
 .not_select
	LDA $67
	BIT #$30
	BNE .l_or_r_clicked
	
	LDA $68
	JML $038647
	
.l_or_r_clicked
	LDA !PLAYER_CAR_SELECTION
	EOR #$10
	STA !PLAYER_CAR_SELECTION

	LDA #$02
	STA $60
	
	STZ $55
	
	LDX $5a
	JML Select_Player_Car_GM_Exit
;=========================================================

;=========================================================
; Hijack Load_Car_Select_Screen_Car_Type to mask player car selection
;=========================================================
Hijack_Load_Car_Select_Screen_Car_Type:
	LDA !PLAYER_CAR_SELECTION
	AND #$0F
	TAX
	
	LDA $03867b,x
	
	JML $0385e2
;=========================================================

;=========================================================
; Hijack Load_Car_Select_Screen_Bank to set the correct bank for BG2 load
;=========================================================
Hijack_Load_Car_Select_Screen_Bank_BG2:
	%Method_Select(#$0010, .do_fz_bank)

	LDA #$001f
	
	BRA .exit

.do_fz_bank
	LDA #$000f

.exit
	LDX #$32b0

	JML $0385b7
;=========================================================

;=========================================================
; Hijack Load_Car_Select_Screen_Bank to set the correct bank for BG1 load
;=========================================================
Hijack_Load_Car_Select_Screen_Bank_BG1:
	%Method_Select(#$0010, .do_fz_bank)
	
	LDA #$001f
	
	BRA .exit

.do_fz_bank
	LDA #$000f

.exit
	LDX #$38b0

	JML $0385c4
;=========================================================

;=========================================================
; Hijack Load_Car_Select_GFX to set the correct bank for car select GFX loading
;=========================================================
Hijack_Load_Car_Select_GFX_Long:
	%Method_Select(#$10, .do_fz_load_gfx)

	PEA $001e

	BRA .exit

.do_fz_load_gfx
	PEA $000e

.exit
	plb

	JML $0398f7
;=========================================================

;=========================================================
; Hijack Load_Car_Select_Screen_GFX to do the proper MVN 
;=========================================================
Hijack_Load_Car_Select_Screen_GFX_DMA_1:
	%Method_Select(#$0010, .do_fz_dma_1)

	LDA #$001f
	LDX #$8b5d
	LDY #$0ae0
	MVN $00, $13

	BRA .exit
	
.do_fz_dma_1
	LDA #$001f
	LDX #$8b95
	LDY #$0ae0
	MVN $00, $03

.exit
	JML $038b71
;=========================================================
	
;=========================================================
; Hijack Init_HUD to mask player car selection
;=========================================================
Hijack_Init_HUD:
	TXY
	
	%Mask_Car_Load(#$0F)
	TAX

	LDA $00a803,x

	TYX
	
	JML $00a7eb
;=========================================================

;=========================================================
; Method to mask the car selection when loading the Spare_Sprite
;=========================================================
Set_Spare_Sprite_Sub:
	TXY
	
	%Mask_Car_Load(#$0F)
	TAX

	LDA $00a852,x

	TYX
	
	RTS
;=========================================================

;=========================================================
; Hijack Init_Misc_Race_Spr to mask player car selection
;=========================================================
Hijack_Init_Misc_Race_Spr:
	JSR Set_Spare_Sprite_Sub

	JML $00a84e
;=========================================================

;=========================================================
; Hijack Set_Spare_Spr_Pos to mask player car selection
;=========================================================
Hijack_Set_Spare_Spr_Pos:
	JSR Set_Spare_Sprite_Sub

	JML $00b198
;=========================================================	
	
;=========================================================
; Hijack DMA_Spare_Spr to load the correct spare sprite graphics
;=========================================================
Hijack_DMA_Spare_Spr:
	%Method_Select(#$0010, .do_fz_dma_spare)
	
	%GP2_Method_Pre($0010)
	JSL DMA_Spare_Spr_GP2
	%GP2_Method_Post()
	
	JML DMA_Spare_Spr_FZ_Exit
	
.do_fz_dma_spare

	JML DMA_Spare_Spr_FZ
;=========================================================
