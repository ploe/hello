; Gameboy definitions
INCLUDE "hardware.inc"

; hardware abstractions
INCLUDE "memlib.inc"
INCLUDE "joypad.inc"

; game logic
INCLUDE "blob.inc"

SECTION "Header", ROM0[$100]

ENTRYPOINT:
	di
	jp START

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0

START:
	call INIT
	call GAME_LOOP

INIT:
	call SCREEN_INIT

	call BLOB_NEW

	call SCREEN_START

SCREEN_INIT:
.wait
	ld a, [rLY]
	cp 144
	jr c, .wait
	; wait for vblank

	xor a
	ld [rLCDC], a
	; turn off LCDC	

	ld a, %11100100
	ld [rBGP], a
	; init background palette

	ld a, %11010000
	ld [rOBP0], a
	; set object palette

	xor a
	ld [rSCX], a
	ld [rSCY], a
	; set screen offset

	ld [rNR52], a
	; turn off the sound

	MEMCPY DMA_IDLE_HRAM, DMA_IDLE, DMA_IDLE_END-DMA_IDLE
	; copy the DMA_IDLE routine to HRAM

	ld a, LCDCF_ON + LCDCF_OBJON + LCDCF_BGON
	ld [rLCDC], a
	; turn screen on, show background

	ret

SCREEN_START:
	ld a, IEF_VBLANK
	ld [rIE], a

	ei

	ret

GAME_LOOP:
	call VBLANK_WAIT	

	call DMA_IDLE_HRAM

	call JOYPAD_GET

	call BLOB_SET_FACE
	call BLOB_DRAW
	
	jp GAME_LOOP

; clip = first db
; interval -> frame
; 0 to end

VBLANK_WAIT:
	ld hl, vblank_period
.wait
	halt
	nop
	; halt until interrupt

	ld a, 0
	cp [hl]
	jr z, .wait
	; was it a vblank interrupt?

	ld [hl], a
	ret
	; if so, we can run the next frame's stuff

; this is the routine that transfers from the WRAM Buffer to OAM 
DMA_IDLE:
	ld a, HIGH(OAM_BUFFER)
	ld [rDMA], a
	; set DMA transfer off

	ld a, $28
.next
	dec a
	jr nz, .next
	ret
	; wait until the transfer has finished

DMA_IDLE_END:

SECTION "Sprites", ROM0

SECTION "VBLANK IRQ", ROM0[$40]
	ld a, $1
	ld [vblank_period], a
	reti

SECTION "Work RAM", WRAM0[$C000]
EXPORT OAM_BUFFER
OAM_BUFFER: ds 4*40

joypad_buttons: ds 1
joypad_pressed: ds 1
vblank_period: ds 1

blob_animation: ds 2
blob_clip: ds 1
blob_frame: ds 1
blob_interval: ds 1

SECTION "VRAM Tile Data", VRAM[$8000]
EXPORT VRAM_TILES
VRAM_TILES:

SECTION "DMA Idle Process", HRAM[$FF80]
DMA_IDLE_HRAM:
