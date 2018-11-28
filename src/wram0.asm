SECTION "OAM BUFFER", WRAM0
OAM_BUFFER:: ds 4*40

SECTION "JOYPAD WRAM", WRAM0
joypad_buttons:: ds 1
joypad_pressed:: ds 1

SECTION "SCREEN WRAM", WRAM0
screen_waiting:: ds 1

SECTION "BLOB WRAM", WRAM0
blob_x:: ds 1
blob_y:: ds 1
blob_animation:: ds 2
blob_clip:: ds 1
blob_frame:: ds 1
blob_interval:: ds 1

SECTION "STICK WRAM", WRAM0
stick_animation: ds 2
stick_clip: ds 1
stick_frame: ds 1
stick_interval: ds 1

