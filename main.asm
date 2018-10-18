INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp start

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0

start:
	call init

	call game_loop

init:
	call screen_init

	call DMA_COPY_IDLE
	call DMA_IDLE_HRAM

	call blob_new

	call screen_start

screen_init:
.wait
	; wait for VBlank
	ld a, [rLY]
	cp 144
	jr c, .wait

	; turn off LCDC	
	xor a
	ld [rLCDC], a

	; init background pallete
	ld a, %11100100
	ld [rBGP], a

	ld a, %11010000
	ld [rOBP0], a

	; set screen offset
	xor a
	ld [rSCX], a
	ld [rSCY], a

	; turn off the sound
	ld [rNR52], a

	; turn screen on, show background
	ld a, %10000011
	ld [rLCDC], a

	ret

screen_start:

	ld a, IEF_VBLANK
	ld [rIE], a

	ei

	ret

blob_new:
	ld a, 24
	ld [OAM_BUFFER], a

	ld a, 32
	ld [OAM_BUFFER+1], a

	ld a, 0
	ld [blob_frame], a

	ld hl, $8000
	ld de, BLOB_SPRITESHEET
	ld bc, BLOB_SPRITESHEET_END - BLOB_SPRITESHEET
.next_byte
	; copy byte and increment counters
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	
	; loop if count is non-zero
	ld a, b
	or c
	jr nz, .next_byte
	ret

game_loop:
	call VBLANK_WAIT
	
	ld a, [blob_frame]
	inc a
	ld [blob_frame], a

	cp a, 15
	jr nz, game_loop

	xor a
	ld [blob_frame], a

	ld a, [OAM_BUFFER]
	add 4
	ld [OAM_BUFFER], a

	
	ld a, [OAM_BUFFER+2]
	xor a, %00000001
	ld [OAM_BUFFER+2], a

	call DMA_IDLE_HRAM
	
	jp game_loop

VBLANK_WAIT:
	ld hl, vblank_period
.wait
	halt
	nop
	nop

	ld a, 0
	cp [hl]
	jr z, .wait

	ld [hl], a
	ret

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
	ld hl, DMA_IDLE_HRAM	; dst
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

SECTION "Sprites", ROM0

BLOB_SPRITESHEET:
INCBIN "blob.2bpp"
BLOB_SPRITESHEET_END:

SECTION "VBLANK IRQ", ROM0[$40]
	ld a, $1
	ld [vblank_period], a
	reti

SECTION "Work RAM", WRAM0[$C100]
OAM_BUFFER: ds 4*40
vblank_period: ds 1
blob_frame: ds 1

SECTION "DMA Idle Process", HRAM[$FF80]
DMA_IDLE_HRAM:
