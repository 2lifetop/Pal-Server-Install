# 🎮 Pal-Server-Install

这是一个用于安装和管理 幻兽帕鲁服务端 的脚本。
幻兽帕鲁交流群：156131989 。群内有群友专享的公益服，有疑问也可以进群询问

🔗 **教程地址**：
[https://www.xuehaiwu.com/palworld-server/](https://www.xuehaiwu.com/palworld-server/)

🛠️ **在线生成服务器配置**：
[https://www.xuehaiwu.com/Pal/](https://www.xuehaiwu.com/Pal/)

## 📝 更新日志：

### **2024.01.27**

- 🛠️ 修复了`check_result`函数的问题，提高了脚本的稳定性和可靠性。
- 🔄 完善了修改服务端配置的逻辑，确保修改后的配置能够立即生效，提升了用户体验。
- ⏰ 修改了定时重启的设置，现在用户可以自定义每隔几个小时重启服务器，增强了脚本的灵活性。
- 📝 待完善：计划增加定时备份存档的功能，并允许用户选择自定义备份存档进行恢复，以提供更安全、更方便的数据管理方式。


### **2024.01.26**

- 🔄 优化了脚本的代码结构，精简了部分重复代码，提高了代码的可读性和可维护性。
- 🎮 为幻兽帕鲁游戏服务端增加了优化补丁，提升了游戏的性能和稳定性。减少内存泄露以及CPU高占用。@[VeroFess](https://github.com/VeroFess/PalWorld-Server-Unoffical-Fix)
- 📂 增加了导入和导出幻兽帕鲁存档及配置的功能，方便用户备份和迁移数据。@[miaowmint](https://github.com/miaowmint/palworld)
- 🚪 新增了退出脚本的功能，使用户能更方便地结束脚本的运行。
- 📋 完善了版本文件的处理，更准确地跟踪和管理脚本和服务器以及补丁的版本信息。

## **2024.01.25**

- 🗑️ 增加删除 swap 功能
- 🕵️ 增加游戏版本号检测
- 🔄 增加脚本版本号检测更新
- 🔧 增加游戏服务端更新

## 🚀 快速开始

在你的服务器上运行以下命令来安装和启动 幻兽帕鲁服务端：

```bash
wget -O PalServerInstall.sh https://mirror.ghproxy.com/https://raw.githubusercontent.com/2lifetop/Pal-Server-Install/main/PalServerInstall.sh && chmod +x PalServerInstall.sh && ./PalServerInstall.sh
```



![](https://image.xuehaiwu.com/2024/01/26/Termius_ZvlU3EAlxb.png)
