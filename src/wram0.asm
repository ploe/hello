INCLUDE "joypad.inc"
INCLUDE "screen.inc"
INCLUDE "blob.inc"

SECTION "Work RAM", WRAM0[$C000]
EXPORT OAM_BUFFER
OAM_BUFFER: ds 4*40

; include/joypad.inc
joypad_buttons: ds 1
joypad_pressed: ds 1

; include/screen.inc
screen_waiting: ds 1

; include/blob.inc
blob_animation: ds 2
blob_clip: ds 1
blob_frame: ds 1
blob_interval: ds 1

