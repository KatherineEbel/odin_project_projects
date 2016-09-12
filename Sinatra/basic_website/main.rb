require 'sinatra'
require 'slim'
require 'sinatra/reloader' if development?

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
