require 'sinatra'
require 'slim'
require 'sass'
require './song.rb'
require 'sinatra/reloader' if development?

get('/styles.css') { scss :styles }

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

get '/songs' do
  @songs = Song.all
  slim :songs
end

# new song
get '/songs/new' do
  @song = Song.new
  slim :new_song
end

post '/songs' do
  song = Song.create(params[:song])
  redirect to("/songs/#{song.id}")
end

# show song
get '/songs/:id' do
  @song = Song.get(params[:id])
  slim :show_song
end

# edit song
get '/songs/:id/edit' do
  @song = Song.get(params[:id])
  slim :edit_song
end

put '/songs/:id' do
  song = Song.get(params[:id])
  song.update(params[:song])
  redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
  Song.get(params[:id]).destroy
  redirect to('/songs')
end

not_found do
  slim :not_found
end
