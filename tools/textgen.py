#!/usr/bin/env python3
# -*- coding: utf-8 -*-

jpnmap = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅぇぉゃゅょっがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォャュョッガギグゲゴザジズぜゾダヂヅデドバビブベボパピプペポ０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ－。、•？！．＿＇～「」『』（）＜＞《》○×△●♥／♪★↑↓→←月日时分：∷'

chn_p0_map = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅぇぉゃゅょっがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォャュョッガギグゲゴザジズぜゾダヂヅデドバビブベボパピプペポ0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ◩◩◩•◩◩◩◩◩◩◩◩◩◩◩◩◩◩◩◩○×△●♥◩♪★'

ndrombank=0x60
ndramaddr=0x4000
ndaddrdict={}
ndbankdict={}

charbank = 0x4F
chardatalen = 0x4000

ntbank = 0x60
ntaddr = 0x4000
ntdict = {}

exist = {}

chn_tbl_r = 0x4000
chartbl = {}

for i in range(len(chn_p0_map)):
	if chn_p0_map[i] != '◩':
		chartbl[chn_p0_map[i]] = [i]
chartbl[" "] = [0xef]
chartbl["　"] = [0xef]
chartbl["[控制F1]"] = [0xf1]
chartbl["[结束F2]"] = [0xf2]
chartbl["[加速F3]"] = [0xf3]
chartbl["[控制F4]"] = [0xf4]
chartbl["[结束F5]"] = [0xf5]
chartbl["[下行F6]"] = [0xf6]
chartbl["[停顿F7]"] = [0xf7]
chartbl["[双选F8]"] = [0xf8]
chartbl["[换段F9]"] = [0xf9]
chartbl["[控制FA]"] = [0xfa]
chartbl["[字典FB]"] = [0xfb]
chartbl["[三选FC]"] = [0xfc]
chartbl["[四选FD]"] = [0xfd]
chartbl["[换行FF]"] = [0xff]

pointer_asm = [
	"include \"include/macros.inc\"\n",
	"\n",
]

text_asm = [
	"include \"include/macros.inc\"\n",
	"include \"autogen/charmap.inc\"\n",
	"\n",
]

charmap_asm = [
	"include \"include/charmap_w.inc\"\n",
	"\n",
	"\tnewcharmap_w 3\n",
	"\n",
]

text_tbl = [

]

def getromaddr(bank, ramaddr):
	if bank == 0:
		return ramaddr
	else:
		return (ramaddr - 0x4000) + bank * 0x4000

def getramaddr(romaddr):
	if romaddr >= 0x4000:
		return romaddr // 0x4000, romaddr % 0x4000 + 0x4000
	else:
		return 0, romaddr

def gettextlabel(romaddr):
	bank, addr = getramaddr(romaddr)
	return "Text_%02x_%04x"%(bank, addr)

def insert_pointer_asm(poinaddr, dataaddr):
	global pointer_asm
	poinb, poina = getramaddr(poinaddr+1)
	pointer_asm.append("section \"pointer %06X\", romx[$%04x], bank[$%x]\n"%(poinaddr, poina, poinb))
	pointer_asm.append("\tdba %s\n\n"%(gettextlabel(dataaddr)))

def insert_text_asm(asmstr, datalen, dataaddr):
	global chardatalen
	global charbank
	global text_asm
	if (chardatalen + datalen) > 0x3e00:
		charbank += 1
		chardatalen = 0
		text_asm.append("section \"text %04X\", romx[$%04x], bank[$%x]\n"%(charbank, 0x4000, charbank))
	text_asm.append("%s::\n"%(gettextlabel(dataaddr)))
	text_asm.append(asmstr)
	chardatalen += datalen

def sametext(poin, txbank, txaddr):
	global exist
	if getromaddr(txbank, txaddr) in exist:
		insert_pointer_asm(poin, getromaddr(txbank, txaddr))
		exist[getromaddr(txbank, txaddr)] = True
	else:
		print("same text %02X:%04X is not exist"%(txbank, txaddr))

def charmap_gen(str):
	global chn_tbl_r
	global chartbl
	ctrl = 0
	ctrl_str = ''
	count = 0
	for c in str:
		if ctrl:
			ctrl_str += c
			if c == ']':
				ctrl = 0
				count += len(chartbl[ctrl_str])
				continue
		else:
			if c == '[':
				ctrl = 1
				ctrl_str = '['
				continue
			elif c == ']':
				print(str)
				raise Exception("Ctrl error")
			if c not in chartbl:
				chartbl[c] = [0xfe, chn_tbl_r >> 8, chn_tbl_r & 0xff ]
				text_tbl.append("%04X=%s\n"%(chn_tbl_r, c))
				chn_tbl_r += 1
			count += len(chartbl[c])
	if ctrl:
		raise Exception("Ctrl error")
	return count

def textgen(linec, pause):
	text_line = []
	text_datalen = 0
	if len(linec) > 3:
		print("Text is overflowed!", linec)
	for i in range(len(linec)):
		text_str = linec[i].replace("{ED}", "").replace("{", "[").replace("}", "]")
		text_datalen += charmap_gen(text_str)
		if i == 0:
			text_line.append("\ttext \"" + text_str + "\"\n")
		else:
			text_line.append("\tline \"" + text_str + "\"\n")
	if pause:
		text_line.append("\tpara_end\n\n")
	else:
		text_line.append("\ttext_end\n\n")
	text_datalen += 1

	return "".join(text_line), text_datalen

def newtext(asmstr, datalen, poin, txbank, txaddr):
	insert_pointer_asm(poin, getromaddr(txbank, txaddr))
	insert_text_asm(asmstr, datalen, getromaddr(txbank, txaddr))
	if getromaddr(txbank, txaddr) in exist:
		print("same text %02X:%04X is already exist"%(txbank, txaddr))
	else:
		exist[getromaddr(txbank, txaddr)] = True

with open('data/text.txt', 'r') as f:
	text = f.readlines()

state = 0
mark = 0
err = False
for line_raw in text:
	if err:
		raise Exception("unexpect at %d: %s "%(state, line))

	line = line_raw.strip("\n")

	if line == '': mark = 0
	elif line[:5] == 'POIN:': mark = 2
	elif line[:5] == 'BANK:': mark = 3
	elif line[:5] == 'ADDR:': mark = 4
	elif line[:9] == '－原文－－－－－－': mark = 5
	elif line[:9] == '－译文－－－－－－': mark = 6
	elif line[:9] == '－重复文本－－－－': mark = 7
	elif line[:9] == '－备注－－－－－－': mark = 8
	elif line[:9] == '－结束－－－－－－': mark = 9
	else: mark = 1

	if state == 0:
		if mark == 0:
			continue
		elif mark == 2:
			txbank = 0
			txaddr = 0
			linec = []
			asmstr = ''
			datalen = 0
			poin = int(line[5:], 16)
			state = 1
		else:
			err = True
			continue
	elif state == 1:
		if mark == 3:
			txbank = int(line[5:], 16)
			state = 2
		else:
			err = True
			continue
	elif state == 2:
		if mark == 4:
			txaddr = int(line[5:], 16)
			state = 3
		else:
			err = True
			continue
	elif state == 3:
		if mark == 5:
			state = 4
		else:
			err = True
			continue
	elif state == 4:
		if mark <= 1:
			continue
		elif mark == 6:
			state = 5
		elif mark == 7:
			sametext(poin, txbank, txaddr)
			state = 0
		else:
			err = True
			continue
	elif state == 5:
		if mark == 1:
			linec.append(line)
		elif mark == 0:
			if len(linec) > 0:
				asmstr_, datalen_ = textgen(linec, True)
				asmstr += asmstr_
				datalen += datalen_
				linec = []
		elif mark == 8:
			if len(linec) > 0:
				asmstr_, datalen_ = textgen(linec, False)
				asmstr += asmstr_
				datalen += datalen_
				linec = []
			if len(asmstr) > 0:
				romdata = newtext(asmstr, datalen, poin, txbank, txaddr)
			state = 6
		else:
			err = True
			continue
	elif state == 6:
		if mark <= 1:
			continue
		elif mark == 9:
			state = 0
		else:
			err = True
			continue

for key in chartbl:
	charmap_asm.append("\tcharmap_w \"%s\""%key)
	for i in chartbl[key]:
		charmap_asm.append(", $%02x"%i)
	charmap_asm.append("\n")

with open('autogen/pointer.asm', 'w') as f:
	f.writelines(pointer_asm)

with open('autogen/text.asm', 'w') as f:
	f.writelines(text_asm)

with open('autogen/charmap.inc', 'w') as f:
	f.writelines(charmap_asm)

with open('autogen/text.tbl', 'w') as f:
	f.writelines(text_tbl)
