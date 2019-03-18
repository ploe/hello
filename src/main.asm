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
	call BlobNew
	call SCREEN_START
	call SampleRole

GAME_LOOP:
	call SCREEN_WAIT	

	call JoypadGet

	call BlobUpdate
	call BlobDraw
	
	call DMA_IDLE_HRAM

	jp GAME_LOOP
