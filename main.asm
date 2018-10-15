INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0

Start:

.waitVBlank
	; wait for VBlank
	ld a, [rLY]
	cp 144
	jr c, .waitVBlank

	; turn off LCDC	
	xor a
	ld [rLCDC], a

	ld hl, $8000
	ld de, DAISY_SPRITESHEET
	ld bc, DAISY_SPRITESHEET_END
.copyDaisy
	; copy byte and increment counters
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	
	; loop if count is non-zero
	ld a, b
	or c
	jr nz, .copyDaisy
; end of copyDaisy

	; initialize copyFont loop
	ld hl, $9000
	ld de, FontTiles
	ld bc, FontTilesEnd - FontTiles
.copyFont
	; copy byte and increment counters
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	
	; loop if count is non-zero
	ld a, b
	or c
	jr nz, .copyFont
; end of copyFont

	; copy string to top left corner
	ld hl, $9800
	ld de, HelloWorldStr
.copyString
	ld a, [de]
	ld [hli], a
	inc de
	and a
	jr nz, .copyString
; end of copy string

	; init background pallete
	ld a, %11100100
	ld [rBGP], a

	; set screen offset
	xor a
	ld [rSCX], a
	ld [rSCY], a

	; turn off the sound
	ld [rNR52], a

	; turn screen on, show background
	ld a, %10000001
	ld [rLCDC], a

.lockup
	jr .lockup

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

DAISY_SPRITESHEET:
INCBIN "daisy.2bpp"
DAISY_SPRITESHEET_END:

Section "Hello World string", ROM0

HelloWorldStr:
	db "hello, world", 0
