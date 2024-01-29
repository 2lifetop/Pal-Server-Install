# 🎮 Pal-Server-Install

这是一个用于安装和管理 幻兽帕鲁服务端 的脚本。
幻兽帕鲁交流群：156131989 。群内有群友专享的公益服，有疑问也可以进群询问

🔗 **教程地址**：
[https://www.xuehaiwu.com/palworld-server/](https://www.xuehaiwu.com/palworld-server/)

🛠️ **在线生成服务器配置**：
[https://www.xuehaiwu.com/Pal/](https://www.xuehaiwu.com/Pal/)

## 📝 更新日志：

### **2024.01.29**

- 🚀 脚本更新至0.1.7版本。
- 🔄 新增定时备份`add_backup`功能，提高了数据的安全性和防丢失能力。
- 🛠️ 新增了`check_backup_script`，`check_restart_script`函数，用于在增加定时备份任务前检查备份脚本是否存在，提高了脚本的稳定性和可靠性。


### **2024.01.28** 
>>>>>>> 48c63f257622eaf57d01f4108b60e690ba39acf6

- 🚀 脚本更新至0.1.6版本。

- 📝 重构了`add_restart`函数，现在定时重启的任务会将其输出记录到名为 `crontab.log` 的日志文件中，提高了日志的可读性和可追踪性。
- 🔄 优化了定时任务的添加方式，新的 cron 任务会覆盖旧的 cron 任务，而不是添加到其后面，使任务管理更加清晰。
- 🛠️ 对脚本进行了一些微调，以确保 `restart.sh` 位于当前工作目录下，并且有权限在该目录下创建和删除文件。
- 📝 待完善：计划对用户输入进行更严格的检查和处理，以防止非法输入导致的问题，提高脚本的健壮性。

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
