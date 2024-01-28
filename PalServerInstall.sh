#!/bin/bash
# 当前的脚本版本
currentScriptVersion="0.1.5"
# 定义一些颜色和格式
Green="\033[32m"
Font="\033[0m"
Red="\033[31m"

# 检查命令的执行结果
check_result() {
    if [ $? -ne 0 ]; then
        echo -e "${Red}$1 失败${Font}"
        exit 1
    fi
}

# 检查 Docker 容器是否存在
check_docker_container() {
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        return 0
    else
        return 1
    fi
}

# 检查输入是否为数字
check_numeric_input() {
    if  [[ "\$1" =~ ^[0-9]+$ ]]
    then
        echo "请输入正确的数字！"
    fi
}

# 检查 jq 是否已经安装
if ! [ -x "$(command -v jq)" ]; then
    echo 'jq 没有安装，正在尝试安装...'
    sudo apt-get update
    sudo apt-get install -y jq
    check_result "jq 安装"
fi


# 从服务器获取版本信息
versionInfo=$(curl -s https://www.xuehaiwu.com/wp-content/uploads/shell/Pal/version.json)
check_result "获取版本信息"

# 解析JSON以获取最新的版本和下载链接
latestScriptVersion=$(echo $versionInfo | jq -r '.scriptVersion')
latestGameVersion=$(echo $versionInfo | jq -r '.gameVersion')
latestPatchVersion=$(echo $versionInfo | jq -r '.PatchVersion')
downloadLink=$(echo $versionInfo | jq -r '.downloadLink')

if [ ! -f version.json ]; then
    # 如果不存在，则使用从服务器获取的版本信息创建一个新的 version.json 文件
    # 将PatchVersion设置为 "0"
    versionInfo=$(echo $versionInfo | jq '.PatchVersion = "0"')
    echo $versionInfo > version.json
fi


# 比较脚本版本
if [[ $(echo -e "$currentScriptVersion\n$latestScriptVersion" | sort -V | head -n 1) != $latestScriptVersion ]]; then
    echo "新的脚本版本可用，你的版本为 $currentScriptVersion，最新版本为 $latestScriptVersion。正在下载新版本..."
    # 下载新版本的脚本
    curl -O https://www.xuehaiwu.com/wp-content/uploads/shell/Pal/PalServerInstall.sh
    check_result "下载新版本的脚本"
    chmod +x PalServerInstall.sh
    exit
fi

# 从本地文件获取游戏版本信息
versionInfo=$(cat version.json)

# 解析JSON以获取当前的游戏、补丁版本
currentGameVersion=$(echo $versionInfo | jq -r '.gameVersion')
currentPatchVersion=$(echo $versionInfo | jq -r '.PatchVersion')

# 比较游戏版本
if [[ $(echo -e "$currentGameVersion\n$latestGameVersion" | sort -V | head -n 1) != $latestGameVersion ]]; then
    echo "新的游戏版本可用，你的版本为 $currentGameVersion，最新版本为 $latestGameVersion。请升级。"
    sleep 2s
fi
# 比较补丁版本
if [[ $(echo -e "$currentPatchVersion\n$latestPatchVersion" | sort -V | head -n 1) != $latestPatchVersion ]]; then
    echo "新的补丁版本可用，你的版本为 $currentPatchVersion，最新版本为 $latestPatchVersion。请升级。"
    sleep 2s
fi

#root权限
root_need(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Red}Error:This script must be run as root!${Font}"
        exit 1
    fi
}

#检测ovz
ovz_no(){
    if [[ -d "/proc/vz" ]]; then
        echo -e "${Red}Your VPS is based on OpenVZ，not supported!${Font}"
        exit 1
    fi
}

#检测并安装Docker
install_docker(){
    if command -v docker &> /dev/null; then
        echo -e "${Green}Docker 已安装，进行下一步.${Font}"
    else
        echo -e "${Green}Docker 未安装，正在为您安装...${Font}"
        curl -fsSL https://get.docker.com | bash -s docker
        check_result "Docker 安装"
        echo -e "${Green}Docker 安装成功！${Font}"
    fi
}

#安装幻兽帕鲁服务端
install_pal_server(){
    if check_docker_container; then
        echo -e "${Red}幻兽帕鲁服务端已存在，安装失败！${Font}"
    else
        echo -e "${Green}开始安装幻兽帕鲁服务端...${Font}"
        CONTAINER_ID=$(docker run -dit --name steamcmd --net host cm2network/steamcmd)
        check_result "创建 Docker 容器"
        docker exec -it $CONTAINER_ID bash -c "/home/steam/steamcmd/steamcmd.sh +login anonymous +app_update 2394010 validate +quit"
        check_result "安装游戏"
        wget -O restart.sh https://www.xuehaiwu.com/wp-content/uploads/shell/Pal/restart.sh --no-check-certificate && chmod +x restart.sh 
        check_result "下载 restart.sh 脚本"
        ./restart.sh
        echo -e "${Green}幻兽帕鲁服务端已成功安装并启动！${Font}"
    fi
}

#启动幻兽帕鲁服务端
start_pal_server(){
    if check_docker_container; then
        echo -e "${Green}开始启动幻兽帕鲁服务端...${Font}"
        docker start steamcmd
        check_result "启动 Docker 容器"
        ./restart.sh
        echo -e "${Green}幻兽帕鲁服务端已成功启动！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，启动失败！${Font}"
    fi
}

#停止幻兽帕鲁服务端
stop_pal_server(){
    if check_docker_container; then
        echo -e "${Green}开始停止幻兽帕鲁服务端...${Font}"
        docker stop steamcmd
        check_result "停止 Docker 容器"
        echo -e "${Green}幻兽帕鲁服务端已成功停止！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，停止失败！${Font}"
    fi
}

#修改服务端配置
modify_config(){
    if check_docker_container; then
        if [ -f ./PalWorldSettings.ini ]; then
            echo -e "${Green}开始修改服务端配置...${Font}"
            docker restart steamcmd
            check_result "停止服务端"
            docker cp ./PalWorldSettings.ini steamcmd:/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/
            check_result "修改服务端配置"
            echo -e "${Green}服务端配置已成功修改！服务端已停止，重启后生效！${Font}"
        else
            echo -e "${Red}未找到服务端配置文件，请前往https://www.xuehaiwu.com/Pal/进行下载。${Font}"
        fi
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，修改配置失败！${Font}"
    fi
}

#增加swap内存
add_swap(){
echo -e "${Green}请输入需要添加的swap，建议为内存的2倍！${Font}"
read -p "请输入swap数值单位MB:" swapsize

#检查是否存在swapfile
grep -q "swapfile" /etc/fstab

#如果不存在将为其创建swap
if [ $? -ne 0 ]; then
    echo -e "${Green}swapfile未发现，正在为其创建swapfile${Font}"
    fallocate -l ${swapsize}M /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap defaults 0 0' >> /etc/fstab
         echo -e "${Green}swap创建成功，并查看信息：${Font}"
         cat /proc/swaps
         cat /proc/meminfo | grep Swap
    check_result "创建swap"
else
    echo -e "${Red}swapfile已存在，swap设置失败，请先运行脚本删除swap后重新设置！${Font}"
fi
}
del_swap(){
#检查是否存在swapfile
grep -q "swapfile" /etc/fstab

#如果存在就将其移除
if [ $? -eq 0 ]; then
	echo -e "${Green}swapfile已发现，正在将其移除...${Font}"
	sed -i '/swapfile/d' /etc/fstab
	echo "3" > /proc/sys/vm/drop_caches
	swapoff -a
	rm -f /swapfile
    echo -e "${Green}swap已删除！${Font}"
    check_result "删除swap"
else
	echo -e "${Red}swapfile未发现，swap删除失败！${Font}"
fi
}
#增加定时重启
add_restart(){
    if check_docker_container; then
        echo -e "${Green}开始增加定时重启...${Font}"
        echo -e "${Green}1、每天凌晨5点${Font}"
        echo -e "${Green}2、每周三凌晨5点${Font}"
        echo -e "${Green}3、每多少小时重启一次${Font}"
        read -p "请输入数字 [1-3]:" num
        case "$num" in
            1)
            echo "0 5 * * * /bin/bash $(pwd)/restart.sh >> $(pwd)/crontab.log" > mycron
            ;;
            2)
            echo "0 5 * * 3 /bin/bash $(pwd)/restart.sh >> $(pwd)/crontab.log" > mycron
            ;;
            3)
            read -p "请输入每多少小时重启一次:" hours
            echo "0 */$hours * * * /bin/bash $(pwd)/restart.sh >> $(pwd)/crontab.log" > mycron
            ;;
            *)
            echo -e "${Red}请输入正确数字 [1-3]${Font}"
            add_restart
            ;;
        esac
        crontab mycron
        rm mycron
        echo -e "${Green}定时重启已成功增加！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，增加定时重启失败！${Font}"
    fi
}

#重启幻兽帕鲁服务端
restart_pal_server(){
    if check_docker_container; then
        echo -e "${Green}开始重启幻兽帕鲁服务端...${Font}"
        ./restart.sh
        check_result "重启服务端"
        echo -e "${Green}幻兽帕鲁服务端已成功重启！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，重启失败！${Font}"
    fi
}

#查看幻兽帕鲁服务端状态
check_pal_server_status(){
    if check_docker_container; then
        echo -e "${Green}幻兽帕鲁服务端状态如下：${Font}"
        docker stats steamcmd --no-stream
    else
        echo -e "${Red}幻兽帕鲁服务端不存在！${Font}"
    fi
}

#更新幻兽帕鲁服务端
update_pal_server(){
    # 检查当前的游戏版本是否与最新的游戏版本相同
    if [ "$currentGameVersion" == "$latestGameVersion" ]; then
        echo -e "${Green}已经是最新的幻兽帕鲁游戏版本，无需更新。${Font}"
    else
        # 询问用户是否要更新至最新版游戏
        read -p "新的游戏版本可用，版本为 $latestGameVersion。是否要更新至最新版游戏? (y/n)" answer
        case ${answer:0:1} in
            y|Y )
                if [ $(docker ps -a -q -f name=steamcmd) ]; then
                    echo -e "${Green}开始启动幻兽帕鲁服务端...${Font}"
                    docker exec -it steamcmd /bin/bash -c "/home/steam/steamcmd/steamcmd.sh +login anonymous +app_update 2394010 validate +quit"
                    check_result "更新服务端"
                    # 更新本地的版本信息文件
                    jq ".gameVersion = \"$latestGameVersion\"" version.json > temp.json && mv temp.json version.json
                    echo -e "${Green}已更新本地的版本信息文件。${Font}"
                    ./restart.sh
                    echo -e "${Green}幻兽帕鲁服务端已成功启动！${Font}"
                else
                    echo -e "${Red}幻兽帕鲁服务端不存在，启动失败！${Font}"
                fi
            ;;
            * )
                echo -e "${Green}跳过更新步骤。${Font}"
            ;;
        esac
    fi
}

#删除幻兽帕鲁服务端
delete_pal_server(){
    if check_docker_container; then
        echo -e "${Green}开始删除幻兽帕鲁服务端...${Font}"
        docker stop steamcmd
        docker rm steamcmd
        check_result "删除服务端"
        echo -e "${Green}幻兽帕鲁服务端已成功删除！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，删除失败！${Font}"
    fi
}
#服务端优化补丁
update_patch_version() {
# 检查当前的补丁版本是否与最新的补丁版本相同
    if [ "$currentPatchVersion" == "$latestPatchVersion" ]; then
        echo "已经是最新优化补丁，无需更新。"
    else
        # 询问用户是否要更新至最新版补丁
        read -p "目前linux有两个版本的服务器，本补丁是基于Palworld Dedicated Server (ID：2394010 )，请先核实是否一致，如果不懂请勿更新。新的补丁版本可用，版本为 $latestPatchVersion。是否要更新至最新版补丁? (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                # 下载最新的补丁版本
                echo "正在下载新的补丁版本..."
                wget -O PalServer-Linux-Test $downloadLink
                check_result "下载补丁"
                # 替换 Docker 容器内的源文件
                docker cp PalServer-Linux-Test steamcmd:/home/steam/Steam/steamapps/common/PalServer/Pal/Binaries/Linux/PalServer-Linux-Test
                check_result "替换源文件"
                # 授权文件
                docker exec -u 0 -it steamcmd chmod +x /home/steam/Steam/steamapps/common/PalServer/Pal/Binaries/Linux/PalServer-Linux-Test
                check_result "授权补丁"
                # 更新本地的版本信息文件
                jq ".PatchVersion = \"$latestPatchVersion\"" version.json > temp.json && mv temp.json version.json
                echo "已更新本地的版本信息文件。"
                
            ;;
            * )
                echo "跳过更新步骤。"
            ;;
        esac
    fi
}
#导入幻兽帕鲁存档及配置
import_pal_server(){
    if check_docker_container; then
        read -p "请将幻兽帕鲁存档及配置(Saved)文件夹放入 /data/palworld 目录，然后回车继续" import
        echo -e "${Green}开始导入幻兽帕鲁存档及配置...${Font}"
        chmod -R 777 /data/palworld/
        docker cp -a /data/palworld/Saved/ steamcmd:/home/steam/Steam/steamapps/common/PalServer/Pal/
        check_result "导入存档及配置"
        echo -e "${Green}开始重启幻兽帕鲁服务端...${Font}"
        docker restart steamcmd
        ./restart.sh
        check_result "重启服务端"
        echo -e "${Green}幻兽帕鲁服务端已成功重启！${Font}"
        echo -e "${Green}幻兽帕鲁存档及配置已成功导入！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，导入失败！${Font}"
    fi
}

# 导出幻兽帕鲁存档及配置
export_pal_server() {
    if check_docker_container; then
        echo -e "${Green}此操作会导出容器内 /home/steam/Steam/steamapps/common/PalServer/Pal/Saved 文件夹下所有的文件${Font}"
        echo -e "${Green}导出的幻兽帕鲁存档及配置将会存放在 /data/palworld 目录下！${Font}"
        echo -e "${Green}开始导出幻兽帕鲁存档及配置...${Font}"
        mkdir -p /data/palworld
        docker cp steamcmd:/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/ /data/palworld/
        check_result "导出存档及配置"
        echo -e "${Green}幻兽帕鲁存档及配置已成功导出！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，导出失败！${Font}"
    fi
}

#开始菜单
main(){
root_need
ovz_no
install_docker
clear
echo -e "———————————————————————————————————————"
echo -e "${Green}Linux VPS一键安装管理幻兽帕鲁服务端脚本${Font}"
echo -e "${Green}脚本版本${currentScriptVersion}${Font}"
echo -e "${Green}教程地址：https://www.xuehaiwu.com/palworld-server/${Font}"
echo -e "${Green}服务器购买：https://curl.qcloud.com/WJYPYPoQ ${Font}"
echo -e "${Green}1、安装幻兽帕鲁服务端${Font}"
echo -e "${Green}2、启动幻兽帕鲁服务端${Font}"
echo -e "${Green}3、停止幻兽帕鲁服务端${Font}"
echo -e "${Green}4、修改服务端配置${Font}"
echo -e "${Green}5、增加swap内存${Font}"
echo -e "${Green}6、删除swap内存${Font}"
echo -e "${Green}7、增加定时重启${Font}"
echo -e "${Green}8、重启幻兽帕鲁服务端${Font}"
echo -e "${Green}9、查看幻兽帕鲁服务端状态${Font}"
echo -e "${Green}10、更新幻兽帕鲁服务端${Font}"
echo -e "${Green}11、删除幻兽帕鲁服务端${Font}"
echo -e "${Green}12、更新补丁版本${Font}"
echo -e "${Green}13、导入幻兽帕鲁存档及配置${Font}"
echo -e "${Green}14、导出幻兽帕鲁存档及配置${Font}"
echo -e "${Green}15、退出脚本${Font}"
echo -e "———————————————————————————————————————"
read -p "请输入数字 [1-15]:" num
check_numeric_input $num
case "$num" in
    1)
    install_pal_server
    ;;
    2)
    start_pal_server
    ;;
    3)
    stop_pal_server
    ;;
    4)
    modify_config
    ;;
    5)
    add_swap
    ;;
    6)
    del_swap
    ;;
    7)
    add_restart
    ;;
    8)
    restart_pal_server
    ;;
   9)
    check_pal_server_status
    ;;
	10)
    update_pal_server
    ;;
    11)
    delete_pal_server
    ;;
    12)
    update_patch_version
    ;;
    13)
    import_pal_server
    ;;
    14)
    export_pal_server
    ;;
    15)
    echo -e "${Green}退出脚本...${Font}"
    exit 0
    ;;
    *)
    clear
    echo -e "${Green}请输入正确数字 [1-15]${Font}"
    sleep 2s
    main
    ;;
    esac
}
main
