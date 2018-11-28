INCLUDE "hardware.inc"

INCLUDE "joypad.inc"
INCLUDE "memlib.inc"

SECTION "BLOB WRAM", WRAM0
BlobX: ds 1
BlobY: ds 1
BlobAnimation: ds 2
BlobClip: ds 1
BlobFrame: ds 1
BlobInterval: ds 1

SECTION "Blob Routines", ROM0

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
	ld a, [BlobAnimation]
	ld h, a

	ld a, [BlobAnimation+1]
	ld l, a

	ENDM

; b <- offset, c <- interval
GET_OFFSET_AND_INTERVAL: MACRO
	FETCH_ANIMATION

	ld a, [BlobFrame]
	add a, a
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

BlobSetFace::
	JOYPAD_BTN_DOWN JOYPAD_DOWN
	THEN_SET_FACE BlobClip, BLOB_DOWN, OAM_BUFFER+3, 0

	JOYPAD_BTN_DOWN JOYPAD_UP
	THEN_SET_FACE BlobClip, BLOB_UP, OAM_BUFFER+3, 0

	JOYPAD_BTN_DOWN JOYPAD_RIGHT
	THEN_SET_FACE BlobClip, BLOB_RIGHT, OAM_BUFFER+3, 0

	JOYPAD_BTN_DOWN JOYPAD_LEFT
	THEN_SET_FACE BlobClip, BLOB_RIGHT, OAM_BUFFER+3, OAMF_XFLIP
	; right face, but flipped on the x axis

	JOYPAD_ANY_DPAD
	jr z, .still
	ld hl, BlobDance

	jr .return
.still
	ld hl, BlobStill
	xor a
	ld [BlobInterval], a
	ld [BlobFrame], a

.return
	ld a, h
	ld [BlobAnimation], a

	ld a, l
	ld [BlobAnimation+1], a

	ret

BlobUpdate::
.down
	JOYPAD_BTN_DOWN JOYPAD_DOWN
	jr z, .up
	ld a, [BlobY]
	inc a
	ld [BlobY], a
.up
	JOYPAD_BTN_DOWN JOYPAD_UP
	jr z, .right
	ld a, [BlobY]
	dec a
	ld [BlobY], a
.right
	JOYPAD_BTN_DOWN JOYPAD_RIGHT
	jr z, .left
	ld a, [BlobX]
	inc a
	ld [BlobX], a
.left
	JOYPAD_BTN_DOWN JOYPAD_LEFT
	jr z, .return
	ld a, [BlobX]
	dec a
	ld [BlobX], a

.return
	ld a, [BlobY]
	ld [OAM_BUFFER], a

	ld a, [BlobX]
	ld [OAM_BUFFER+1], a

	ret

; increments the frame, if it's at the end of the animation it loops it
INC_FRAME:
	xor a
	ld [BlobInterval], a
	; reset the interval

	ld a, [BlobFrame]
	inc a
	ld [BlobFrame], a
	; if so advance the frame

	GET_OFFSET_AND_INTERVAL

	ld a, c
	cp a, b
	jr nz, .return
	; is the frame and interval is zero?

	xor a
	ld [BlobFrame], a
	; back to frame one
	
	GET_OFFSET_AND_INTERVAL

.return
	ret

BlobDance:
	db 1, 15
	db 0, 15
	db 0, 0

BlobStill:
	db 0, $FF
	db 0, 0

BlobDraw::
	call BlobSetFace ; get clip
.set_frame
	GET_OFFSET_AND_INTERVAL

	ld a, [BlobInterval]
	inc a
	ld [BlobInterval], a
	; increment the animation interval

	cp a, c
	jr nz, .set_oam
	; has our interval elapsed?

	call INC_FRAME
	; then we increment the frame

.set_oam
	ld a, [BlobClip]
	add a, b
	; add the tile clip to the offset

	ld [OAM_BUFFER+2], a
	; update the tile

	ret

BlobSheet:
INCBIN "blob.2bpp"
BlobSheetEnd:
BLOB_SHEET_SIZE EQU BlobSheetEnd-BlobSheet

STICK_SHEET:
INCBIN "stick.2bpp"
STICK_SHEET_END:
STICK_SHEET_SIZE EQU STICK_SHEET_END-STICK_SHEET

BlobNew::
	ld a, 16
	ld [OAM_BUFFER], a

	ld a, 16
	ld [OAM_BUFFER+1], a

	ld a, BLOB_DOWN
	ld [BlobClip], a

	xor a
	ld [BlobFrame], a
	ld [BlobInterval], a

	ld hl, BlobDance
	ld a, h
	ld [BlobAnimation], a
	ld a, l
	ld [BlobAnimation+1], a

	MEMCPY _VRAM, BlobSheet, BLOB_SHEET_SIZE
	MEMCPY VRAM_TILES + BLOB_SHEET_SIZE, STICK_SHEET, STICK_SHEET_SIZE

	ret
