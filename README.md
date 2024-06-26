# Rsync自動バックアップスクリプト群
*注意* シンボリックリンクは無視され、実体がコピーされます。

## 動作要件(動作確認済環境)
rootユーザーOnlyでの動作を想定

1. rsync   (3.2.7-0ubuntu0.22.04.2 amd64)
2. systemd (249.11-0ubuntu3.11 amd64)
3. bash    (5.1-6ubuntu1.1 amd64)

# 初期設定
## バックアップ先とバックアップ元の指定
./src/rsync_backup.sh　内の「各変数定義」セクション内で定義されている「SAVEDIR」と「TARGETDIR」の内容を、適時書き換えて下さい。
```bash
############################################
################# 各変数定義 ################
############################################

#バックアップ先のディレクトリ
SAVEDIR= バックアップ先ディレクトリ

#バックアップ元のディレクトリ
TARGETDIR= バックアップ元ディレクトリ
```

## インストール
動作要件が満たされている事を確認した上で、以下のコマンドを実行して下さい。
```bash
sudo bash rsync_install.sh
```

## アンインストール
以下のコマンドを実行すると、"インストール"で実行された内容を綺麗さっぱり削除してアンインストールできます。
```bash
sudo bash rsync_uninstall.sh
```

## ディレクトリ構造
<pre>
.
├── README.md           # りーどみぃい
├── rsync_install.sh    # サービスインストール用スクリプト
├── rsync_uninstall.sh  # サービスアンインストール用スクリプト
└── src
    ├── rsync_backup.service    # サービスファイル
    ├── rsync_backup.timer      # サービストリガー
    └── rsync_backup.sh         # バックアップスクリプト
</pre>