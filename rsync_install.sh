#! /bin/bash

############################################
################# 各変数定義 ################
############################################

#service関連ファイルの配置定義
SERVICEDIR="/etc/systemd/system/"

#メインスクリプトの配置定義
SCRIPTDIR="/usr/local/bin/"

#メインスクリプト名
SCRIPTFILE="rsync_backup.sh"

#serviceファイル名
SERVICEFILE="rsync_backup.service"

#timerファイル名
TIMERFILE="rsync_backup.timer"


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

#ディレクトリとファイルの存在チェック
if [ ! -d ./src ]; then
    echo "[Check:NG:] Not found src directory"
    exit 1
elif [ ! -e ./src/$SCRIPTFILE ]; then
    echo "[Check:NG] Not found ($SCRIPTFILE)"
    exit 1
elif [ ! -e ./src/$SERVICEFILE ]; then
    echo "[Check:NG] Not found ($SERVICEFILE)"
    exit 1
elif [ ! -e ./src/$TIMERFILE ]; then
    echo "[Check:NG] Not found ($TIMERFILE)"
    exit 1
else
    echo "[Check:OK] Found all files"
fi



############################################
########### サービスファイルの配置 ###########
############################################

#サービスファイル関連の配置
cp ./src/$SERVICEFILE $SERVICEDIR
cp ./src/$TIMERFILE $SERVICEDIR

#メインスクリプトの配置
cp ./src/$SCRIPTFILE $SCRIPTDIR
#実行権限を付与
chmod 700 $SCRIPTDIR/$SCRIPTFILE



############################################
########### サービスファイルの配置 ###########
############################################

systemctl daemon-reload

#サービスの自動起動
systemctl enable $TIMERFILE
systemctl enable $SERVICEFILE

#各サービスの有効化
systemctl start $TIMERFILE
systemctl start $SERVICEFILE

exit 0
