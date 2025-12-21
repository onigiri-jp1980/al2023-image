# WSL用イメージ構築(AmazonLinux2023)
AmazonLinux2023を以下の構成でセットアップしてWSLにインポートするためのイメージを構築するのものです。

 - pyenv越しにPython3.12を利用できる
   - AL2023にはPython3.9が同梱されていますが、これをPython3.10以降にアップグレードする公式な方法がないため
   - AL2023公式でPython3.10以降のRPMが配布されてはいますけど、alternative等でサクっと切り替えられずダルいのです。
 - HomeBrew(LinuxBrew)を利用できる
 - docker-compose を利用できる
   - Podmanベースにしてもいいんですけど、仕事ではまだDockerなので。
 - プロンプトにカレントディレクトリがgitリポジトリだった場合、どのブランチか未コミットの資材があるか表示する<br />
   - IaCな感じの作業するときに地味に便利です。 
 ```bash
 # 未コミット資材がある場合
 [USER@HOSTNAME current_dir][branch-name*]$ 
 # [ブランチ名*]のようにアスタリスクがつきます。

 # 未コミット資材がない（いわゆるクリーンな状態の）場合
 [USER@HOSTNAME current_dir][branch-name]$ 
 # [ブランチ名*]のようにアスタリスクがつきません。
 ```
 - SSHキーを配置します。
   - 作りながら思いましたが、共有ボリューム使う方法のが管理が楽な面があると思います。
## 使用方法
### 環境設定ファイルの準備
```bash
$ cp .env.example .env
```
ログインユーザー名、グループ名とかをお好みのものに変更してください

### SSHキーの配置
```bash
$ cp -rp ~/.ssh/* ./docker/ssh/
```

### イメージのビルド
```bash
$ docker compose build
```

### コンテナの起動・ログイン
```bash
$ docker compose up -d
$ docker compose exec app bash
```

### イメージのエクスポート
コンテナIDを得る必要があるので、一旦コンテナを起動します。
本稿ではWSLへのインポートを前提にしているので、Windows側の`C:\wsl`に保存される
手順で記述します。
```bash
## ビルドしたイメージでコンテナを起動
$ docker compose up -d
## 無圧縮tarで出力(こっちが楽です)
$ docker export $(docker compose ps -q) > /mnt/c/wsl/export.tar
## xzで圧縮する場合
$ docker export $(docker compose ps -q) | xz -c - > /mnt/c/wsl/export.tar.xz
```

### WSLへのインポート
今更書くまでもないですけど一応。
```shell
wsl --import <ディストリビューション名> <インストール先> <エクスポートしたtarファイルのパス> 
```
