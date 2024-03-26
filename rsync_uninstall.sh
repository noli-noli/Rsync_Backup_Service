#! /bin/bash

############################################
############### 前処理ルーチン ##############
############################################

#実行ユーザーの確認
if [ "$(id -u)" -ne 0 ]; then
    echo "[Check:NG] Please run as root"
    exit 1
else
    echo "[Check:OK] Run as root"
fi


############################################
############### メインルーチン ##############
############################################

#関連サービスの停止
systemctl stop rsync_backup.service rsync_backup.timer

#関連サービスの削除
systemctl disable rsync_backup.service rsync_backup.timer 

#関連ファイルの削除
rm /etc/systemd/system/rsync_backup.*

#メインスクリプトの削除
rm /usr/local/bin/rsync_backup.sh

#デーモンの再読み込み
systemctl daemon-reload
systemctl reset-failed
