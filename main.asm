INCLUDE "hardware.inc"

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

	call DMA_COPY_IDLE
	call DMA_IDLE_HRAM

	call BLOB_NEW

	call screen_start

SCREEN_INIT:
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

BLOB_NEW:
	ld a, 16
	ld [OAM_BUFFER], a

	ld a, 16
	ld [OAM_BUFFER+1], a

	ld a, 0
	ld [blob_clip], a
	ld [blob_frame], a
	ld [blob_ticks], a

	ld hl, blob_dance_down
	ld a, h
	ld [blob_animation], a
	ld a, l
	ld [blob_animation+1], a

	ld hl, $8010
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

GAME_LOOP:
	call VBLANK_WAIT	

	call DMA_IDLE_HRAM

	call BLOB_DRAW
	
	jp GAME_LOOP

; clip = first db
; ticks -> frame
; 0 to end

blob_dance_down:
	db 1, $FF
	db 0, $FF
	db 1, $FF
	db 0, 0

BLOB_DRAW:
.set_clip
	ld a, [blob_clip]
	cp a, 0
	jr nz, .get_offset
	; have we already set the clip?

	ld hl, blob_dance_down
	ld a, [hl]
	ld [blob_clip], a
	; get the clip, the first line of the animation

.get_offset
	ld a, [blob_frame]
	inc a
	ld [blob_frame], a
	; increment frame counter

	ld hl, blob_dance_down
	sla a
	add a, l
	ld l, a
	; get the frame data from the animation

	ld a, [hli]
	ld [blob_steps+1], a
	ld b, a
	; get offset

	ld a, [hl]
	; load interval

	cp a, b
	jr nz, .set_oam
	; is the frame and ticks is zero?

	xor a
	ld [blob_frame], a
	ld [blob_ticks], a
	jr .get_offset
	; then reset the frame and start again

.set_oam

	ld a, [blob_clip]
	add a, b

	; add the tile clip to the offset
	ld [OAM_BUFFER+2], a
	; update the tile

	ret

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

blob_animation: ds 2
blob_clip: ds 1
blob_frame: ds 1
blob_ticks: ds 1
blob_steps: ds 10

SECTION "DMA Idle Process", HRAM[$FF80]
DMA_IDLE_HRAM:
