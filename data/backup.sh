#!/bin/bash
check_result() {
    if [ $? -ne 0 ]; then
        echo -e "${Red}$1 失败${Font}"
        exit 1
    fi
}
check_docker_container() {
    if [ $(docker ps -a -q -f name=steamcmd) ]; then
        return 0
    else
        return 1
    fi
}
export_pal_server() {
    if check_docker_container; then
        local timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
        local backup_dir="/data/backup/backup_$timestamp/"
        echo -e "${Green}此操作会导出容器内 /home/steam/Steam/steamapps/common/PalServer/Pal/Saved 文件夹下所有的文件${Font}"
        echo -e "${Green}导出的幻兽帕鲁存档及配置将会存放在 $backup_dir 目录下！${Font}"
        echo -e "${Green}开始导出幻兽帕鲁存档及配置...${Font}"
        mkdir -p "$backup_dir"
        docker cp steamcmd:/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/ "$backup_dir"
        check_result "导出存档及配置"
        echo -e "${Green}幻兽帕鲁存档及配置已成功导出到 $backup_dir 目录！${Font}"
        
        echo -e "${Green}开始打包备份文件...${Font}"
        tar -czf "/data/backup/backup_$timestamp.tar.gz" -C "/data/backup/" "backup_$timestamp/"
        check_result "打包备份文件"
        echo -e "${Green}备份文件已成功打包为 /data/backup/backup_$timestamp.tar.gz${Font}"
        
        echo -e "${Green}开始删除原始备份文件...${Font}"
        rm -rf "$backup_dir"
        check_result "删除原始备份文件"
        echo -e "${Green}原始备份文件已成功删除！${Font}"
    else
        echo -e "${Red}幻兽帕鲁服务端不存在，导出失败！${Font}"
    fi
}

export_pal_server