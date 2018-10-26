; Gameboy definitions
INCLUDE "hardware.inc"

; hardware abstractions
INCLUDE "memlib.inc"
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


SECTION "Sprites", ROM0

SECTION "Work RAM", WRAM0[$C000]
EXPORT OAM_BUFFER
OAM_BUFFER: ds 4*40

joypad_buttons: ds 1
joypad_pressed: ds 1
EXPORT screen_waiting
screen_waiting: ds 1

blob_animation: ds 2
blob_clip: ds 1
blob_frame: ds 1
blob_interval: ds 1

SECTION "VRAM Tile Data", VRAM[$8000]
EXPORT VRAM_TILES
VRAM_TILES:

SECTION "DMA Idle Process", HRAM[$FF80]
EXPORT DMA_IDLE_HRAM
DMA_IDLE_HRAM:
