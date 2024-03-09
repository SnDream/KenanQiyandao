IF !DEF(CONSTANTS_INC)
DEF CONSTANTS_INC EQU 1

charmap "<CF1>", $f1
charmap "<ENC>", $f2 ; 结束文本并清屏
charmap "<SUP>", $f3 ; 文本加速
charmap "<CF4>", $f4
charmap "<END>", $f5 ; 结束文本
charmap "<DLN>", $f6 ; 当前位置直接下一行
charmap "<PAU>", $f7 ; 停顿
charmap "<OP2>", $f8 ; 双选择
charmap "<PAC>", $f9 ; 停顿后清屏
charmap "<CFA>", $fa
charmap "<AAA>", $fb ; 快速显示 啊啊啊啊
charmap "<OP3>", $fc ; 三选择
charmap "<OP4>", $fd ; 四选择
charmap "<CHN>", $fe ; 中文符号
charmap "<LIN>", $ff ; 换行


DEF TEXT_BOX_W			EQU 20
DEF TEXT_BOX_H			EQU 7
DEF TEXT_BOX_INNER_W	EQU TEXT_BOX_W - 2
DEF TEXT_BOX_INNER_H	EQU TEXT_BOX_H - 2

				rsreset
DEF GB_TYPE_GB0	rb	1
DEF GB_TYPE_GB1	rb	1
DEF GB_TYPE_GB2	rb	1
DEF GB_TYPE_GB3	rb	1
DEF GB_TYPE_CGB	rb	1

DEF FONT_BASE_CGB EQU $4000
DEF FONT_BASE_DMG EQU FONT_BASE_CGB + 18

ENDC ; CONSTANTS_INC
