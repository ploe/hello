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
	call SampleRole
	call SCREEN_START

GAME_LOOP:
	call SCREEN_WAIT	

	call JoypadGet

	call BlobUpdate
	call BlobDraw
	
	call DMA_IDLE_HRAM

;	ld a, $A	
;	ld [$0000], a

;	ld a, $0
;	ld [$6000], a
;	ld a, $1
;	ld [$6000], a
;	ld a, $8
;	ld [$4000], a
	
	;ld a, 13
	;ld [$A000], a

;	ld a,  [$A000]
;	ld [$C010], a

	jp GAME_LOOP
