;============================================================================
; LoadBlockToVRAM -- Macro that simplifies calling LoadVRAM to copy data to VRAM
;----------------------------------------------------------------------------
; In: SRC_ADDR -- 24 bit address of source data
;     DEST -- VRAM address to write to (WORD address!!)
;     SIZE -- number of BYTEs to copy
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: A, X, Y
;----------------------------------------------------------------------------

;============================================================================
;LoadBlockToVRAM SRC_ADDRESS, DEST, SIZE
;   requires:  mem/A = 8 bit, X/Y = 16 bit
;============================================================================
macro LoadBlockToVRAM(SRC_ADDR_BANK, SRC_ADDR, DEST, SIZE)
    ldx.w #<DEST>      ; DEST
    stx $2116       ; $2116: Word address for accessing VRAM.
    lda.b #<SRC_ADDR_BANK>    ; SRCBANK
    ldx.w #<SRC_ADDR>         ; SRCOFFSET
    ldy.w #<SIZE>         ; SIZE
    jsr LoadVRAM
endmacro
;============================================================================

;============================================================================
; LoadVRAM -- Load data into VRAM
;----------------------------------------------------------------------------
; In: A:X  -- points to the data
;     Y     -- Number of bytes to copy (0 to 65535)  (assumes 16-bit index)
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
; Modifies: none
;----------------------------------------------------------------------------
; Notes:  Assumes VRAM address has been previously set!!
;----------------------------------------------------------------------------
LoadVRAM:
	pha
	phx
	phy			
	phb
	php		;Preserve registers
		
	sep #$20	;Careful not to SEP $10, or it will erase upper half of Y!

	stz $420B	;Clear the DMA control register
	stx $4302	;Store the data offset into DMA source offset
	sty $4305   ;Store the size of the data block
	sta $4304	;Store the data bank of the source data

	lda #$80
	sta $2115	;set VRAM transfer mode to word-access, increment by 1

	lda #$01	;Set the DMA mode (word, normal increment)
	sta $4300       
	lda #$18    ;Set the destination register (VRAM gate)
	sta $4301      
	lda #$01    ;Initiate the DMA transfer
	sta $420B

	plp		;Restore registers
	plb
	ply
	plx
	pla
	rts		;Return to caller
;============================================================================
