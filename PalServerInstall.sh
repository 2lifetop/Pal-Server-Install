#!/usr/bin/env bash
#Blog:https://www.xuehaiwu.com/

Green="\033[32m"
Font="\033[0m"
Red="\033[31m"


DATETIME_DIR="$(date +\%Y-\%m-\%d\%H\%M\%S)"
BACKUP_DIR="./Saved/$DATETIME_DIR"

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
        echo -e "${Green}Docker 安装成功！${Font}"
    fi
}

#备份存档
backup_word() {
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Green}开始备份幻兽帕鲁存档...${Font}"
        CONTAINER_ID=$(docker ps -a -q -f name=steamcmd)
        mkdir -p "$BACKUP_DIR"
        docker cp -a steamcmd:/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/SaveGames/0 "$BACKUP_DIR"
        tar -czvf "$BACKUP_DIR.tar.gz" -C "$BACKUP_DIR" .
        rm -rf "$BACKUP_DIR"

        echo -e "${Green}备份幻兽帕鲁存档成功，备份文件夹为 $DATETIME_DIR${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，备份失败！${Font}"
    fi
}

#安装幻兽帕鲁服务端
install_pal_server(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Red}幻兽帕鲁服务端已存在，安装失败！${Font}"
    else
        echo -e "${Green}开始安装幻兽帕鲁服务端...${Font}"
        CONTAINER_ID=$(docker run -dit --name steamcmd  --net host cm2network/steamcmd)
        docker exec -it $CONTAINER_ID bash -c "/home/steam/steamcmd/steamcmd.sh +login anonymous +app_update 2394010 validate +quit"
        wget https://www.xuehaiwu.com/wp-content/uploads/shell/Pal/restart.sh &&chmod +x restart.sh
        ./restart.sh
        echo -e "${Green}幻兽帕鲁服务端已成功安装并启动！${Font}"
    fi
}

#启动幻兽帕鲁服务端
start_pal_server(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Green}开始启动幻兽帕鲁服务端...${Font}"
        docker start steamcmd
        ./restart.sh
        echo -e "${Green}幻兽帕鲁服务端已成功启动！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，启动失败！${Font}"
    fi
}

#停止幻兽帕鲁服务端
stop_pal_server(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Green}开始停止幻兽帕鲁服务端...${Font}"
        docker stop steamcmd
        echo -e "${Green}幻兽帕鲁服务端已成功停止！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，停止失败！${Font}"
    fi
}
#查看幻兽帕鲁服务端状态
check_pal_server_status(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Green}幻兽帕鲁服务端状态如下：${Font}"
        docker ps -a -f name=steamcmd
        echo -e "${Green}幻兽帕鲁服务端资源使用情况如下：${Font}"
        docker stats --no-stream steamcmd
        echo -e "${Green}服务器内存使用情况如下：${Font}"
        free -h
    else
        echo -e "${Red}幻兽帕鲁服务端不存在！${Font}"
    fi
}

#修改服务端配置
modify_config(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        if [ -f ./PalWorldSettings.ini ]; then
            echo -e "${Green}开始修改服务端配置...${Font}"
            docker cp ./PalWorldSettings.ini steamcmd:/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/
            echo -e "${Green}服务端配置已成功修改！服务端重启后生效！${Font}"
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
else
	echo -e "${Red}swapfile未发现，swap删除失败！${Font}"
fi
}
#增加定时重启
add_restart(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Green}开始增加定时重启...${Font}"
        echo -e "${Green}1、每天凌晨5点${Font}"
        echo -e "${Green}2、每周三凌晨5点${Font}"
        echo -e "${Green}3、自定义${Font}"
        read -p "请输入数字 [1-3]:" num
        case "$num" in
            1)
            echo "0 5 * * * cd $(pwd) && ./restart.sh" >> /etc/crontab
            ;;
            2)
            echo "0 5 * * 3 cd $(pwd) && ./restart.sh" >> /etc/crontab
            ;;
            3)
            read -p "请输入定时重启的cron表达式:" cron
            echo "$cron cd $(pwd) && ./restart.sh" >> /etc/crontab
            ;;
            *)
            echo -e "${Red}请输入正确数字 [1-3]${Font}"
            add_restart
            ;;
        esac
        echo -e "${Green}定时重启已成功增加！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，增加定时重启失败！${Font}"
    fi
}

#重启幻兽帕鲁服务端
restart_pal_server(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Green}开始重启幻兽帕鲁服务端...${Font}"
        docker start steamcmd
        ./restart.sh
        echo -e "${Green}幻兽帕鲁服务端已成功重启！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，重启失败！${Font}"
    fi
}

#删除幻兽帕鲁服务端
delete_pal_server(){
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        echo -e "${Green}开始删除幻兽帕鲁服务端...${Font}"
        docker stop steamcmd
        docker rm steamcmd
        echo -e "${Green}幻兽帕鲁服务端已成功删除！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，删除失败！${Font}"
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
echo -e "${Green}教程地址：https://www.xuehaiwu.com/palworld-server/${Font}"
echo -e "${Green}1、安装幻兽帕鲁服务端${Font}"
echo -e "${Green}2、启动幻兽帕鲁服务端${Font}"
echo -e "${Green}3、停止幻兽帕鲁服务端${Font}"
echo -e "${Green}4、修改服务端配置${Font}"
echo -e "${Green}5、增加swap内存${Font}"
echo -e "${Green}6、删除swap内存${Font}"
echo -e "${Green}7、增加定时重启${Font}"
echo -e "${Green}8、重启幻兽帕鲁服务端${Font}"
echo -e "${Green}9、查看幻兽帕鲁服务端状态${Font}"
echo -e "${Green}10、删除幻兽帕鲁服务端${Font}"
echo -e "${Green}11、备份存档${Font}"
echo -e "———————————————————————————————————————"
read -p "请输入数字 [1-9]:" num
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
    delete_pal_server
    ;;
    11)
    backup_word
    ;;
    *)
    clear
    echo -e "${Green}请输入正确数字 [1-11]${Font}"
    sleep 2s
    main
    ;;
    esac
}
main
