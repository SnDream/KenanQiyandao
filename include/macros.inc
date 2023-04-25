IF !DEF(MACROS_INC)
DEF MACROS_INC EQU 1

MACRO cleartill
	rept \1 - @
		nop
	endr
endm

MACRO lb ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 | ((\3) & $ff)
endm

MACRO dbw
	db \1
	dw \2
endm

MACRO dba
	db BANK(\1)
	dw \1
endm

text equs "w_text"
line equs "w_text \"[换行FF]\", "
para_end equs "w_text \"[换段F9]\""
text_end equs ""

ENDC ; MACROS_INC
