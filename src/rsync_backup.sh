#! /bin/bash

############################################
################# 各変数定義 ################
############################################

#バックアップ先のディレクトリ
SAVEDIR="/mnt/backup/incremental_backup/hare-machine"

#バックアップ元のディレクトリ
TARGETDIR="/home/"

#ログディレクトリ
LOGDIR="/var/log/rsync_backup-service"



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


#各ディレクトリの存在確認
if [ ! -d $SAVEDIR ]; then  #バックアップ先ディレクトリの存在確認
    echo "[Check:NG] Not found backup directory"
    exit 1
elif [ ! -d $TARGETDIR ]; then  #バックアップ元ディレクトリの存在確認
    echo "[Check:NG] Not found target directory"
    exit 1
elif [ ! -d $LOGDIR ]; then  #ログディレクトリの存在確認
    echo "[Check:NG] Not found log directory"
    exit 1
else
    echo "[Check:OK] Success to check directories"
fi


#コマンドの存在確認
if [ "/usr/bin/rsync" != $(which rsync) ]; then
    echo "[Check:NG] Not found rsync command"
    exit 1
else
    echo "[Check:OK] Found rsync command"
fi


#ログ保存ディレクトリのチェック
if [ ! -e $LOGDIR/rsync_backup.log ]; then
    touch $LOGDIR/rsync_backup.log
    echo "[Check:OK] Create log file"
else
    echo "[Check:OK] Found log file"
fi

############################################
############### メインルーチン ##############
############################################

#起動時のログを記録
echo "Start rsync backup" >> $LOGDIR/rsync_backup.log

#標準出力と標準エラー出力をログファイルにリダイレクト
exec &> >(awk '{print strftime("[%Y/%m/%d %H:%M:%S] "),$0 } { fflush() } ' >> $LOGDIR/rsync_backup.log)

#直近のバックアップのディレクトリ名を取得
LATESTBKUP=$(ls $SAVEDIR | grep backup- | tail -n 1)

#バックアップの実行
rsync -avhz --link-dest="$SAVEDIR/$LATESTBKUP" "$TARGETDIR" "$SAVEDIR/home-backup_$(date +%Y_%m-%d_%H-%M)"

#30日以上前のバックアップを削除
find $SAVEDIR -type d -name "home_backup-*" -mtime +30 | xargs rm -rf

#標準出力と標準エラー出力のリダイレクトを停止
exec &>/dev/null

#終了時のログを記録
echo "Finish rsync backup" >> $LOGDIR/rsync_backup.log

exit 0