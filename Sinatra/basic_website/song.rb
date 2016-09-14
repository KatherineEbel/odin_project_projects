require 'dm-core'
require 'dm-migrations'


class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date
  property :likes, Integer, :default => 0

  def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

module SongHelpers
  def find_songs
    Song.all
  end

  def find_song
    Song.get(params[:id])
  end

  def create_song
    Song.create(params[:song])
  end
end

helpers SongHelpers

DataMapper.finalize

get '/songs' do
  @songs = find_songs
  slim :songs
end

# new song
get '/songs/new' do
  halt(401, 'Not Authorized') unless session[:admin]
  @song = Song.new
  slim :new_song
end

post '/songs' do
  @song = create_song
  flash[:notice] = "song successfully added" if @song
  redirect to("/songs/#{@song.id}")
end

# show song
get '/songs/:id' do
  halt(401, 'Not Authorized') unless session[:admin]
  @song = find_song
   slim :show_song
end

# edit song
get '/songs/:id/edit' do
  halt(401, 'Not Authorized') unless session[:admin]
  @song = find_song
  slim :edit_song
end

put '/songs/:id' do
  halt(401, 'Not Authorized') unless session[:admin]
  song = find_song
  if song.update(params[:song])
    flash[:notice] = "Song successfully updated"
  end
  redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
  halt(401, 'Not Authorized') unless session[:admin]
  if find_song.destroy
    flash[:notice] = "Song deleted"
  end
  redirect to('/songs')
end

post '/songs/:id/like' do
  @song = find_song
  @song.likes = @song.likes.next
  @song.save
  redirect to"/songs/#{@song.id}" unless request.xhr?
  slim :like, :layout => false
end
