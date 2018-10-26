	IF !DEF(MEMORY_INC)
MEMORY_INC SET 1

; args dst, src, size
MEMCPY: MACRO
	ld hl, \1
	ld de, \2
	ld bc, \3

.next_byte\@
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	; copy byte and increment counters

	ld a, b
	or c
	jr nz, .next_byte\@
	; loop if count is non-zero

	ENDM

ENDC
