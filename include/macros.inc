IF !DEF(MACROS_INC)
DEF MACROS_INC EQU 1

MACRO cleartill
	REPT \1 - @
		nop
	ENDR
ENDM

MACRO lb ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 | ((\3) & $ff)
ENDM

MACRO dbw
	db \1
	dw \2
ENDM

MACRO dba
	db BANK(\1)
	dw \1
ENDM

DEF text EQUS "db_w"
DEF line EQUS "db_w \"[换行FF]\", "
DEF para_end EQUS "db_w \"[换段F9]\""
DEF text_end EQUS ""

ENDC ; MACROS_INC
