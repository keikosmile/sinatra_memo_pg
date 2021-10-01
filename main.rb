# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require_relative 'memo_db'

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

get '/memos/:id' do
  @id = params[:id]
  @memo = memo_db.select(@id)
  erb :detail
end

delete '/memos/:id' do
  memo_db.delete(params[:id])
  redirect '/'
end

get '/memos/:id/edit' do
  @id = params[:id]
  @memo = memo_db.select(@id)
  erb :edit
end

patch '/memos/:id' do
  memo_db.update(params[:id], params[:title], params[:body])
  redirect '/'
end

get '/about' do
  erb :about
end

not_found do
  erb :error
end
