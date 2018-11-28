INCLUDE "hardware.inc"

INCLUDE "memlib.inc"

SECTION "Screen Setup Routines", ROM0

SCREEN_INIT::
.wait
	ld a, [rLY]
	cp 144
	jr c, .wait
	; wait for vblank

	xor a
	ld [rLCDC], a
	; turn off LCDC	

	ld a, %11100100
	ld [rBGP], a
	; init background palette

	ld a, %11010000
	ld [rOBP0], a
	; set object palette

	xor a
	ld [rSCX], a
	ld [rSCY], a
	; set screen offset

	ld [rNR52], a
	; turn off the sound

	MEMCPY DMA_IDLE_HRAM, DMA_IDLE, DMA_IDLE_END-DMA_IDLE
	; copy the DMA_IDLE routine to HRAM

	ret

SCREEN_START::
	ld a, LCDCF_ON | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	; turn screen on, show background

	ld a, IEF_VBLANK
	ld [rIE], a

	ei

	ret

; clip = first db
; interval -> frame
; 0 to end

SCREEN_WAIT::
.wait
	halt
	; halt until interrupt

	ld a, [screen_waiting]
	and a
	jr nz, .wait
	; was it a vblank interrupt?

	ld a, 1
	ld [screen_waiting], a
	ret
	; if so, we can run the next frame's stuff

; this is the routine that transfers from the WRAM Buffer to OAM 
DMA_IDLE:
	ld a, HIGH(OAM_BUFFER)
	ld [rDMA], a
	; set DMA transfer off

	ld a, $28
.next
	dec a
	jr nz, .next
	ret
	; wait until the transfer has finished
DMA_IDLE_END:

SECTION "VBLANK IRQ", ROM0[$40]
	xor a
	ld [screen_waiting], a

	reti

