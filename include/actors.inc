	IF !DEF(ACTORS_INC)
ACTORS_INC SET 1

; RoleSetMethod RoleDraw DrawMethod
RoleSetMethod: MACRO 
	ld bc, \1 - RoleStart
	ld de, \2

	call RoleSetMethodSub
	
	ENDM

ENDC


