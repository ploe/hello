	IF !DEF(MEMORY_INC)
MEMORY_INC SET 1

; args dst, src, size
MEMCPY: MACRO
	ld hl, \1
	ld de, \2
	ld bc, \3

.next_word\@
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	; copy word and increment counters

	ld a, b
	or c
	jr nz, .next_word\@
	; loop till count is 0

	ENDM

; args dst, value, size
MEMSET: MACRO
	ld hl, \1
	ld d, \2
	ld bc, \3

.next_word\@
	ld a, d
	ld [hli], a
	dec bc
	; copy word and decrement size

	ld a, b
	or c
	jr nz, .next_word\@
	; loop till count is 0

	ENDM


ENDC
