#! /bin/bash

############################################
################# 各変数定義 ################
############################################

#バックアップ先のディレクトリ
SAVEDIR="/mnt/backup/incremental_backup/HOGEHOGE-machine"

#バックアップ元のディレクトリ(「/」を含むか否かで動作が異なるので注意。タイムスタンプ等に影響有)
TARGETDIR="/home"

#保存名称
SAVE_NAME="home-backup_"

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

#ログディレクトリの作成
if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR
    echo "[Check:OK] Create log directory"
else
    echo "[Check:OK] Found log directory"
fi


#ログファイルのチェック
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
date +"[%Y/%m/%d %H:%M:%S] Start rsync backup" >> $LOGDIR/rsync_backup.log

#標準エラー出力をログファイルにリダイレクト
exec 2> >(awk '{print strftime("[%Y/%m/%d %H:%M:%S] "),$0 } { fflush() } ' >> $LOGDIR/rsync_backup.log)

#直近のバックアップのディレクトリ名を取得
LATESTBKUP=$(ls $SAVEDIR | grep $SAVE_NAME | tail -n 1)

#バックアップの実行
rsync -avhzL --link-dest="$SAVEDIR/$LATESTBKUP" "$TARGETDIR" "$SAVEDIR/$SAVE_NAME$(date +%Y_%m-%d_%H-%M)"

#30日以上前のバックアップを削除
find "$SAVEDIR/" -maxdepth 1 -type d -name "$SAVE_NAME*" -mtime +30 | xargs rm -rf

#標準出力と標準エラー出力のリダイレクトを停止
exec 2>/dev/null

#終了時のログを記録
date +"[%Y/%m/%d %H:%M:%S] Finish rsync backup" >> $LOGDIR/rsync_backup.log

exit 0
