# ISUCON7 予選問題 on Docker

[ISUCON7 予選問題](https://github.com/isucon/isucon7-qualify) の環境をDocker上で動かします

---

## 構成

複数台構成で、以下のコンテナが立ち上がります。

|service名|役割|
|:---:|:---:|
|app01|webサーバー|
|app02|webサーバー|
|app03|dbサーバー|
|bench|benchサーバー|

app01, app02からapp03のmysqlに接続しています。

app0X系は、メモリ1GB、CPUは1コアという制限をしています。

## ベンチマークを動かすまで

始めにcloneでリポジトリをダウンロードします。

```
$ git clone https://github.com/at-grandpa/isucon7-qualify-docker.git
$ cd isucon7-qualify-docker.git
```

操作方法は `make` もしくは `make help` で参照できます。

```
$ make

  isucon7-qualify-docker

  see: https://github.com/at-grandpa/isucon7-qualify-docker

  up                     buildからup、nginxとmysqlの起動までを全て行う
  stop                   コンテナを停止する
  rm                     コンテナを削除する
  clean                  コンテナを停止し削除する
  ps                     コンテナの一覧と状態を表示する
  logs/%                 '%'にapp01/app02/app03/benchを指定すると、指定されたコンテナの直近のlogを表示する
  attach/%               '%'にapp01/app02/app03/benchを指定すると、指定されたコンテナにattachする
  nginx/start            全Webサーバーのnginxを起動する
  nginx/start/%          '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxを起動する
  nginx/restart          全Webサーバーのnginxを再起動する
  nginx/restart/%        '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxを再起動する
  nginx/stop             全Webサーバーのnginxを停止する
  nginx/stop/%           '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxを停止する
  nginx/status           全Webサーバーのnginxのstatusを表示する
  nginx/status/%         '%'にapp01/app02を指定すると、指定されたWebサーバーでnginxのstatusを見る
  mysql/start            app03でmysqlを起動する
  mysql/restart          app03でmysqlを再起動する
  mysql/stop             app03でmysqlを停止する
  mysql/status           app03でmysqlのstatusを見る
  app/start/python       全Webサーバーでpythonのwebappが起動する
  app/start/python/%     '%'にapp01/app02を指定すると、指定されたWebサーバーでpythonのwebappが起動する
  app/start/go           全Webサーバーでgoのwebappが起動する
  app/start/go/%         '%'にapp01/app02を指定すると、指定されたWebサーバーでgoのwebappが起動する
  bench/start            BENCH_TARGET_HOSTSで指定したhostに対してベンチマークを走らせる  ex) $ make bench/start BENCH_TARGET_HOSTS=app01,app02
  bench/result           直近のベンチマークの result.json を jq コマンドで見る
  bench/score            直近のベンチマークのスコアを見る

```

ベンチマークを回すまでの手順は以下です。

まず、imageのpullとupが行います。

```
$ make up
```

次に、（今回は）goのwebサーバーを立ち上げます。

```
$ make app/start/go
```

これで、app01とapp02でgoのアプリケーションが起動します。

ブラウザで確認するには、下記にアクセスしてください。

```
[app01] http://0.0.0.0:8081/
[app02] http://0.0.0.0:8082/
```

ベンチマークをかけるには、アプリケーションが動作している状態で以下を実行してください。

```
$ make bench/start BENCH_TARGET_HOSTS=app01,app02
```

`BENCH_TARGET_HOSTS=app01`とすれば、app01にだけベンチマークを走らせます。

ベンチマーク結果は下記で確認できます。

```
$ make bench/result
```

スコアのみを見たい時は、以下を実行してください。

```
$ make bench/score
```

## チューニングの仕方

* cloneした後に`git remote`で、リモートを自分のリポジトリに変更してください
* リポジトリrootと、各コンテナの `/home/isucon/isubata` ディレクトリがマウントされています
* ローカルの`webapp/`以下のコードを編集しチューニングを行います
* コンテナ内でビルドし、アプリケーションを実行してください
* コンテナ内に入るには `make attach/app01` など、`make attach/{service名}` でログインできます
* `docker/app/Dockerfile`や`docker/db/Dockerfile`も適宜変更してください

## 参考

[ISUCON7 予選問題](https://github.com/isucon/isucon7-qualify) を参考にさせていただきました。

## コントリビュート

気になる点などありましたら、PRやISSUE等お待ちしています。お気軽にどうぞ。
