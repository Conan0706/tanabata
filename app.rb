require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require "faye/websocket"
require "webrick"
require "pry"
require './models.rb'

set :sockets, []

connections = []

get '/' do
  erb :index
end

get '/websocket' do
  if Faye::WebSocket.websocket?(request.env)
    ws = Faye::WebSocket.new(request.env)

    ws.on :open do |event|
      settings.sockets << ws
    end

    ws.on :message do |event|
      settings.sockets.each do |socket|
        socket.send(event.data)
      end
    end

    ws.on :close do |event|
      settings.sockets.delete(ws)
    end

    ws.rack_response
  else
    redirect '/result'
  end
end

get '/result' do
  @postsCount = Post.all.count
  erb :result
end

post '/create' do
  username = params[:username]
  message = params[:message]
  
  # レコードの作成
  post = Post.create(name: username, content: message)
  
  # WebSocketを通じてクライアントにデータを送信
  data = {
    username: post.name,
    message: post.content,
    postCount: Post.all.count
  }
  settings.sockets.each do |socket|
    socket.send(data.to_json)
  end
  
  # レコード数を更新
  @postsCount = Post.all.count
  
  redirect '/'
end
