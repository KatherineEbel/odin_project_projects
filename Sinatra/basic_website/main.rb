require 'sinatra'
require 'slim'
require 'sass'
require './song.rb'
require 'sinatra/reloader' if development?

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db");
end

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end


get('/styles.css') { scss :styles }

get '/login' do
  slim :login
end

get '/logout' do
  session.clear
  redirect to('/login')
end

post '/login' do
  if params[:username] == settings.username && params[:password] = settings.password
    session[:admin] = true
    redirect to('/')
  else
    slim :login
  end
end

get '/' do
  slim :home
end

get '/about' do
  @title = 'All about this Site'
  slim :about
end

get '/contact' do
  @title = 'Contact Us'
  slim :contact
end


not_found do
  slim :not_found
end
