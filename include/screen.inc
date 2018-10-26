	IF !DEF(SCREEN_INC)
SCREEN_INC SET 1
	; defined in src/screen.asm
	GLOBAL SCREEN_INIT, SCREEN_START, SCREEN_WAIT

	; defined in src/wram0.asm
	GLOBAL screen_waiting
ENDC
