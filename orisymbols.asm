org: macro
	if \1 < $4000
		section "org_\1", rom0[\1]
	elif \1 < $8000
	if _NARG >= 2
		section "org_\1_\2", romx[\1], bank[\2]
	else
		section "org_\1", romx[\1], bank[1]
	endc
	elif \1 < $a000
	if _NARG >= 2
		section "org_\1_\2", vram[\1], bank[\2]
	else
		section "org_\1", vram[\1], bank[0]
	endc
	elif \1 < $c000
		section "org_\1", sram[\1]
	elif \1 < $d000
		section "org_\1", wram0[\1]
	elif \1 < $e000
	if _NARG >= 2
		section "org_\1_\2", wramx[\1], bank[\2]
	else
		section "org_\1", wramx[\1], bank[1]
	endc
	elif \1 >= $ff80
		section "org_\1", hram[\1]
	endc
endm

; ROM

	org $03ca
oDisplayChar::

	org $03da
oSendVRAMPre::
	org $041b
oSendVRAMAct::
	org $06f0
; 从 hl 读 bc 长到显存 de
oWriteVRAM::
	org $08d9
; 设显存 hl 起 b * c 区域为 a
oFillVRAMArea::
	org $0956
oSwitchBank::
	org $090c
; hl = [ hl + a * 2 ]
oGetHLJumpTable::
	org $0932
; a = [ hl + a ]
oGetHLIndexTable::
	org $0ba1
oWaitVRAMWriteable::
	
	org $0f2b
; hl <- Clear Addr
; bc <- Clear Size
oClearRam::
	org $0f2c
; hl <- Fill Addr
; bc <- Fill Size
; a  <- Fill value
oFillRam::
	org $139b
oTextBoxInit::
	org $13f9
oCharProcess::

	org $14ff
oCharCtrlF9::
	org $1517
oCharCtrlF1::
	org $1529
oCharCtrlF2::
	org $152d

oTextboxClear::
	org $1539

oCharCtrlF3::
	org $1542
oCharCtrlF4::
	org $1548
oCharCtrlF5::
	org $154d
oCharCtrlF6::
	org $1579
oCharCtrlF7::
	org $157f
oCharCtrlF8::
	org $15f8
oCharCtrlFA::
	org $1602
oCharCtrlFB::
	org $15ab
oCharCtrlFC::
	org $15c1
oCharCtrlFD::
	org $160c
oCharCtrlFF::

	
; VRAM
	org $9c00
ovTextBoxStart::
	org $9c21
ovTextBoxInnerStart::
	org $9c22
ovTextBoxTextStart::
ovTextBoxTextLine1::
	org $9c42
ovTextBoxTextLineb1::
	org $9c62
ovTextBoxTextLine2::
	org $9c82
ovTextBoxTextLineb2::
	org $9ca2
ovTextBoxTextLine3::
	org $9cb3
ovTextBoxInnerEnd::
ovTextBoxTextEnd::
	org $9cd4
ovTextBoxEnd::

; WRAM

	org $c3f8
owRomBank:: db; c3f8

	org $c56b
owTextPointer:: dw ; $c56b
owTextNextMap:: dw ; $c56d
owTextNextNo:: db ; $c56f
owTextC570:: db ; $c570
owTextC571:: db ; $c571
owTextC572:: db ; $c572
owTextC573:: db ; $c573
owTextHeadingMap:: dw ; $c574
owTextC576:: db; $c576
owTextC577:: db; $c577

	org $c6ec
owDisplayTileMark:: db
owDisplayTileMap:: dw
owDisplayTileNo:: db

	org $d20e
; 4 - CGB
owGBType::

