# 懒得数key让电脑去数

###### 用MATLAB读取扒拉Portal Key的录屏视频文件来数各坡Key的数量

## 前言

本咸鱼的特长就是乱放key，且懒得打理，所以经常出现以下尴尬局面：

- 咦？link不上？翻桶。卧槽，这桶里咋没有？！难道是下个桶？卧槽，怎么也没有？！
- 卧槽，我怎么囤了这么多这个坡的key？！
- 这是最后一把，……了……吗？

一堆桶里扒拉着数key找key好痛苦。索性开个脑洞，交给电脑数去。不曾想，这不是脑洞是深坑啊。而且还忘记了马上就Prime了，哭丧脸。

## 脑洞

把扒拉key的操作录屏，视频文件喂给MATLAB，OCR识别完输出坡名和数量。打完收工！

## 别看脑洞这么骨感，其实深坑特别丰满

受限于技术水平，这活真不好干。憋了好久憋出个满是bug的脚本，索性凑合能用了。

### 脚本逻辑和操作流程

#### 文件说明

- ```CountIngressKeys_V1.m``` 数Key脚本；
- ```RectAspectRatio.m```     输出每帧图像中最大矩形框的高宽比，并绘图的函数。

#### 依赖

- 脚本只在 WIN 下测试过。其他系统按道理也可以。
- MATLAB Computer Vision System Toolbox：用来调用该工具箱的```ocr```命令，识别英文、数字。其实换下面这个Tesseract OCR做识别也成，并不必须，但现在脚本里还是有用```ocr```。
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract/wiki)：命令行式的OCR，需另装，配置好简繁字库，用来识别简繁中文。装配过程可以[放狗搜](https://www.google.com/search?q=tesseract+%E9%85%8D%E7%BD%AE)，很多教程。

#### 录屏

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/InventoryKeyAndLoadKeyIntoCapsule.jpg" width="400"></img>

- Inventory里的key，如果只有1把的话，是不会显示数量的，即没有“x1”；桶里的则会显示，而且在桶里点load，则会显示Inventory里的key，而且有“x1”（上图）。所以推荐录屏时不直接录Inventory里翻key的过程，而是找个桶，点load再录。当然，录Inventory里的也可以，脚本也能处理。

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/key-rolling.gif" width="200"></img>

- 翻key一定要从头翻到底，比如从左翻到右，或从右翻到左，翻快点都可以的（如上）。现在的脚本没考虑来回翻的情况，会数错。
- 一个桶翻完换另一个桶时的切换过程，没关系，要相信脚本能识别这个过程（看人品）。当然你也可以每个桶录一个，分别丢给脚本去数。

#### 预设

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/ImplayInterface.png" width="200"></img>

- 有了MP4，先在MATLAB里 ```implay(文件路径)``` 一下（上图）。红色矩形框里是控制按钮，右下角是当前第几帧和总帧数。有时候录屏会录进去一些开始录屏或终止录屏的菜单按钮(下图)，所以要掐头去尾。不用编辑视频，找到可供OCR识别的帧数范围就行，在脚本里填好。脚本也是逐帧做循环处理的。

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/ScreenRecordingProblem.gif" width="200"></img>

- 每帧图像在OCR之前，先识别该帧图像里最大的矩形框。如果这帧图像是滑动key的视频里的一帧，这个最大矩形框就一定是可滚动的key图这部分（下图红色虚线）。

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/rectangledetected.jpg" width="200"></img>

- 而且，该矩形框的高宽比浮动不大（下图），所以可根据这个矩形框的高宽比判断是不是key图。可以先运行一下```r=RectAspectRatio(文件路径);```输出高宽比的序列来看一下key图对应的高宽比大致为多少，然后在脚本```CountIngressKeys_V1.m```参数区域里填入上限和下限。从下图可以看出，桶界面和翻桶时所识别出来的最大矩形高宽比和桶里key图的高宽比差很远，这也是为什么从一个桶翻key切换另一个桶的过程可以被排除。不过，问题来了，不同手机这个高宽比是不一样的。脚本里预设了iPhone 6和Moto G 2nd Gen的（我们没有钱.jpg）。欢迎补充。

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/aspectratio-vs-frame.jpg" width="600"></img>

- 下图即脚本```CountIngressKeys_V1.m```里的参数设置区域，改好运行脚本即可，人品好的话能一直run到底。

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/Parameters.png" width="500"></img>

#### 运行

脚本执行时不用管，这里只简单说下逻辑：

- 裁切出key图后，再切出上部的数量区域和下部的坡名区域分别 OCR。

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/keynumberregion.jpg" width="200"></img>

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/portalnameregion.jpg" width="200"></img>

- Tesseract OCR识别一次比较慢，外加一次读写。如果每帧都要OCR就太慢了，况且大部分时候前后相邻帧都是同一个画面。所以用前后相邻key图的坡名区域做互相关，互相关系数在0.75以上的认为是同一个坡名，不做OCR，跳到下一循环。
- 坡key数量识别成功率有限，某些识别不出的场合，输出图像人肉判断后输入数字。
- 坡名的识别成功率就更低了，各种乱码。比如，经常把“院”识别成“脘”，无力吐槽。做了清理之后，停留在一眼能看出是哪个坡的水准。
- 如果循环处理完每一帧后，得到的坡名数组里相邻的两个坡名是一样的，就干掉一个，应该是在相关系数筛选那里漏网了。
- 最后查找坡名数组里同名的坡，把对应的key数相加得到该坡的合计key数量。比如桶里有2条这个坡的key，仓库里有1条，所以相加得到总共有3条。

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/CountingResultSample.png" width="200"></img>

- 结果写去EXCEL文件，方便根据key数量排序神马的。输出的前两列是根据OCR识别顺序也就是录屏视频的时间顺序排列的坡名和数量，后两列则是根据坡名文字排序的。有后两列的好处是，有识别差错的时候，可以一眼发现同一个坡被识别成了俩坡名：

<img src="https://github.com/chouj/CountIngressKeys/blob/master/images/EXCELsample.png" width="400"></img>

### 已知问题

- 每个城市里都有好多个“小象”、“石狮”这种同名坡，脚本会把他们全加起来。理论上可以把坡名识别区域扩大到坡名及其下面一行的地址识别，这样就多一个判据可以对同名坡加以区分，但我懒癌直犯。。直犯。。
- 翻key录屏不要来回往复翻。
- 玄学属性爆棚。

## 后记

- 放出这个用吃奶的劲儿编出来的0.2成品就是期待能被技术大佬打脸。
- 神马？你说数得对不对？不管你信不信，我反正是信了！
- 其他脑洞：桶里的数一遍，Inventory里的数一遍，两边一match，看看有哪些key该从桶里搬出来link用了。嗯。这个。再说吧。


## 致谢

- [Detecting rectangle shape in an image](https://www.mathworks.com/matlabcentral/answers/35243-detecting-rectangle-shape-in-an-image)
- [Matlab 读入txt 中文乱码](https://blog.csdn.net/ada444845016/article/details/9344817)
- [matlab：把cell中的某个元素删去](https://blog.csdn.net/durpur/article/details/49975413)

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/Mesoscale)
[![Donate](https://img.shields.io/badge/Donate-WeChat-brightgreen.svg)](https://github.com/chouj/donate-page/blob/master/simple/images/WeChatQR.jpg?raw=true)
[![Donate](https://img.shields.io/badge/Donate-AliPay-blue.svg)](https://github.com/chouj/donate-page/blob/master/simple/images/AlipayQR.jpg?raw=true)
