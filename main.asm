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

	call SCREEN_START

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
	ld a, LCDCF_ON + LCDCF_OBJON + LCDCF_BGON
	ld [rLCDC], a

	ret

SCREEN_START:
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
	ld [blob_interval], a

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

	call JOYPAD_GET

	call BLOB_DRAW
	
	jp GAME_LOOP

; clip = first db
; interval -> frame
; 0 to end

JOYPAD_STATE EQU %00001111
JOYPAD_DOWN EQU %10000000

JOYPAD_GET:
	ld a, P1F_5
	ld [rP1], a
	; set to read d-pad (Right, Left, Up, Down)

	ld a, [rP1]
	ld a, [rP1]
	; read twice, as the state can bounce

	cpl
	and JOYPAD_STATE
	swap a
	ld b, a
	; stick the DPAD in b

	ld a, P1F_4
	ld [rP1], a
	; set to read the buttons (A, B, Select, Start)
	
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	; read six times, as the state can bounce

	cpl
	and JOYPAD_STATE
	or b
	; a is now loaded with the joypad state

	ld b, a
	ld a, [joypad_down]
	cpl
	and b
	ld [joypad_pressed], a
	ld a, b
	ld [joypad_down], a

	ret

blob_dance_down:
	db 1, 0
	db 0, 15
	db 1, 15
	db 0, 0

; load hl with a pointer to the animation
FETCH_ANIMATION: MACRO
	ld a, [blob_animation]
	ld h, a

	ld a, [blob_animation+1]
	ld l, a

	ENDM

; b <- offset, c <- interval
GET_OFFSET_AND_INTERVAL: MACRO
	FETCH_ANIMATION

	ld a, [blob_frame]
	sla a
	add a, l
	ld l, a
	; get the frame data from the animation

	ld a, [hli]
	ld b, a
	; get offset

	ld a, [hl]
	ld c, a
	; load interval

	ENDM

BLOB_DRAW:
.set_clip
	ld a, [blob_clip]
	cp a, 0
	jr nz, .set_frame
	; have we already set the clip?

	FETCH_ANIMATION

	ld a, [hl]
	ld [blob_clip], a
	; get the clip, the first line of the animation

	ld a, 1
	ld [blob_frame], a
	; initialise the frame

.set_frame
	ld a, [joypad_down]
	and JOYPAD_DOWN
	cp a, 0
	jr nz, .animoot

	ld b, 0
	jr .set_oam

.animoot
	GET_OFFSET_AND_INTERVAL

	ld a, [blob_interval]
	inc a
	ld [blob_interval], a
	; increment the animation interval

	cp a, c
	jr nz, .set_oam
	; has our interval elapsed?

	call INC_FRAME
	; then we increment the frame

.set_oam
	ld a, [blob_clip]
	add a, b
	; add the tile clip to the offset

	ld [OAM_BUFFER+2], a
	; update the tile

	ret

; increments the frame, if it's at the end of the animation it loops it
INC_FRAME:
	xor a
	ld [blob_interval], a
	; reset the interval

	ld a, [blob_frame]
	inc a
	ld [blob_frame], a
	; if so advance the frame

	GET_OFFSET_AND_INTERVAL

	ld a, c
	cp a, b
	jr nz, .return
	; is the frame and interval is zero?

	ld a, 1
	ld [blob_frame], a
	; back to frame one
	
	GET_OFFSET_AND_INTERVAL

.return
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

joypad_pressed: ds 1
joypad_down: ds 1
vblank_period: ds 1

blob_animation: ds 2
blob_clip: ds 1
blob_frame: ds 1
blob_interval: ds 1
blob_steps: ds 10

SECTION "DMA Idle Process", HRAM[$FF80]
DMA_IDLE_HRAM:
