	IF !DEF(ACTORS_INC)
ACTORS_INC SET 1

; RoleSetMethod RoleDraw DrawMethod
RoleSetMethod: MACRO 
	push hl

	ld bc, RoleEnd-\1
	ld de, \2
	pop hl

	call RoleSetMethodSub
	
	ENDM

ENDC
