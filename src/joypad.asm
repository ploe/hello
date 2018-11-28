INCLUDE "hardware.inc"
INCLUDE "joypad.inc"

SECTION "JOYPAD WRAM", WRAM0
JoypadButtons:: ds 1
JoypadPressed:: ds 1

SECTION "Joypad Routines", ROM0
JOYPAD_STATE EQU %00001111
JoypadGet::
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
	ld a, [JoypadButtons]
	cpl
	and b
	ld [JoypadPressed], a
	ld a, b
	ld [JoypadButtons], a

	ret
