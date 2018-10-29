; hardware abstractions
INCLUDE "screen.inc"
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

	call GAME_LOOP

GAME_LOOP:
	call SCREEN_WAIT	

	call DMA_IDLE_HRAM

	call JOYPAD_GET

	call BLOB_SET_FACE
	call BLOB_DRAW
	
	jp GAME_LOOP

