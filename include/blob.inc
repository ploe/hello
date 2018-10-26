	IF !DEF(BLOB_INC)
BLOB_INC SET 1

; defined in src/blob.asm
GLOBAL BLOB_NEW, BLOB_SET_FACE, BLOB_DRAW

; defined in WRAM0
GLOBAL blob_animation, blob_clip, blob_frame, blob_interval

ENDC
