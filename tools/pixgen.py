#!/usr/bin/env python3

pixgbdata = {}
pixgbdata12x8 = {}
trdata = {}

with open('./data/font-12x12.dat', 'rb') as df:
	with open('./data/font.tbl', 'r') as f:
		for line in f:
			tmp = list(df.read(18))
			raw_data = []
			for i in range(12):
				raw_data.append([])
				for j in range(12):
					offset = i * 12 + j
					raw_data[i].append( (tmp[offset // 8] >> (7 - (offset % 8))) & 1 )
			pixgbdata[line[5]] = raw_data

with open('./data/font-12x8.dat', 'rb') as df:
	with open('./data/font.tbl', 'r') as f:
		for line in f:
			tmp = list(df.read(18))
			raw_data = []
			for i in range(12):
				raw_data.append([])
				for j in range(12):
					offset = i * 12 + j
					raw_data[i].append( (tmp[offset // 8] >> (7 - (offset % 8))) & 1 )
			pixgbdata12x8[line[5]] = raw_data

with open('./autogen/text.tbl') as f:
	for line in f:
		trdata[int(line[:4], 16)] = line[5]

def trans(raw_pix, raw_pix12x8):
	raw_trans = []
	count = 0
	tmp = 0
	for i in range(3):
		for j in range(12):
			for k in range(4):
				tmp = tmp << 1
				tmp |= raw_pix[j][i * 4 + k] & 1
				count += 1
				if count == 8:
					raw_trans.append(tmp)
					count = 0
					tmp = 0
	for i in range(3):
		for j in range(8):
			for k in range(4):
				tmp = tmp << 1
				tmp |= raw_pix12x8[j][i * 4 + k] & 1
				count += 1
				if count == 8:
					raw_trans.append(tmp)
					count = 0
					tmp = 0
	raw_trans.append(0)
	raw_trans.append(0)
	return bytes(raw_trans)

end = False

alpix = b''

font_asm = [

]

for codeh in range(min(trdata) >> 8, (max(trdata) >> 8) + 1):
	tmp = b''
	for codel in range(0, 0x100):
		code = codeh * 0x100 + codel
		try:
			pixdata = pixgbdata[trdata[code]]
			pixdata12x8 = pixgbdata12x8[trdata[code]]
		except:
			print("Unknown char", trdata[code])
			pixdata = pixgbdata['　']
			pixdata12x8 = pixgbdata12x8['　']
		if not end:
			tmp += trans(pixdata, pixdata12x8)
		if (code) == max(trdata):
			break
	font_file = './autogen/font_' + "%02X"%(codeh) + '.bin'
	with open(font_file, 'wb') as f:
		f.write(tmp)
	font_asm.append("section \"Font %02x\", romx[$4000], bank[$%x]\n"%(codeh, codeh))
	font_asm.append("\tincbin \"%s\"\n\n"%font_file)
	alpix += tmp

with open('./autogen/allpix.bin', 'wb') as f:
	f.write(alpix)

with open('./autogen/font.asm', 'w') as f:
	f.writelines(font_asm)
