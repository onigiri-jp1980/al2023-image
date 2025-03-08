# WSL用イメージ構築(AmazonLinux2023)
AmazonLinux2023を以下の構成で構築してWSLにインポートする際のものです。
- pyenv越しにPython3.12を利用できる
  - AL2023にはPython3.9が同梱されていますが、これをPython3.10以降にアップグレードする公式な方法がないため
  - AL2023公式でPython3.10以降のRPMが配布されてはいますけど、alternativeとかでサクっと切り替えられずダルいのです。
- docker-compose を利用できる
  - Podmanベースにしてもいいんですけど
## 使用方法
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
$ docker compose up -d
## 無圧縮tarで出力
$ docker export $(docker compose ps -q) > /mnt/c/wsl/export.tar
## xzで圧縮する場合
$ docker export $(docker compose ps -q) | xz -c - > /mnt/c/wsl/export.tar.xz
```
