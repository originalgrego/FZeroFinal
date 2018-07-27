lorom

;=========================================================
; F-Zero Final v0.1
; Authors: Gregory Lewandowski (Grego), Richard Bukor (CatadorDeLatas)
;
; A mod to bring all of the content from BS F-Zero Grand Prix 2 into the original F-Zero and
; enhance F-Zero to handle custom maps/leagues/backgrounds/palettes etc.
;
; Please see the README for further detail.
;=========================================================

; The selected map
!CURRENT_MAP equ $0053

; The base game state variable
!GAME_STATE equ $0054

; Whether we are in practice mode, #$01 for true
!PRACTICE_FLAG equ $0058

; Currently selected option when a menu is active
!SELECTED_OPTION equ $005A

; The league selected
!LEAGUE_SELECTION equ $0090

!FZ_PALETTE_BANK equ $0F
!FZ_PALETTE_TABLE_ADDRESS equ $00a465

!FZ_TRACK_SETTINGS_TABLE_ADDRESS equ $02e129

!FZ_TRACK_NAME_PTR equ $ac42

!FZ_TRACK_BANK_TABLE equ $00a486
!FZ_READ_ORG_TABLE equ $039f00

!FZ_TILE_POOL_BANK equ $0C
!FZ_TILE_POOL_ADDR equ $C380

!FZ_TRACK_MINE_TABLE equ $0ce880

!FZ_AI_CHECKPOINT_TABLE equ $e0f9

!FZ_TRACK_GFX_TABLE equ $00a450

!GP2_PALETTE_BANK equ $1F
!GP2_PALETTE_TABLE_ADDRESS equ $10a204

!GP2_TRACK_BANK_TABLE equ $10a225
!GP2_READ_ORG_TABLE equ $139f00

!GP2_TILE_POOL_BANK equ $1C

!GP2_TRACK_MINE_TABLE equ $1ce880

!GP2_AI_CHECKPOINT_TABLE equ $e000

!GP2_TRACK_GFX_TABLE equ $10A1EF

!GP2_TRACK_SETTINGS_TABLE_ADDRESS equ $12e02c

; Increase the leagues!
!MAX_LEAGUE equ $03

incsrc Divide.asm
incsrc All_Practice.asm

;Set rom size to 2mb
org $00FFD7
	db $0B

; Hijack track variation loading so it may be disabled for custom/ace league
org $009f9b
	JML Hijack_Track_Variations

; Label for jumping to the loop to handle track variations
org $009fa1
Handle_Track_Variations:

; Label for skipping track variation handling
org $009fbc
Skip_Track_Variations:

; Hijack track settings, Original code - lda $02e129,x
org $009f1b
	JSL Hijack_Track_Settings

org $009f28
	JSL Hijack_Track_Settings

org $009f4c
	JSL Hijack_Track_Settings

; Hijack track palette loading
org $00a127
	JML Hijack_Track_Palette_Loading

; Hijack read position and size for track data
org $00A040
	JML Hijack_Read_Org_Size

; Hijack bank handling for track data
org $00A05F
	JML Hijack_Set_Read_Bank

; Hijack track loading to load the correct tile pool
org $009F08
	JML Hijack_Load_Track

; Hijack ai path bank, Original code - pea $0012; plb
org $00d60b
	JML Hijack_AI_PEA

; Hijack ai paths
org $00d645
	JML Hijack_AI_Checkpoint_Structure

org $00D623
	JML Hijack_AI_Checkpoint_Structure

; Hijack mine data, Original code - lda #$0c00; sta $21; lda $0ce880,x
org $00a317
	JML Hijack_Load_Track_Mines

; Hijack track gfx
org $00a0cf
	JML Hijack_Load_Track_GFX

; Disable original league select drawing routine
org $0387c8
	NOP
	NOP
	NOP

; Hijack the NMI handler
org $0080D9
	JML Hijack_NMI

; Max leagues!
org $0387bd
	CMP #!MAX_LEAGUE

org $0387ac
	CMP #!MAX_LEAGUE

; Hijack bank when loading map graphics, Original code - pea $000f
org $03971c
	JML Hijack_Upload_xbpp_As_4bpp

; Master class always available, Original code - lda $7f49fa
org $0387eb
	LDA #$FF
	NOP
	NOP

; Stop handling practice mode differently when calculating sram offsets, Original code - bne $c313
org $02c305
	NOP
	NOP

; Use new track_sram_ofs table
org $02c612
	JML Hijack_Get_Track_SRAM_Ofs

; Hijack track name handling
org $00abd3
	JML Hijack_Track_Names

; Added grand prix 2 data to the rom
org $108000
	incbin ../SNES_ROMS/F-Zero_Grand_Prix_2.sfc

; Make mute city iv use variation 3, gives it the dark horizon, messes up mini map loading ;(
; TODO: Make horizon table configurable.
org $12e03b
	;db $E7
	
;Dem hacks
org $308000
	incsrc LoadBlockToVRAM.asm

;=========================================================
; Hijack the NMI handler to draw our custom league menu
;=========================================================
Hijack_NMI:
	; Original code from $0080D9
	REP #$30
	PHA
	PHX
	PHY
	PHD
	PHB
	; Original code from $0080D9

	LDA !GAME_STATE
	CMP #$0501 ; Game state equal to #$01 (menu) and game state + 1 equal to #$05 (league selection)?
	BNE .exit

	JSR Draw_Custom_League_Menu

.exit
	JML $0080e0
;=========================================================

;=========================================================
; Draws the custom league menu in the same fashion as the class selector.
;=========================================================
Draw_Custom_League_Menu:
	LDA !SELECTED_OPTION
	CLC
	ASL A

	TAX

	SEP #$20

	JSR (LEAGUE_SELECTION_JSR_TABLE, X)

	; Erase the queen and king league tiles
	%LoadBlockToVRAM($30, SELECT_LEAGUE_CLEAR_TILES, $05B0, $1A)
	%LoadBlockToVRAM($30, SELECT_LEAGUE_CLEAR_TILES, $05F0, $1A)

	REP #$20

	RTS
;=========================================================

;=========================================================
; Determines the offset to use when accessing the hijack tables.
; The offset for all hijack tables is determined by (league * 2), however
; for practice mode the league is always #$00, so we must divide the map
; number by #$05 to determine the league first.
;=========================================================
Get_League_Table_Offset:
	PHX
	PHP

	SEP #$20

	LDA !PRACTICE_FLAG
	BEQ .not_practice

		REP #$30

		LDX #$0000

		LDA !CURRENT_MAP
		AND #$00FF

		%Divide($0005)
		
		TXA
		
		BRA .end

.not_practice
		REP #$30

		LDA !LEAGUE_SELECTION
	
.end
	CLC
	ASL A ; Mult by 2

	PLP
	PLX

	RTS
;=========================================================

;=========================================================
; Hijack the loading of xbpp graphics, by changing the bank we can control
; which set of mini maps load.
;
; TODO: Enhance this as it will currently only work for GP2 and FZ maps, the address loaded needs to be configurable for custom leagues
;=========================================================
Hijack_Upload_xbpp_As_4bpp:
	JSR Get_League_Table_Offset

	PHX ; Preserve X!

	TAX

	REP #$20

	LDA UPLOAD_XBPP_BANK_TABLE, X

	PHA ; Push on two bytes

	PLB ; Pull one

	SEP #$20

	PLA ; Preserve the top byte (#$00)

	PLX ; Get X back off the stack

	PHA ; Push the top byte back on, a PLB at the end of xbpp upload will pull this value to return the bank register to #$00

	JML $039720
;=========================================================

;=========================================================
; Hijack the beginning of track loading to load custom tile pools, necessary as FZ and GP2 do not share a tile pool.
; Custom maps and leagues will also require their own tile pools, unless we get very lucky. ;D
;=========================================================
Hijack_Load_Track:
	PHP
	PHB

	REP #$30

	JSR Load_Tile_Pool

	SEP #$30

	PLB

	LDA #$00

	JML $009F0D
;=========================================================

;=========================================================
; Hijack track setting loading, custom leagues and GP2 require their own set of track settings data.
;=========================================================
Hijack_Track_Settings:
	JSR Get_League_Table_Offset

	PHY

	TXY
	TAX

	JSR (TRACK_SETTINGS_JSR_TABLE, X)

	PLY

	RTL
;=========================================================

;=========================================================
; Hijack the loading of track palettes, GP2 and custom maps will have custom palettes
;=========================================================
Hijack_Track_Palette_Loading:
	JSR Get_League_Table_Offset

	TAX

	JSR (LOAD_PALETTE_JSR_TABLE, X)

	JML $00a133
;=========================================================

;=========================================================
; Hijack the loading of track data's address and size
;=========================================================
Hijack_Read_Org_Size:
	JSR Get_League_Table_Offset

	PHY

	TXY
	TAX

	JSR (READ_ORG_SIZE_JSR_TABLE, X)

	PLY

	JML $00a04c
;=========================================================

;=========================================================
; Hijack the loading of track data's bank.
;=========================================================
Hijack_Set_Read_Bank:
	TAY

	JSR Get_League_Table_Offset

	PHX

	TAX

	JSR (SET_READ_BANK_JSR_TABLE, X)

	PLX

	JML $00a068
;=========================================================

;=========================================================
; Hijack the loading of track graphics, will be useful for custom track tiles... someday.
;=========================================================
Hijack_Load_Track_GFX:
	PHX

	JSR Get_League_Table_Offset

	TAX

	JSR (LOAD_TRACK_GFX_JSR_TABLE, X)

	PLX

	JML $00a0dd
;=========================================================

;=========================================================
; Loads the correct tilepool for the current league. GP2 and custom leagues will have their own tilepools.
;=========================================================
Load_Tile_Pool:
	JSR Get_League_Table_Offset

	TAX

	LDA #$24FF
	LDY #$0000

	JSR (TILE_POOL_JSR_TABLE, X)

	RTS
;=========================================================

;=========================================================
; Hijack the loading of track mines to use the correct table for the league
;=========================================================
Hijack_Load_Track_Mines:
	JSR Get_League_Table_Offset

	PHY

	TXY
	TAX

	JSR (TRACK_MINES_JSR_TABLE, X)

	PLY

	JML $00a320
;=========================================================

;=========================================================
; Hijack the beginning of AI checkpoint loading to use the correct bank for the current league.
;=========================================================
Hijack_AI_PEA:
	JSR Get_League_Table_Offset

	PHX

	TAX

	REP #$20

	LDA AI_CHECKPOINT_BANK_TABLE, X

	PHA
	PLB ; This is tricky, a PLB is performed at the end of the load ai path method, the upper byte of A (#$00) is left on the stack for it

	SEP #$20

	PLA

	PLX
	
	PHA

	JML $00d60f
;=========================================================

;=========================================================
; Hijack the ai checkpoint loading to use the correct table for the league.
;=========================================================
Hijack_AI_Checkpoint_Structure:
	REP #$20

	JSR Get_League_Table_Offset

	PHX
	PHY

	TXY
	TAX

	JSR (AI_CHECKPOINT_JSR_TABLE, X)

	STA $30

	PLY
	PLX

	JML $00d64a
;=========================================================

;=========================================================
; Hijack track variation handling, used to disable track variations for GP2 and custom leagues.
;=========================================================
Hijack_Track_Variations:
	; Original code from $009f9b
	LDA $28
	AND #$00FF
	TAY
	; Original code from $009f9b

	JSR Get_League_Table_Offset

	TAX

	LDA TRACK_MODIFICATIONS_ENABLED_TABLE, X
	BNE .continue

	JML Skip_Track_Variations

.continue
	JML Handle_Track_Variations
;=========================================================

;=========================================================
; Hijack track name loading, allows for GP2 and custom leagues to have custom map names.
;=========================================================
Hijack_Track_Names:

	JSR Get_League_Table_Offset

	PHB
	PHX

	TAX

	; Load from the correct bank
	LDA TRACK_NAME_BANK_TABLE, X

	PHA
	PLB

	REP #$30

	; Load from the correct track name table
	LDA TRACK_NAME_PTR_TABLE, X

	STA $00

	TYA

	ADC $0000 ; We are adding Y (the name offset) with the address of the ptr table to derive a pointer to the starting address for the track name

	TAX

	LDA $0000, X ; X contains the address for an entry in the ptr table, this leaves A containing the address to the track name

	STA $0000

	SEP #$30

	; Original code from $00ABCB
	LDY #$00
.write_buffer
		LDA ($00),Y
		STA $0480,Y
		BEQ .end_of_buffer

		INY
		BRA .write_buffer

.end_of_buffer
	; Original code from $00ABCB

	PLX
	PLB

	JML $00abe9
;=========================================================

;=========================================================
; Hijack the loading of track SRAM offsets.  The original table only contained enough
; entries for the 15 maps in F-Zero, this allows us to expand the table to handle more than 15 maps.
;
; TODO: Expand SRAM and fix handling of SRAM records
;=========================================================
Hijack_Get_Track_SRAM_Ofs:
	TAX

	REP #$20
	LDA SRAM_TRACK_OFS, X

	TAX

	SEP #$20

	JML $02c616
;=========================================================

;=========================================================
; What bank to use for the call to Upload_xbpp_As_4bpp, used to hijack minimap loading.
; TODO: Handle minimap graphics addresses to allow for custom leagues to locate their minimap graphics anywhere.
;=========================================================
UPLOAD_XBPP_BANK_TABLE:
	DW $000f, $000f, $000f, $001f
;=========================================================

;=========================================================
; New Sram_track_ofs to add in additional maps/leagues
;=========================================================
SRAM_TRACK_OFS:
	DB $05, $00, $26, $00, $47, $00, $68, $00, $89, $00
	DB $ac, $00, $cd, $00, $ee, $00, $0f, $01, $30, $01
	DB $53, $01, $74, $01, $95, $01, $b6, $01, $d7, $01
GP2_SRAM_TRACK_OFS:
	DB $05, $00, $26, $00, $47, $00, $68, $00, $89, $00 ; Reusing knight league values, should be - DB $F8, $01, $19, $02, $3A, $02, $5B, $02, $7C, $02, need to expand memory/change refs
;=========================================================

;=========================================================
; Hijack track name tables
;=========================================================
TRACK_NAME_BANK_TABLE:
	DW $0000, $0000, $0000, $0030

TRACK_NAME_PTR_TABLE:
	DW !FZ_TRACK_NAME_PTR, !FZ_TRACK_NAME_PTR, !FZ_TRACK_NAME_PTR, GP2_TRACK_NAME_PTR
;=========================================================

;=========================================================
; Track names and track name ptr table for GP2
;=========================================================
GP2_TRACK_NAME_PTR:
	DW BIG_BLUE_II_TRACK_NAME
	DW SILENCE_II_TRACK_NAME
	DW BLANK_TRACK_NAME
	DW SAND_STORM_TRACK_NAME
	DW BLANK_TRACK_NAME
	DW BLANK_TRACK_NAME
	DW SAND_STORM_TRACK_NAME
	DW MUTE_CITY_IV_TRACK_NAME
	DW BLANK_TRACK_NAME

SILENCE_II_TRACK_NAME: ; Silence ii
	DB $44, $53, $01, $82, $1B, $FF, $A0, $8E, $6F, $68, $8B, $66, $68, $FF, $FE, $FF, $00

BIG_BLUE_II_TRACK_NAME: ; Bigblue ii
	DB $44, $53, $01, $81, $1B, $FF, $65, $8E, $6A, $FF, $65, $6F, $A2, $68, $FF, $FE, $FF, $00

SAND_STORM_TRACK_NAME: ; Sandstorm
	DB $44, $53, $01, $87, $1B, $FF, $A0, $64, $8B, $67, $FF, $A0, $A1, $8C, $8F, $8A, $FF, $FE, $FF, $00

MUTE_CITY_IV_TRACK_NAME: ; Mute city iv
	DB $44, $53, $01, $88, $1B, $FF, $8A, $A2, $A1, $68, $FF, $66, $8E, $A1, $A5, $FF, $8E, $A3, $00

BLANK_TRACK_NAME:
	DB $44, $53, $01, $88, $1B, $00
;=========================================================

;=========================================================
; League selction hijack tables
;=========================================================
LEAGUE_SELECTION_JSR_TABLE:
	dw KNIGHT_LEAGUE, QUEEN_LEAGUE, KING_LEAGUE, ACE_LEAGUE

LEAGUE_SELECTION_FUNC_TABLE:
	KNIGHT_LEAGUE:
		%LoadBlockToVRAM($30, SELECT_LEAGUE_SCREEN_KNIGHT_LEAGUE_TILES, $0570, $1A)
		RTS
	QUEEN_LEAGUE:
		%LoadBlockToVRAM($30, SELECT_LEAGUE_SCREEN_QUEEN_LEAGUE_TILES, $0570, $1A)
		RTS
	KING_LEAGUE:
		%LoadBlockToVRAM($30, SELECT_LEAGUE_SCREEN_KING_LEAGUE_TILES, $0570, $1A)
		RTS
	ACE_LEAGUE:
		%LoadBlockToVRAM($30, SELECT_LEAGUE_SCREEN_ACE_LEAGUE_TILES, $0570, $1A)
		RTS
;=========================================================

;=========================================================
; League selection tiles
;=========================================================
SELECT_LEAGUE_SCREEN_KNIGHT_LEAGUE_TILES:
	db $CC, $08, $CE, $08, $CA, $08, $C8, $08, $C9, $08, $D5, $08, $FF, $04, $CD, $08, $C6, $08, $AF, $08, $C8, $08, $D6, $08, $C6, $08

SELECT_LEAGUE_SCREEN_QUEEN_LEAGUE_TILES:
	db $D2, $08, $D6, $08, $C6, $08, $C6, $08, $CE, $08, $FF, $08, $CD, $08, $C6, $08, $AF, $08, $C8, $08, $D6, $08, $C6, $08, $FF, $08

SELECT_LEAGUE_SCREEN_KING_LEAGUE_TILES:
	db $CC, $08, $CA, $08, $CE, $08, $C8, $08, $FF, $08, $CD, $08, $C6, $08, $AF, $08, $C8, $08, $D6, $08, $C6, $08, $FF, $08, $FF, $08

SELECT_LEAGUE_SCREEN_ACE_LEAGUE_TILES:
	db $AF, $08, $C4, $08, $C6, $08, $FF, $08, $CD, $08, $C6, $08, $AF, $08, $C8, $08, $D6, $08, $C6, $08, $FF, $08, $FF, $08, $FF, $08

SELECT_LEAGUE_CLEAR_TILES:
	db $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08, $FF, $08
;=========================================================

;=========================================================
; Track modifications hijack table
;=========================================================
org $30ED00
TRACK_MODIFICATIONS_ENABLED_TABLE:
	dw #$0001, #$0001, #$0001, #$0000
;=========================================================

;=========================================================
; Track graphics hijack table
;=========================================================
macro TrackGFXFunclet(BANK_ADDR_B, TRACK_GFX_ADDR_L)
	TYX
	LDA <TRACK_GFX_ADDR_L>, X
	STA $04
	INX
	LDA <TRACK_GFX_ADDR_L>, X
	STA $05
	LDA #<BANK_ADDR_B>
	STA $06
	RTS
endmacro

org $30EE00
LOAD_TRACK_GFX_JSR_TABLE:
	dw FZ_TRACK_GFX, FZ_TRACK_GFX, FZ_TRACK_GFX, GP2_TRACK_GFX

org $30EF00
LOAD_TRACK_GFX_FUNC_TABLE:
	FZ_TRACK_GFX:
		%TrackGFXFunclet($0C, !FZ_TRACK_GFX_TABLE)
	GP2_TRACK_GFX:
		%TrackGFXFunclet($1C, !GP2_TRACK_GFX_TABLE)
;=========================================================

;=========================================================
; AI Checkpoint bank table
;=========================================================
org $30F200
AI_CHECKPOINT_BANK_TABLE:
	DW $0002, $0002, $0002, $0012
;=========================================================

;=========================================================
; AI Checkpoint hijack table
;=========================================================
macro AICheckpointFunclet(CHECK_POINT_ADDR_S)
	TYX
	LDA <CHECK_POINT_ADDR_S>,x
	RTS
endmacro

org $30F000
AI_CHECKPOINT_JSR_TABLE:
	dw FZ_AI_CHECKPOINT, FZ_AI_CHECKPOINT, FZ_AI_CHECKPOINT, GP2_AI_CHECKPOINT

org $30F100
AI_CHECKPOINT_FUNC_TABLE:
	FZ_AI_CHECKPOINT:
		%AICheckpointFunclet(!FZ_AI_CHECKPOINT_TABLE)
	GP2_AI_CHECKPOINT:
		%AICheckpointFunclet(!GP2_AI_CHECKPOINT_TABLE)
;=========================================================

;=========================================================
; Track mines handling
;=========================================================
macro TrackMinesFunclet(BANK_ADDR_S, MINE_TABLE_ADDR_L)
	TYX
	LDA #<BANK_ADDR_S>
	STA $21
	LDA <MINE_TABLE_ADDR_L>,x
	RTS
endmacro

;Track mines hijack table
org $30F400
TRACK_MINES_JSR_TABLE:
	dw FZ_TRACK_MINES, FZ_TRACK_MINES, FZ_TRACK_MINES, GP2_TRACK_MINES

org $30F500
TRACK_MINES_FUNC_TABLE:
	FZ_TRACK_MINES:
		%TrackMinesFunclet($0C00, !FZ_TRACK_MINE_TABLE)
	GP2_TRACK_MINES:
		%TrackMinesFunclet($1C00, !GP2_TRACK_MINE_TABLE)
;=========================================================

;=========================================================
;Tile pool hijack table
;=========================================================
macro TilePoolTableFunclet(BANK_ADDR_B, TILE_POOL_TABLE_ADDR_S)
	LDX #<TILE_POOL_TABLE_ADDR_S>
	MVN $7F, <BANK_ADDR_B>
	RTS
endmacro

org $30F600
TILE_POOL_JSR_TABLE:
	dw FZ_TILE_POOL, FZ_TILE_POOL, FZ_TILE_POOL, GP2_TILE_POOL

org $30F700
TILE_POOL_FUNC_TABLE:
	FZ_TILE_POOL:
		%TilePoolTableFunclet(!FZ_TILE_POOL_BANK, !FZ_TILE_POOL_ADDR)
	GP2_TILE_POOL:
		%TilePoolTableFunclet(!GP2_TILE_POOL_BANK, !FZ_TILE_POOL_ADDR)
;=========================================================

;=========================================================
;Track setting hijack table
;=========================================================
macro TrackSettingTableFunclet(TRACK_SETTING_TABLE_ADDR_L)
	TYX
	LDA <TRACK_SETTING_TABLE_ADDR_L>, X
	RTS
endmacro

org $30FA00
TRACK_SETTINGS_JSR_TABLE:
	dw FZ_TRACK_SETTINGS, FZ_TRACK_SETTINGS, FZ_TRACK_SETTINGS, GP2_TRACK_SETTINGS

org $30FB00
TRACK_SETTINGS_FUNC_TABLE:
	FZ_TRACK_SETTINGS:
		%TrackSettingTableFunclet(!FZ_TRACK_SETTINGS_TABLE_ADDRESS)
	GP2_TRACK_SETTINGS:
		%TrackSettingTableFunclet(!GP2_TRACK_SETTINGS_TABLE_ADDRESS)
;=========================================================

;=========================================================
; Read org size hijacking table
;=========================================================
macro ReadOrgFunclet(READ_ORG_TABLE_ADDR_L)
	TYX
	LDA <READ_ORG_TABLE_ADDR_L>,X
	STA $22
	INX
	INX
	LDA <READ_ORG_TABLE_ADDR_L>,X
	STA $26
	RTS
endmacro

org $30FC00
READ_ORG_SIZE_JSR_TABLE:
	dw FZ_READ_ORG, FZ_READ_ORG, FZ_READ_ORG, GP2_READ_ORG

org $30FD00
READ_ORG_FUNC_TABLE:
	FZ_READ_ORG:
		%ReadOrgFunclet(!FZ_READ_ORG_TABLE)
	GP2_READ_ORG:
		%ReadOrgFunclet(!GP2_READ_ORG_TABLE)
;=========================================================

;=========================================================
; Bank read hijacking table
;=========================================================
macro BankReadFunclet(BANK_ADDR_S, BANK_READ_TABLE_ADDR_L)
	TYX
	LDA <BANK_READ_TABLE_ADDR_L>, X
	CLC
	ADC	#<BANK_ADDR_S>
	AND #$00FF
	STA $24
	RTS
endmacro

org $30F800
SET_READ_BANK_JSR_TABLE:
	dw FZ_SET_READ_BANK, FZ_SET_READ_BANK, FZ_SET_READ_BANK, GP2_SET_READ_BANK

org $30F900
SET_READ_BANK_FUNC_TABLE:
	FZ_SET_READ_BANK:
		%BankReadFunclet($0000, !FZ_TRACK_BANK_TABLE)
	GP2_SET_READ_BANK:
		%BankReadFunclet($0010, !GP2_TRACK_BANK_TABLE)
;=========================================================

;=========================================================
; Pallete hijacking table
;=========================================================
macro PaletteFunclet(BANK_ADDR_B, FZ_PALETETE_TABLE_ADDR_L)
	TYX
	LDA <FZ_PALETETE_TABLE_ADDR_L>, X
	TAX
	LDY #$0520
	LDA #$00df
	MVN $00, <BANK_ADDR_B>
	RTS
endmacro

org $30FE00
LOAD_PALETTE_JSR_TABLE:
	dw LOAD_FZ_PALETTE, LOAD_FZ_PALETTE, LOAD_FZ_PALETTE, LOAD_GP2_PALETTE

org $30FF00
LOAD_PALETTE_FUNC_TABLE:
	LOAD_FZ_PALETTE:
		%PaletteFunclet(!FZ_PALETTE_BANK, !FZ_PALETTE_TABLE_ADDRESS)
	LOAD_GP2_PALETTE:
		%PaletteFunclet(!GP2_PALETTE_BANK, !GP2_PALETTE_TABLE_ADDRESS)
;=========================================================