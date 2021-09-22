# sinatra_memo メモアプリ
## 【概要】
![](public/img/README_.png)
メモをネット上で共有するためのアプリです。

## 【ローカルで メモアプリ を立ち上げるための手順】

### 1. ファイルをダウンロードする
#### ファイル構成
- public/
  - css/
      - style.css
  - img/
      - memo.ico
      - post-it.jpg
      - READEME_.png
  - js/
      - input_limit.js
      - table_click.js
- views/
  - about.erb
  - detail.erb
  - edit.erb
  - error.erb
  - index.erb
  - layout.erb
  - new.erb
- .gitignore
- .rubocop.yml
- database.json (初めてWebアプリケーションを実行後、作成される)
- Gemfile
- Gemfile.lock
- main.rb
- README.md

### 2. gem をインストールする
`bundle install`

### 3. Webアプリケーションを起動する
`bundle exec ruby main.rb`

### 4. ブラウザで下記にアクセスする
http://localhost:4567

### 5. 実行中のWebアプリケーションを停止する
ターミナルで、Ctrl-C
