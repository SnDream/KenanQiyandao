IF !DEF(W_CHARMAP_INC)
DEF W_CHARMAP_INC EQU 1

MACRO w_init
def W_PLANE_MAX = \1
newcharmap w_length
for i, 0, \1
	newcharmap w_plane_{d:i}
endr
setcharmap w_plane_0
endm

MACRO w_charmap
if _NARG >= 2 && _NARG < W_PLANE_MAX + 2
	setcharmap w_length
	charmap \1, _NARG - 1
	for i, 0, W_PLANE_MAX
		setcharmap w_plane_{d:i}
		if i < _NARG - 1
			def j = i + 2
			charmap \1, \<{d:j}>
		else
			charmap \1, 0
		endc
	endr
	setcharmap w_plane_0
else
	warn "Define w_char failed."
endc
endm

MACRO w_text
rept _NARG
	setcharmap w_length
	for i, 1, charlen(\1) + 1
		setcharmap w_length
		def j = charsub(\1, i)
		if j <= W_PLANE_MAX
			for k, 0, j
				setcharmap w_plane_{d:k}
				db charsub(\1, i)
			endr
		else
			warn strcat("Get w_char failed: ", charsub(\1, i))
		endc
	endr
	shift
endr
setcharmap w_plane_0
endm

ENDC ; W_CHARMAP_INC
