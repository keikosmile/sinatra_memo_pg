# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'pg'

class MemoDB
  class << self
    def create_table
      begin
        conn = PG.connect(dbname: 'memo')
        conn.exec("CREATE TABLE IF NOT EXISTS Memos
          ( memo_id VARCHAR(36)  NOT NULL,
            title   VARCHAR(30)  NOT NULL,
            body    VARCHAR(500),
            PRIMARY KEY (memo_id)
          )")
      ensure
        conn.close if conn
      end
    end

    def select(memo_id)
      memo = {}
      begin
        conn = PG.connect(dbname: 'memo')
        conn.exec("SELECT title, body FROM Memos WHERE memo_id = '#{memo_id}'") do |result|
          memo["title"] = "#{result[0]['title']}"
          memo["body"] = "#{result[0]['body']}"
        end
      ensure
        conn.close if conn
      end
      memo
    end

    def select_all
      memos = {}
      begin
        conn = PG.connect(dbname: 'memo')
        conn.exec("SELECT * FROM Memos") do |result|
          result.each do |tuple|
            memos["#{tuple['memo_id']}"] = {"title"=>"#{tuple['title']}", "body"=>"#{tuple['body']}"}
          end
        end
      ensure
        conn.close if conn
      end
      memos
    end

    def insert(title, body)
      begin
        conn = PG.connect(dbname: 'memo')
        conn.exec("INSERT INTO Memos (memo_id, title, body) VALUES ('#{SecureRandom.uuid}', '#{title}', '#{body}')")
      ensure
        conn.close if conn
      end
    end

    def delete(memo_id)
      begin
        conn = PG.connect(dbname: 'memo')
        conn.exec("DELETE FROM Memos WHERE memo_id = '#{memo_id}'")
      ensure
        conn.close if conn
      end
    end

    def update(memo_id, title, body)
      begin
        conn = PG.connect(dbname: 'memo')
        conn.exec("UPDATE Memos SET (title, body) = ('#{title}', '#{body}') WHERE memo_id = '#{memo_id}'")
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
