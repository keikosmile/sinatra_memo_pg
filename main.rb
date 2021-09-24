# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'pg'

class MemoDB
  class << self
    def select(memo_id)
      memo = {}
      conn = PG.connect(dbname: 'memo')
      conn.exec("SELECT title, body FROM Memos WHERE memo_id = '#{memo_id}'") do |result|
        result.each do |row|
          memo["title"] = "#{row['title']}"
          memo["body"] = "#{row['body']}"
        end
      end
      conn.close
      memo
    end

    def select_all
      memos = {}
      conn = PG.connect(dbname: 'memo')
      conn.exec("SELECT * FROM Memos") do |result|
        result.each do |row|
          memos["#{row['memo_id']}"] = {"title"=>"#{row['title']}", "body"=>"#{row['body']}"}
        end
      end
      conn.close
      memos
    end

    def insert(title, body)
      conn = PG.connect(dbname: 'memo')
      conn.exec("INSERT INTO Memos (memo_id, title, body) VALUES ('#{SecureRandom.uuid}', '#{title}', '#{body}')")
      conn.close
    end

    def delete(memo_id)
      conn = PG.connect(dbname: 'memo')
      conn.exec("DELETE FROM Memos WHERE memo_id = '#{memo_id}'")
      conn.close
    end

    def update(memo_id, title, body)
      conn = PG.connect(dbname: 'memo')
      conn.exec("UPDATE Memos SET (title, body) = ('#{title}', '#{body}') WHERE memo_id = '#{memo_id}'")
      conn.close
    end
  end
end

configure do
  set :app_title, 'メモアプリ'
  FileUtils.touch(MemoDB::JSON_FILE) unless File.exist?(MemoDB::JSON_FILE)
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
