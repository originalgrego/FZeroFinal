!PLAYER_CAR_SELECTION equ $52

; Hijack ai init, original code - LDA !Player_Car_Type, ASL A, ASL A
org $00d2ef
	JML Hijack_Init_AI_Cars

org $00fa25
	JML Hijack_Prestart_Accel

org $00ed05
	JML Hijack_Draw_Car_5_Out_Of_Race
	
; Set_Spare_Spr_Pos
org $00b193
	JML Hijack_Set_Spare_Spr_Pos
	
; Init_Misc_Race_Spr
org $00a849
	JML Hijack_Init_Misc_Race_Spr
	
; Init_HUD
org $00a7e6
	JML Hijack_Init_HUD

; Disable loading vehicles palettes in Load_Track_Pal, wait to Init_Player_Car to handle that
org $00a148
	nop
	nop
	nop

; Disable loading vehicle palettes in Load_Track_Pal during practice
org $00a171
	nop
	nop
	nop
	
;=============================================================
; DMA_Spare_Spr
;=============================================================
org $0088d3
	JSR DMA_Spare_Spr_Redirect
	
org $00b125
DMA_Spare_Spr_FZ:
	
org $00b163
DMA_Spare_Spr_FZ_Exit:
	
org $10af36
DMA_Spare_Spr_GP2:

org $10af40 
	ora #$18

org $10af74
	RTL
;=============================================================
	
;=============================================================
; Hijack Init_Player_Car
;=============================================================
org $0089e4
	JSR Init_Player_Car_Redirect
	
org $00b236
Init_Player_Car_FZ:

org $00b29b
Init_Player_Car_FZ_Exit:

org $10b047
Init_Player_Car_GP2:

org $10b0ac	
	RTL
;=============================================================

;=============================================================
; Hijack Load_Player_Spr_Arrangement to call gp2 method
;=============================================================
org $00d71d
	JML Hijack_Load_Player_Spr_Arrangement
	
org $00d723
Load_Player_Spr_Arrangement_FZ_Continue:

org $00d850
Load_Player_Spr_Arrangement_FZ_Exit:

org $10d60b
	pea $0012
	
org $10d758
	lda $120000,x
	
org $10d737
	lda $120000,x
	
org $10d73e
	lda $120002,x
;=============================================================

;=============================================================
; Hijack Updt_Player_Anim to point to gp2 method
;=============================================================
org $008d7e
	JSR Updt_Player_Anim_Redirect

org $00ba70`
Updt_Player_Anim:

org $00baae
Updt_Player_Anim_Exit:
;=============================================================

;=============================================================
; Hijack Draw_All_Cars
;=============================================================
org $00f33f
	JML Hijack_Draw_All_Cars

org $00f349
Draw_Player_Car_FZ_Call:

org $00f34c
Skip_Draw_Player_Car_FZ_Call:
;=============================================================
	
;=============================================================
; Hijack Upload_Player_GFX
;=============================================================
org $0089ff
	JSR Upload_Player_GFX_Redirect

org $00d20a	
Upload_Player_GFX_FZ:

org $00d2ce
Upload_Player_GFX_FZ_Exit:

org $10d119 
	adc #$18

org $10d10c 
	lda $12eee5,x
	
org $10d12f
	lda $12eeec,x
	
org $10d137
	lda $12eeec,x

org $10d13f
	lda $12eeec,x

org $10d176 
	lda $12ef10,x
;=============================================================
	
;=============================================================
; Hijack Upload_Jump_GFX
;=============================================================
org $00ebdf
	JSR Upload_Jump_GFX_Redirect

org $00f128
Upload_Jump_GFX_FZ:

org $10f1c0
	PEA $0012
	
org $10f1e1
	adc #$18
	
org $10f104
	lda $12f159,x
	
org $10f06d
	rts
	
org $10f061
	rts
	
org $10f022
	rts
	
org $10f044
	lda #$001e
;=============================================================

;=============================================================
; Hijack Updt_Player_Engine_Fire	
;=============================================================
org $008d92
	JSR Updt_Player_Engine_Fire_Redirect

org $00C507
Updt_Player_Engine_Fire_FZ:

org $00c519
Updt_Player_Engine_Fire_FZ_Exit:
	
org $008bba
	JSR Load_Misc_Colors_Engine_Fire_Redirect
	
org $0089f9
	JSR Load_Misc_Colors_Engine_Fire_Redirect
	
org $00BE45
Load_Misc_Colors_Engine_Fire_FZ:

org $00be88
Load_Misc_Colors_Engine_Fire_FZ_Exit:

org $10c4b8 
	lda $12c300,x

org $10c4c1 
	lda $12c302,x

org $10c4ca 
	lda $12c304,x

org $10c4d3 
	lda $12c306,x
	
org $10c4e7
	lda $12c328,x
	
org $10c4fb
	lda $12c340,x
	
org $10c504 
	lda $12c342,x

org $10c50d 
	lda $12c344,x

org $10c516 
	lda $12c346,x

org $10c52a 
	lda $12c368,x

org $10c533 
	lda $12c36a,x

org $10c53c 
	lda $12c36c,x

org $10c545 
	lda $12c36e,x
;=============================================================
	
;=============================================================
; Hijack Flash_Player_Lap_Finish
;=============================================================
org $008db6
	JSR Flash_Player_Lap_Finish_Redirect

org $00C782
Flash_Player_Lap_Finish_FZ:

org $00c7ab
Flash_Player_Lap_Finish_FZ_Exit:
	
org $10c5f8
	mvn $00, $1f
;=============================================================

;=============================================================
; Hijack Updt_Player_Values
;=============================================================
org $00b2a2
	JML Hijack_Updt_Player_Values

org $10b0b7
Updt_Player_Values_GP2_Methods:
	
org $10b0d1
	RTL

org $10b0d8
	RTL
	
org $00b2c9
Updt_Player_Values_FZ_Race_Ended:
	
org $00b2c0
Updt_Player_Values_FZ_Exit:
	
org $00b2a6
Updt_Player_Values_FZ_Methods:

org $10b6b1
	lda $12c421,x

org $10b6b8
	lda $12c46d,x
	
org $10b700 
	lda $12c48e,x
;=============================================================

;=============================================================
; Hijack Update_Cars_Values
;=============================================================
org $00915d
	JML Hijack_Update_Cars_Values

org $00916b
Update_Cars_Values_FZ_Methods:
	
org $00919b
Update_Cars_Values_FZ_Continue:

org $0091a6
Update_Cars_Values_FZ_Skip:

org $009166
Update_Cars_Values_FZ_Move_Offscreen:

org $108f36
	RTL
	
org $109272
	lda $12c4ad,x

org $10927b
	lda $18ed20,x

org $10928f
	lda $18ec30,x
	
org $1091af
	lda $12c50c,x
;=============================================================
	
;=============================================================
; GP2 Bank 00 Long jump redirects
;=============================================================
org $108000 ; Who needs gp2's init code?
Draw_Player_Car_GP2_L:
	JSR $f3d8
	RTL

Updt_Player_Anim_GP2_L:
	JSR $b881
	RTL

Load_Player_Spr_Arrangement_GP2_L:
	JSR $d609
	RTL
	
Upload_Player_GFX_GP2_L:
	JSR $d0f6
	RTL
	
Upload_Jump_GFX_GP2_L:
	JSR $f017
	RTL
	
Update_Player_Engine_Fire_GP2_L:
	JSR $c32e
	RTL
	
Load_Misc_Colors_Engine_Fire_GP2_L:
	JSR $bc5d
	RTL
	
Flash_Player_Lap_Finish_GP2_L:
	JSR $c5a1
	RTL
	
Do_Player_Collision_Redirect:
	PEA $1000
	PLB
	JSL Do_Player_Collision_L
	PLB
	RTS
;=============================================================
	
;=============================================================
; FZ Bank 00 redirects
;=============================================================
org $008791 ; "Set_Uncont_If_Greater" (0x12 bytes of unused space, 4 hijacks worth)
Updt_Player_Anim_Redirect:
	JML Hijack_Updt_Player_Anim

Upload_Player_GFX_Redirect:
	JML Hijack_Upload_Player_GFX

Upload_Jump_GFX_Redirect:
	JML Hijack_Upload_Jump_GFX

Load_Misc_Colors_Engine_Fire_Redirect:
	JML Hijack_Load_Misc_Colors_Engine_Fire
		
org $00977F ; "Updt_Car_Coords_Revrs" (0x3D bytes of unused space, 15 hijacks)	
Updt_Player_Engine_Fire_Redirect:
	JML Hijack_Updt_Player_Engine_Fire
	
Flash_Player_Lap_Finish_Redirect:
	JML Hijack_Flash_Player_Lap_Finish

Init_Player_Car_Redirect:
	JML Hijack_Init_Player_Car
	
Do_Player_Collision_L:
	JSR Do_Player_Collision
	RTL
	
DMA_Spare_Spr_Redirect:
	JML Hijack_DMA_Spare_Spr
;=============================================================
	
;=============================================================
; Load gp2 select car graphics
;=============================================================
org $0385dc
	JML Hijack_Load_Car_Select_Screen_Car_Type

org $0385b1
	JML Hijack_Load_Car_Select_Screen_Bank_BG2
	
org $0385be
	JML Hijack_Load_Car_Select_Screen_Bank_BG1
	
org $03864f
Select_Player_Car_GM_Exit:

org $0398f3
	JML Hijack_Load_Car_Select_GFX_Long

org $038b65
	JML Hijack_Load_Car_Select_Screen_GFX_DMA_1
	
org $138B6D
	dw $0018,$0019,$001A,$001B
	
org $038668
	JML Hijack_Select_Car_Set_Index

org $0388EA
	JML Hijack_Select_Car_Set_Car_Select_Palette
	
org $038641
	JML Hijack_Select_Player_Car_GM
;=============================================================

;=============================================================
; Hijack Do_Player_Collision
;=============================================================
org $00BB66
Do_Player_Collision:

org $10b0bc
	JSR Do_Player_Collision_Redirect
;=============================================================
