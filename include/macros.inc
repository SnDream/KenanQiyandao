IF !DEF(MACROS_INC)
DEF MACROS_INC EQU 1

cleartill: macro
	rept \1 - @
		nop
	endr
endm

lb: macro ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 | ((\3) & $ff)
endm

dbw: macro
	db \1
	dw \2
endm

dba: macro
	db BANK(\1)
	dw \1
endm

text equs "w_text"
line equs "w_text \"[换行FF]\", "
para_end equs "w_text \"[换段F9]\""
text_end equs ""

ENDC ; MACROS_INC
