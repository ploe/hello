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

	ld hl, $8000
	ld de, DAISY_SPRITESHEET
	ld bc, DAISY_SPRITESHEET_END - DAISY_SPRITESHEET
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

	ld a, 24
	ld [OAM_BUFFER], a

	ld a, 32
	ld [OAM_BUFFER+1], a

	; turn screen on, show background
	ld a, %10000011
	ld [rLCDC], a

	call DMA_COPY_IDLE
	call $FF80

.lockup
	jr .lockup

DMA_IDLE:
	ld a, $C1
	ld [rDMA], a

	ld a, $28
.next
	dec a
	jr nz, .next
	ret

DMA_IDLE_END:
	

DMA_COPY_IDLE:
	ld hl, $FF80	; dst
	ld de, DMA_IDLE	; iterator 
	ld bc, DMA_IDLE_END - DMA_IDLE 

.next
	; copy byte and increment counters
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	
	; loop if count is non-zero
	ld a, b
	or c
	jr nz, .next

	ret

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

DAISY_SPRITESHEET:
INCBIN "daisy.2bpp"
DAISY_SPRITESHEET_END:

Section "Hello World string", ROM0

HelloWorldStr:
	db "hello, world",0

SECTION "OAM Buffer", WRAM0[$C100]
OAM_BUFFER: DS 4*40
