# 懒得数key让电脑去数

###### 用MATLAB读取扒拉Portal Key的录屏视频文件来数各Key的数量

## 前言

本咸鱼的特长就是乱放key，且懒得打理，所以经常出现以下尴尬局面：

- 卧槽，这桶里咋没有？！难道是下个桶？卧槽，怎么也没有？！
- 卧槽，我怎么囤了这么多这个坡的key？！
- 这是最后一把，……了……吗？

一堆桶里扒拉着数key好痛苦。索性开个脑洞，交给电脑数去。不曾想，这不是脑洞是深坑啊。而且还忘记了马上就Prime了，哭丧脸。

## 脑洞

把扒拉key的操作录屏，视频文件喂给MATLAB，OCR识别完输出坡名和数量，打完收工！

## 别看脑洞这么骨感，其实深坑特别丰满

受限于技术水平，这活真不好干。憋了好久憋出个满是bug的脚本，索性凑合能用了。

### 脚本逻辑和操作流程

#### 依赖

- 脚本只在 WIN 下测试过。
- MATLAB Computer Vision System Toolbox：用来调用```ocr```命令，识别英文、数字；
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract/wiki)：命令行式的OCR，需另装，配置好简繁字库，用来识别简繁中文。

#### 录屏

- Inventory里的key，如果只有1把的话，是不会显示数量的，即没有“x1”；桶里的则会显示，而且在桶里点load，则会显示Inventory里的key，而且有“x1”。所以推荐录屏时不直接录Inventory里翻key的过程，而是找个桶，点load再录。当然，录Inventory里的也可以，脚本也能处理。
- 翻key一定要从头翻到底，比如从左翻到右，或从右翻到左，翻快点都可以的。现在的脚本没考虑来回翻的情况，会数错。
- 一个桶翻完换另一个桶时的切换过程，没关系，要相信脚本能识别这个过程（看人品）。当然你也可以每个桶录一个，分别丢给脚本去数。

#### 预设

- 有了MP4，先在MATLAB里 ```implay``` 一下。有时候录屏会录进去一些开始录屏或终止录屏的菜单按钮，所以要掐头去尾。不用编辑视频，找到可供OCR识别的帧数范围就行，在脚本里填好。脚本也是逐帧做循环处理的。

![key区域识别](https://github.com/chouj/CountIngressKeys/blob/master/images/rectangledetected.jpg =200x)

- 每帧图像在OCR之前，先识别该帧图像里倒数第二大的矩形框（最大那个就是图像本身这个矩形），然后根据这个矩形框的长宽比判断是不是key图（如上）。问题来了，不同手机这个长宽比是不一样的。脚本里预设了iPhone 6和Moto G 2nd Gen的。欢迎补充。

#### 运行

- 裁切出key图后，再切出上部的数量区域和下部的坡名区域分别 OCR。

![Key Number Region](https://github.com/chouj/CountIngressKeys/blob/master/images/keynumberregion.jpg =200x)

![Key Name Region](https://github.com/chouj/CountIngressKeys/blob/master/images/portalnameregion.jpg =200x)

- Tesseract OCR识别一次比较慢，外加一次读写。如果每帧都要OCR就太慢了，况且大部分时候前后相邻帧都是同一个画面。所以用前后相邻key图的坡名区域做互相关，互相关系数在0.75以上的认为是同一个坡名，不做OCR，跳到下一循环。
- 坡key数量识别成功率有限，某些识别不出的场合，输出图像人肉判断后输入数字。
- 坡名的识别成功率就更低了，各种乱码。比如，经常把“院”识别成“脘”，无力吐槽。做了清理之后，停留在一眼能看出是哪个坡的水准。
- 如果循环处理完每一帧后，得到的坡名数组里相邻的两个坡名是一样的，就干掉一个，应该是在相关系数筛选那里漏网了。
- 最后查找坡名数组里同名的坡，把对应的key数相加得到该坡的合计key数量。比如桶里有2条这个坡的key，仓库里有1条，所以相加得到总共有3条。

![Key Counting Result Sample](https://github.com/chouj/CountIngressKeys/blob/master/images/CountingResultSample.png =200x)

- 结果写去EXCEL文件，方便根据key数量排序神马的。

### 已知问题

- 每个城市里都有好多个“小象”、“石狮”这种同名坡，脚本会把他们全加起来。理论上可以把坡名识别区域扩大到坡名及其下面一行的地址识别，这样就多一个判据可以对同名坡加以区分，但我懒癌直犯。。直犯。。
- 翻key录屏不要来回往复翻。

## 后记

放出这个用吃奶的劲儿编出来的0.2成品就是期待能被技术大佬打脸。

## 致谢

- [Detecting rectangle shape in an image](https://www.mathworks.com/matlabcentral/answers/35243-detecting-rectangle-shape-in-an-image)
