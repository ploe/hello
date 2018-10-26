INCLUDE "hardware.inc"

INCLUDE "joypad.inc"
INCLUDE "memlib.inc"

INCLUDE "blob.inc"

BLOB_DOWN EQU 0
BLOB_RIGHT EQU 2
BLOB_UP EQU 4

THEN_SET_FACE: MACRO
	jr z, .return\@

	ld a, \2
	ld [\1], a

	ld a, \4
	ld [\3], a
		
.return\@
	ENDM

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

SECTION "Blob Routines", ROM0

BLOB_SET_FACE:
	JOYPAD_BTN_DOWN JOYPAD_DOWN
	THEN_SET_FACE blob_clip, BLOB_DOWN, OAM_BUFFER+3, 0

	JOYPAD_BTN_DOWN JOYPAD_UP
	THEN_SET_FACE blob_clip, BLOB_UP, OAM_BUFFER+3, 0

	JOYPAD_BTN_DOWN JOYPAD_RIGHT
	THEN_SET_FACE blob_clip, BLOB_RIGHT, OAM_BUFFER+3, 0

	JOYPAD_BTN_DOWN JOYPAD_LEFT
	THEN_SET_FACE blob_clip, BLOB_RIGHT, OAM_BUFFER+3, OAMF_XFLIP
	; right face, but flipped on the x axis

	JOYPAD_ANY_DPAD
	jr z, .still
	ld hl, blob_dance

	jr .return
.still
	ld hl, blob_still
	ld a, 0
	ld [blob_interval], a
	ld [blob_frame], a

.return
	ld a, h
	ld [blob_animation], a

	ld a, l
	ld [blob_animation+1], a

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

	ld a, 0
	ld [blob_frame], a
	; back to frame one
	
	GET_OFFSET_AND_INTERVAL

.return
	ret

blob_dance:
	db 1, 15
	db 0, 15
	db 0, 0

blob_still:
	db 0, $FF
	db 0, 0

BLOB_DRAW:
.set_frame
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

BLOB_SPRITESHEET:
INCBIN "blob.2bpp"
BLOB_SPRITESHEET_END:

BLOB_NEW:
	ld a, 16
	ld [OAM_BUFFER], a

	ld a, 16
	ld [OAM_BUFFER+1], a

	ld a, BLOB_DOWN
	ld [blob_clip], a

	ld a, 0
	ld [blob_frame], a
	ld [blob_interval], a

	ld hl, blob_dance
	ld a, h
	ld [blob_animation], a
	ld a, l
	ld [blob_animation+1], a

	MEMCPY VRAM_TILES, BLOB_SPRITESHEET, BLOB_SPRITESHEET_END-BLOB_SPRITESHEET

	ret
