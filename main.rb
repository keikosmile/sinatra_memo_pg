# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'pg'

class MemoDB
  DATABASE = 'memo'
  TABLE = 'Memos'

  class << self
    def create_table
      begin
        conn = PG.connect(dbname: DATABASE)
        sql = "CREATE TABLE IF NOT EXISTS #{TABLE}
                ( memo_id VARCHAR(36)  NOT NULL,
                  title   VARCHAR(30)  NOT NULL,
                  body    VARCHAR(500),
                  PRIMARY KEY (memo_id)
                )"
        conn.exec(sql)
      ensure
        conn.close if conn
      end
    end

    def select(memo_id)
      begin
        conn = PG.connect(dbname: DATABASE)
        sql = "SELECT title, body FROM #{TABLE} WHERE memo_id = $1"
        result = conn.exec_params(sql, [memo_id])
      ensure
        conn.close if conn
      end
      result[0]
    end

    def select_all
      memos = {}
      begin
        conn = PG.connect(dbname: DATABASE)
        sql = "SELECT * FROM #{TABLE}"
        result = conn.exec(sql)
        result.each do |tuple|
          memos[tuple['memo_id']] = {"title"=>tuple['title'], "body"=>tuple['body']}
        end
      ensure
        conn.close if conn
      end
      memos
    end

    def insert(title, body)
      begin
        conn = PG.connect(dbname: DATABASE)
        sql = "INSERT INTO #{TABLE} (memo_id, title, body) VALUES ($1, $2, $3)"
        conn.prepare('statement', sql)
        conn.exec_prepared('statement', [SecureRandom.uuid, title, body])
      ensure
        conn.close if conn
      end
    end

    def delete(memo_id)
      begin
        conn = PG.connect(dbname: DATABASE)
        sql = "DELETE FROM #{TABLE} WHERE memo_id = $1"
        conn.exec_params(sql, [memo_id])
      ensure
        conn.close if conn
      end
    end

    def update(memo_id, title, body)
      begin
        conn = PG.connect(dbname: DATABASE)
        sql = "UPDATE #{TABLE} SET (title, body) = ($1, $2) WHERE memo_id = $3"
        conn.prepare('statement', sql)
        conn.exec_prepared('statement', [title, body, memo_id])
      ensure
        conn.close if conn
      end
    end
  end
end

configure do
  set :app_title, 'メモアプリ'
  MemoDB.create_table
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = MemoDB.select_all
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos/new' do
  MemoDB.insert(params[:title], params[:body])
  redirect '/'
end

get '/memos/:memo_id' do
  @memo_id = params[:memo_id]
  @memo = MemoDB.select(@memo_id)
  erb :detail
end

delete '/memos/:memo_id' do
  MemoDB.delete(params[:memo_id])
  redirect '/'
end

get '/memos/:memo_id/edit' do
  @memo_id = params[:memo_id]
  @memo = MemoDB.select(@memo_id)
  erb :edit
end

patch '/memos/:memo_id' do
  MemoDB.update(params[:memo_id], params[:title], params[:body])
  redirect '/'
end

get '/about' do
  erb :about
end

not_found do
  erb :error
end
