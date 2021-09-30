# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require './memo_db'

memo_db = MemoDB.new('memo')

configure do
  set :app_title, 'メモアプリ'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = memo_db.select_all
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos/new' do
  memo_db.insert(params[:title], params[:body])
  redirect '/'
end

get '/memos/:memo_id' do
  @memo_id = params[:memo_id]
  @memo = memo_db.select(@memo_id)
  erb :detail
end

delete '/memos/:memo_id' do
  memo_db.delete(params[:memo_id])
  redirect '/'
end

get '/memos/:memo_id/edit' do
  @memo_id = params[:memo_id]
  @memo = memo_db.select(@memo_id)
  erb :edit
end

patch '/memos/:memo_id' do
  memo_db.update(params[:memo_id], params[:title], params[:body])
  redirect '/'
end

get '/about' do
  erb :about
end

not_found do
  erb :error
end
