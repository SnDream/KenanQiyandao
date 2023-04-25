include "include/hardware.inc"
include "include/macros.inc"
include "include/constants.inc"

section "Save Checksum Disable Patch", rom0[$1a42]
	xor a

; section "RAM Clear Patch 1", rom0[$03b0]
; ; ld hl, $de00
; RamClearPatch1:
; 	ld bc, $0100 ; ld bc, $0200
; ; call ClearRam

; section "RAM Clear Patch 2", rom0[$08ba]
; ; ld hl, $de00
; RamClearPatch2:
; 	ld bc, $0100 ; ld bc, $0200
; ; call oClearRam

section "Display Tile Jump Patch", rom0[$0243]
DisplayTileJumpPatch:
	call DisplayTilePatchExtra


section "Display Tile Patch", rom0[$03ca]
DisplayTilePatch:
	jp DisplayTilePatchExtra
	cleartill $03d0
.display


section "Char Process Patch", rom0[$1437]
CharProcessPatch:
	cp a, $f1
	jr c, .jpchar
	; push af
	sub a, $f1
	ld hl, .ctrl_jump_table
	call oGetHLJumpTable
	; pop af
	jp hl
.ctrl_jump_table
	dw oCharCtrlF1
	dw oCharCtrlF2
	dw oCharCtrlF3
	dw oCharCtrlF4
	dw oCharCtrlF5
	dw oCharCtrlF6
	dw oCharCtrlF7
	dw oCharCtrlF8
	dw oCharCtrlF9
	dw oCharCtrlFA
	dw oCharCtrlFB
	dw oCharCtrlFC
	dw oCharCtrlFD
	dw CharProcessPatchExtra
	dw oCharCtrlFF
.cnchar ; clean later (chinese mark)
	ld a, $fe
	jr .jpchar
	cleartill $147d
.jpchar


section "Text Box Clear Patch", rom0[$152d]
TextboxClearPatch:
	jp TextboxClearPatchExtra
	cleartill $1539

section "Extra Home Program", rom0[$33c0]

display_tile_builder: macro ; t l v
	ld [hli], a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hl]
if \3 == 1
	push de
endc
	ld h, d
	ld l, e
	ld de, $0020 - \1 + 1
x = 0
rept \2
x = x + 1
if \1 == 2
	ld [hli], a
	inc a
endc
	ld [hl], a
if x < \2
	add hl, de
	add a, $10 - \1 + 1
endc
endr
if \3 == 1
	pop hl
	ld a, 1
	ldh [rVBK], a
x = 0
rept \2
x = x + 1
if \1 == 2
	set OAMB_BANK1, [hl]
	inc hl
endc
	set OAMB_BANK1, [hl]
if x < \2
	add hl, de
endc
endr
	xor a
	ldh [rVBK], a
	ret 
endc

endm

DisplayTilePatchExtra:
	ld hl, owDisplayTileMark
	ld a, [hl]
	or a
	ret z
	dec a ; 1
	jp z, DisplayTilePatch.display
	dec a ; 2
	jr z, .t2l3v1
	dec a ; 3
	jr z, .t2l2v1
	dec a ; 4
	jr z, .t1l3v1
	dec a ; 5
	jp z, .t1l2v1
	; 6
.t2l1v0
	display_tile_builder 2, 1, 0
.t2l3v1
	display_tile_builder 2, 3, 1
.t2l2v1
	display_tile_builder 2, 2, 1
.t1l3v1
	display_tile_builder 1, 3, 1
.t1l2v1
	display_tile_builder 1, 2, 1

ClearVRAM:
	ld d, 0
FillVRAM:
.loop
	call oWaitVRAMWriteable
	ld [hl], d
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

TextboxClearPatchExtra:
	ld hl, ovTextBoxInnerStart
	lb bc, TEXT_BOX_INNER_W, TEXT_BOX_INNER_H
	ld a, $7f ; space
	call oFillVRAMArea
	ld a, [owGBType]
	cp a, GB_TYPE_CGB
	ret nz
	ld hl, ovTextBoxInnerStart
	lb bc, TEXT_BOX_INNER_W, TEXT_BOX_INNER_H
	ld a, 1
	ldh [rVBK], a
	xor a
	call oFillVRAMArea
	ld hl, $9100
	ld bc, $0100
	call ClearVRAM
	ld hl, $9300
	ld bc, $0100
	call ClearVRAM
	xor a
	ldh [rVBK], a
	ld [wDFSCombine], a
	ret

CharProcessPatchExtra:
	ld a, [owTextPointer]
	ld l, a
	ld a, [owTextPointer+1]
	ld h, a
	ld a, [hli]
	ld [wDFSCode], a
	ld a, [hli]
	ld [wDFSCode+1], a
	ld a, l
	ld [owTextPointer], a
	ld a, h
	ld [owTextPointer+1], a

	ld a, [owGBType]
	cp a, GB_TYPE_CGB
	jp nz, CharProcessDMG

CharProcessCGB:
	ld a, [owTextNextMap+1]
	cp a, HIGH(ovTextBoxStart)
	ret nz
	ld a, [owTextNextMap]
	cp a, LOW(ovTextBoxEnd)
	ret nc
	ld hl, wDFSCombine
	cp a, [hl]
	jr z, .combine
	call NewFont2bppCGB
	ld a, [owTextNextMap]
	cp a, LOW(ovTextBoxTextLine1)
	ret c
	cp a, LOW(ovTextBoxTextLine2)
	jr c, .line1
	cp a, LOW(ovTextBoxTextLine3)
	jr c, .line2
	jr .line3
.combine
	call CombineFont2bppCGB
	ld a, [owTextNextMap]
	cp a, LOW(ovTextBoxTextLine1)
	ret c
	cp a, LOW(ovTextBoxTextLine2)
	jr c, .line1c
	cp a, LOW(ovTextBoxTextLine3)
	jr c, .line2c
	jr .line3c
	
.line1
	; 写入两行
	sub a, LOW(ovTextBoxTextLine1)
	ld [wDFSTile], a
	ld b, a
	ld c, 4
	ld hl, .table_dst_offset_l1
	ld de, .table_src_l1
	call CharTile2VramCGB
	ld a, 3
	ld bc, $0000
	jr .writemap
.line2
	sub a, LOW(ovTextBoxTextLine2) - $10
	ld [wDFSTile], a
	ld b, a
	ld c, 6
	ld hl, .table_dst_offset_l2
	ld de, .table_src_l2
	call CharTile2VramCGB
	ld a, 2
	ld bc, -$0020
	jr .writemap
.line3
	sub a, LOW(ovTextBoxTextLine3) - $30
	ld [wDFSTile], a
	ld b, a
	ld c, 4
	ld hl, .table_dst_offset_l3
	ld de, .table_src_l3
	call CharTile2VramCGB
	ld a, 3
	ld bc, -$0020
	jr .writemap

.line1c
	; 写入两行
	sub a, LOW(ovTextBoxTextLine1)
	ld [wDFSTile], a
	ld b, a
	dec b
	ld c, 4
	ld hl, .table_dst_offset_l1
	ld de, .table_src_l1c
	call CharTile2VramCGB
	ld a, 5
	ld bc, $0000
	jr .writemapc
.line2c
	sub a, LOW(ovTextBoxTextLine2) - $10
	ld [wDFSTile], a
	ld b, a
	dec b
	ld c, 6
	ld hl, .table_dst_offset_l2
	ld de, .table_src_l2c
	call CharTile2VramCGB
	ld a, 4
	ld bc, -$0020
	jr .writemapc
.line3c
	sub a, LOW(ovTextBoxTextLine3) - $30
	ld [wDFSTile], a
	ld b, a
	dec b
	ld c, 4
	ld hl, .table_dst_offset_l3
	ld de, .table_src_l3c
	call CharTile2VramCGB
	ld a, 5
	ld bc, -$0020
	jr .writemapc

.writemap
	push af
	ld a, [owTextNextMap]
	ld l ,a
	ld a, [owTextNextMap+1]
	ld h, a
	push hl
	add hl, bc
	ld a, l
	ld [owDisplayTileMap], a
	ld a, h
	ld [owDisplayTileMap+1], a
	ld a, [wDFSTile]
	ld [owDisplayTileNo], a
	pop hl
	pop af
	ld [owDisplayTileMark], a
	ld a, [owTextC576]
	or a
	ret nz
	inc hl
	inc hl
	ld a, l
	ld [owTextNextMap], a
	ld [wDFSCombine], a
	ld a, h
	ld [owTextNextMap+1], a
	ret

.writemapc
	push af
	ld a, [owTextNextMap]
	ld l ,a
	ld a, [owTextNextMap+1]
	ld h, a
	push hl
	add hl, bc
	ld a, l
	ld [owDisplayTileMap], a
	ld a, h
	ld [owDisplayTileMap+1], a
	ld a, [wDFSTile]
	ld [owDisplayTileNo], a
	pop hl
	pop af
	ld [owDisplayTileMark], a
	ld a, [owTextC576]
	or a
	ret nz
	inc hl
	ld a, l
	ld [owTextNextMap], a
	ld a, h
	ld [owTextNextMap+1], a
	xor a
	ld [wDFSCombine], a
	ret

.table_dst_offset_l1
	db $00, $00, $00, $00
.table_dst_offset_l2
	db $0C, $0C, $00, $00, $00, $00
.table_dst_offset_l3
	db $08, $08, $00, $00
.table_src_l1
	dw wDFS8Font1
	dw wDFS8Font3
	dw wDFS8Font2
	dw wDFS8Font4
.table_src_l1c
	dw wDFS8Font3
	dw wDFS8Font1
	dw wDFS8Font4
	dw wDFS8Font2
.table_src_l2
	dw wDFS8Font1
	dw wDFS8Font3
	dw wDFS8Font1+4
	dw wDFS8Font3+4
	dw wDFS8Font2+4
	dw wDFS8Font4+4
.table_src_l2c
	dw wDFS8Font3
	dw wDFS8Font1
	dw wDFS8Font3+4
	dw wDFS8Font1+4
	dw wDFS8Font4+4
	dw wDFS8Font2+4
.table_src_l3
	dw wDFS8Font1
	dw wDFS8Font3
	dw wDFS8Font1+8
	dw wDFS8Font3+8
.table_src_l3c
	dw wDFS8Font3
	dw wDFS8Font1
	dw wDFS8Font3+8
	dw wDFS8Font1+8

; b -> 起始Tile
; c -> 循环次数
; de -> Tile来源表
; hl -> Tile目标偏移表
CharTile2VramCGB:
	ld a, 1
	ldh [rVBK], a
	ld a, c
	ld c, 0
.loop
	push af
	push hl
	push de
	push bc

	ld a, c
	push de
	push hl
	ld hl, .table_step
	call oGetHLIndexTable
	add a, b
	call Map2FontTileAddr
	pop hl
	ld a, c
	call oGetHLIndexTable
	ld b, a
	or a, e
	ld e, a
	pop hl
	ld a, c
	call oGetHLJumpTable
	ld a, $10
	sub b
	ld c, a
	ld b, 0
	call oWriteVRAM

	pop bc
	pop de
	pop hl
	pop af
	inc c
	cp a, c
	jr nz, .loop
	xor a
	ldh [rVBK], a
	ret

.table_step
	db $00, $01, $10, $11, $20, $21

Map2FontTileAddr:
	swap a
	ld d, a
	and a, $f0
	ld e, a
	ld a, d
	and a, $0f
	or a, $90
	ld d, a
	ret

Code2FontROMAddr:
	ld l, a
	ld h, 0
	add hl, hl ; x2
	add hl, hl ; x4
	add hl, hl ; x8
	add hl, hl ; x16
	add hl, hl ; x32
	add hl, de
	ld d, h
	ld e, l
	ret

NewFont2bppCGB:
	ld a, [wDFSCode+1]
	ld de, FONT_BASE_CGB
	call Code2FontROMAddr
	ld a, [owRomBank]
	push af
	ld a, [wDFSCode]
	call oSwitchBank
	ld b, 6
	ld hl, wDFS8Font1
	call GetFont2bppLeft4px
	ld b, 6
	ld hl, wDFS8Font1
	call GetFont2bppRight4px
	ld b, 6
	ld hl, wDFS8Font3
	call GetFont2bppLeft4px
	pop af
	call oSwitchBank
	ret 

CombineFont2bppCGB:
	ld a, [wDFSCode+1]
	ld de, FONT_BASE_CGB
	call Code2FontROMAddr
	ld a, [owRomBank]
	push af
	ld a, [wDFSCode]
	call oSwitchBank
	ld b, 6
	ld hl, wDFS8Font3
	call GetFont2bppRight4px
	ld b, 6
	ld hl, wDFS8Font1
	call GetFont2bppLeft4px
	ld b, 6
	ld hl, wDFS8Font1
	call GetFont2bppRight4px
	pop af
	call oSwitchBank
	ret

;de:来源 hl:解压目标
GetFont2bppLeft4px:
.loop
	ld a, [de]
	and $F0
	ld [hli], a
	ld [hli], a
	ld a, [de]
	swap a
	and $F0
	ld [hli], a
	ld [hli], a
	inc de
	dec b
	jr nz, .loop
; 	ld b, 8
; 	xor a
; .loop2
; 	ld [hli], a
; 	dec b
; 	jr nz, .loop2
	ret

;de:来源 hl:解压目标
GetFont2bppRight4px:
.loop
	ld a, [de]
	swap a
	and $0F
	or [hl]
	ld [hli], a
	ld [hli], a
	ld a, [de]
	and $0F
	or [hl]
	ld [hli], a
	ld [hli], a
	inc de
	dec b
	jr nz, .loop
	ret

CharProcessDMG:
	ld a, [owTextNextMap]
	ld hl, wDFSCombine
	cp a, [hl]
	jr z, .combine
	call NewFont2bppDMG
	ld a, [owTextNextNo]
	add a, $50
	call Map2FontTileAddr
	ld bc, $0020
	ld hl, wDFS8Font1
	call oWriteVRAM
	ld a, [owTextNextMap]
	ld l, a
	ld a, [owTextNextMap+1]
	ld h, a
	ld a, [owTextNextNo]
	add a, $50
	ld b, a
	ld a, l
	ld [owDisplayTileMap], a
	ld a, h
	ld [owDisplayTileMap+1], a
	ld a, b
	ld [owDisplayTileNo], a
	ld a, 6
	ld [owDisplayTileMark], a
	ld a, [owTextC576]
	or a
	ret nz
	ld a, [owTextNextNo]
	add a, 2
	ld [owTextNextNo], a
	inc hl
	inc hl
	ld a, l
	ld [owTextNextMap], a
	ld [wDFSCombine], a
	ld a, h
	ld [owTextNextMap+1], a
	ret
.combine
	call CombineFont2bppDMG
	ld a, [owTextNextNo]
	add a, $50 - 1
	call Map2FontTileAddr
	ld bc, $0020
	ld hl, wDFS8Font2
	call oWriteVRAM
	ld a, [owTextNextMap]
	ld l, a
	ld a, [owTextNextMap+1]
	ld h, a
	ld a, [owTextNextNo]
	add a, $50
	ld b, a
	ld a, l
	ld [owDisplayTileMap], a
	ld a, h
	ld [owDisplayTileMap+1], a
	ld a, b
	ld [owDisplayTileNo], a
	ld a, 1
	ld [owDisplayTileMark], a
	ld a, [owTextC576]
	or a
	ret nz
	ld a, [owTextNextNo]
	inc a
	ld [owTextNextNo], a
	inc hl
	ld a, l
	ld [owTextNextMap], a
	ld a, h
	ld [owTextNextMap+1], a
	xor a
	ld [wDFSCombine], a
	ret


NewFont2bppDMG:
	ld a, [wDFSCode+1]
	ld de, FONT_BASE_DMG
	call Code2FontROMAddr
	ld a, [owRomBank]
	push af
	ld a, [wDFSCode]
	call oSwitchBank
	ld b, 4
	ld hl, wDFS8Font1
	call GetFont2bppLeft4px
	ld b, 4
	ld hl, wDFS8Font1
	call GetFont2bppRight4px
	ld b, 4
	; ld hl, wDFS8Font2
	call GetFont2bppLeft4px
	pop af
	call oSwitchBank
	ret 

CombineFont2bppDMG:
	ld a, [wDFSCode+1]
	ld de, FONT_BASE_DMG
	call Code2FontROMAddr
	ld a, [owRomBank]
	push af
	ld a, [wDFSCode]
	call oSwitchBank
	ld b, 4
	ld hl, wDFS8Font2
	call GetFont2bppRight4px
	ld b, 4
	ld hl, wDFS8Font2+16
	call GetFont2bppLeft4px
	ld b, 4
	ld hl, wDFS8Font2+16
	call GetFont2bppRight4px
	pop af
	call oSwitchBank
	ret

db $FF
