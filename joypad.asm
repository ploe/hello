INCLUDE "hardware.inc"
INCLUDE "joypad.inc"

SECTION "Joypad Routines", ROM0
JOYPAD_STATE EQU %00001111
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
	ld a, [joypad_buttons]
	cpl
	and b
	ld [joypad_pressed], a
	ld a, b
	ld [joypad_buttons], a

	ret
