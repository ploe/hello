; hardware abstractions
INCLUDE "joypad.inc"

SECTION "Header", ROM0[$100]
ENTRYPOINT:
	di
	jp START

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0

START:
	call SCREEN_INIT
	call BLOB_NEW
	call SCREEN_START

GAME_LOOP:
	call SCREEN_WAIT	

	call JOYPAD_GET

	call BLOB_UPDATE
	call BLOB_SET_FACE
	call BLOB_DRAW
	
	call DMA_IDLE_HRAM

	jp GAME_LOOP
