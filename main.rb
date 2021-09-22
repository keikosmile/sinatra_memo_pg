# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

class MemoDB
  JSON_FILE = './database.json'

  class << self
    def read_memos
      memos = {}
      memos = JSON.parse(File.read(JSON_FILE)) unless File.zero?(JSON_FILE)
      memos
    end

    def write_memos(memos)
      File.open(JSON_FILE, 'w') do |file|
        JSON.dump(memos, file)
      end
    end

    def select(memo_id)
      memos = MemoDB.read_memos
      memos[memo_id]
    end

    def select_all
      MemoDB.read_memos
    end

    def insert(title, body)
      memos = MemoDB.read_memos
      memos[SecureRandom.uuid] = { 'title' => title, 'body' => body }
      MemoDB.write_memos(memos)
    end

    def delete(memo_id)
      memos = MemoDB.read_memos
      memos.delete(memo_id)
      MemoDB.write_memos(memos)
    end

    def update(memo_id, title, body)
      memos = MemoDB.read_memos
      memos[memo_id] = { 'title' => title, 'body' => body }
      MemoDB.write_memos(memos)
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
