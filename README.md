# KenanQiyandao
《名侦探柯南-奇岩岛秘宝传说》汉化工程

# 编译

## 编译环境

Linux环境，Win10可以使用WSL

## 编译工具

编译使用 `rgbds 0.5.2` 和 `python 3.6+`

```
# 安装rgbds
sudo apt install libpng-dev bison
git clone https://github.com/gbdev/rgbds/
make -C rgbds
sudo make install -C rgbds
```

## 编译ROM

需要一个基础ROM，命名为 `baserom.gbc` ，其md5值应为 `f5325eaf1ecbf7cd6e1e561a3b5d77f7` ，存放到工程根目录。

在工程根目录，执行 `make all` 生成汉化ROM，命名为 `output.gbc` 。

# 修改

目前仅可修改剧情文本，在 `data/text.txt` 。

# 待办

- [x] 死亡
- [x] 重写剧情文本GBC程序，支持完整3行显示
- [x] 重写剧情文本GB程序，支持12*8文字的3行显示
- [ ] 自动检查还不支持的12*8文字，并修订
- [x] 自动导入文本
- [ ] 翻译还未翻译的 `POIN:11B97` 到 `POIN:14F48` 文本（在 `data/text.txt` 中部）
- [ ] 整理文本格式，修订为三行格式
- [ ] 剧情文本 GB Tile 数量溢出检查
- [ ] 剧情文本 控制符检查
- [ ] 菜单文本程序
- [ ] 菜单文本数据
- [ ] 菜单文本翻译
- [x] 在当前 `rgbds` 中支持中文字库
- [x] 自动导入字库
- [ ] 导出图像
- [ ] 汉化图像
- [ ] 自动导入图像
