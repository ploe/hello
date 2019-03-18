INCLUDE "hardware.inc"

INCLUDE "actors.inc"
INCLUDE "joypad.inc"
INCLUDE "memlib.inc"

SECTION "ACTORS WRAM", WRAM0
RolesLength EQU 3 - 1
RolesTop::

RoleStart::
RoleDraw:: ds 2
RoleMove:: ds 2
RoleAI:: ds 2
RoleSheet:: ds 1
RoleEnd::
RoleSize EQU RoleEnd-RoleStart

ds RoleSize * RolesLength

RoleBound:: ds 2

ActorsLength EQU 10 - 1
ActorsTop:

ActorStart:
ActorTicks: ds 1
ActorFrame: ds 1
ActorRole: ds 1
ActorEnabled: ds 1
ActorEnd:

ActorSize EQU ActorEnd-ActorStart

ds ActorSize * ActorsLength

SECTION "Actors Routines", ROM0

RoleReset::
	xor a
	ld [RoleBound], a
	ret

; increments the RoleBound
RoleDone::
	ld a, [RoleBound]
	inc a
	ld [RoleBound], a
	ret

; sets hl to the address of RoleBound
RoleNew::
	; get the RoleBound offset
	ld a, [RoleBound]
	ld a, c
	xor a
	ld a, b

	; get the address of the role to use
	ld hl, RolesTop
	add hl, bc
	ret

; called by RoleSetMethod macro
; hl[bc] = de
RoleSetMethodSub::
	push hl
	add hl, bc
	ld a, d
	ld [hli], a
	ld a, e
	ld [hl], a
	pop hl
	ret

MonsterMove::
MonsterDraw::
MonsterAI::

SampleRole::
	call RoleNew

	RoleSetMethod RoleDraw,MonsterDraw
	;RoleSetMethod RoleAI,MonsterAI

	call RoleDone
