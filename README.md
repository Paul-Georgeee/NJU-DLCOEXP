# 南京大学2021秋数字电路与计算机组成原理实验

硬件方面实现了RISCV32I的单周期CPU，以及连接了键盘、屏幕、数码管、灯泡等外设，并且具有两块显存，分别用于显示字符界面和图形界面

软件方面移植了南京大学教学项目[Abstract Machine](https://github.com/NJU-ProjectN/abstract-machine)的IOE和TRM模块以及klib，并移植了南京大学[oslab0](https://github.com/NJU-ProjectN/oslab0-collection)学长编写的打字小游戏和贪吃蛇游戏，并可以成功跑通coremarks和dry两个benchmarks，此外还附带了实现了表达式求值等小功能，上述这些均封装成函数在terminal中键入对应命令即可调用

存储映射如下

```c
	/*
		存储映射
	高12位 	0x000 是指令
			0x001 datamem
			0x002 videomem
			0x0030 0000 从这个地址获取键盘输入 0x0030 0004 修改键盘缓冲队列头指针
			0x0040 0000 从这个地址获取时间的值 单位 秒
			0x0040 0004 从这个地址获取时间的值 单位 毫秒
			0x0040 0008 。。。。。。			   微秒
			0x005 读取开关数据 10 bit
			0x006 LEDR 10 bit
			0x007 数码管 
			0x008 大块显存
			0x0090 0000 控制使用哪块显存
			0x00a0 0000 字符显存当前光标行号 
			0x00a0 0004 字符显存当前光标列号
			0x00a0 0008 起始行寄存器
			0x00b0 0000 LEDR
			0x00c0 0000 SW
	*/
```

文件树如下

```
.
├── 贪吃蛇视频.mp4			#贪吃蛇视频
├── terminal				#软件部分
│   ├── abstract-machine			#am
│   │   ├── LICENSE
│   │   ├── Makefile
│   │   ├── README
│   │   ├── am
│   │   │   ├── Makefile
│   │   │   ├── build			#build文件夹为编译链接生成的文件和库
│   │   │   ├── include			#头文件
│   │   │   │   ├── am.h				
│   │   │   │   ├── amdev.h
│   │   │   │   └── nemu.h
│   │   │   └── src				#源文件
│   │   │       ├── ioe			
│   │   │       │   ├── audio.c			#音频相关的ioe 在本次实验没有实现
│   │   │       │   ├── disk.c			#硬盘相关的ioe 在本次实验没有实现
│   │   │       │   ├── gpu.c			#显存相关
│   │   │       │   ├── input.c			#键盘相关
│   │   │       │   ├── ioe.c			
│   │   │       │   └── timer.c			#时钟相关
│   │   │       ├── start.S			#程序入口
│   │   │       └── trm.c			#trm部分 定义了getchar putch halt等函数
│   │   ├── klib				#c语言库函数
│   │   │   ├── Makefile
│   │   │   ├── build
│   │   │   ├── include
│   │   │   │   ├── klib-macros.h
│   │   │   │   ├── klib.h
│   │   │   │   └── riscv-asm.h
│   │   │   └── src
│   │   │       ├── cpp.c			#c++可能用到的
│   │   │       ├── int64.c			#本次实验没有用到
│   │   │       ├── libgc			#一些乘法除法模函数
│   │   │       │   ├── div.S
│   │   │       │   ├── mulsi3.c
│   │   │       │   ├── udivsi3.c
│   │   │       │   └── umodsi3.c
│   │   │       ├── stdio.c			#标准输入输出
│   │   │       ├── stdlib.c			#常用库函数
│   │   │       └── string.c			#字符串函数
│   │   ├── makefile_			#原AM项目的makefile
│   │   └── scripts				#一些脚本
│   │       ├── dump.mk
│   │       └── linker.ld
│   └── code				#命令行界面实现
│       ├── Makefile
│       ├── build
│       ├── include				#相关头文件 前两个为coremark用到的 handle对应各个命令的函数的声明 legacy为小游戏用到的
│       │   ├── core_portme.h
│       │   ├── coremark.h
│       │   ├── handle.h
│       │   └── legacy.h
│       └── src
│           ├── core_list_join.c			#前六个为coremark
│           ├── core_main.c
│           ├── core_matrix.c
│           ├── core_portme.c
│           ├── core_state.c
│           ├── core_util.c
│           ├── eval.c				#表达式求值
│           ├── handle.c			#比较简单的一些函数
│           ├── main.c				#main函数
│           ├── snakegame.c			#贪吃蛇 变量函数名已被模糊化
│           └── typinggame.c			#打字小游戏
└─── src
    ├── dataram.v				#数据存储器
    ├── dataram_bb.v		
    ├── exp12.v				#顶层模块
    ├── imem.v				#指令存储器
    ├── imem_bb.v
    ├── iomem.v				#外设存储模块
    ├── keyboard.v				#键盘控制模块
    ├── rv32is.v				#实验11的内容 包括控制器alu等模块 接口保持和实验11的头歌上面的一样
    ├── vga_ctrl.v				#vga控制模块
    ├── vmem.v				#图形界面的显存
    └── vmem_bb.v

```

