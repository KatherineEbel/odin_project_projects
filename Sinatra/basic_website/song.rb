require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require 'slim'
require 'sass'
require 'sinatra/flash'

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

class SongController < Sinatra::Base
  enable :method_override
  register Sinatra::Flash

  helpers SongHelpers

  configure do
    enable :sessions
    set :username, 'frank'
    set :password, 'sinatra'
  end

  configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db");
  end

  before do
    set_title
  end

  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\"/>"
    end.join
  end

  def current?(path='/')
    (request.path == path || request.path == path + '/') ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Sinatra"
  end

  get '/' do
    @songs = find_songs
    slim :songs
  end

  # new song
  get '/new' do
    halt(401, 'Not Authorized') unless session[:admin]
    @song = Song.new
    slim :new_song
  end

  post '/' do
    @song = create_song
    flash[:notice] = "song successfully added" if @song
    redirect to("/songs/#{@song.id}")
  end

  # show song
  get '/:id' do
    halt(401, 'Not Authorized') unless session[:admin]
    @song = find_song
     slim :show_song
  end

  # edit song
  get '/:id/edit' do
    halt(401, 'Not Authorized') unless session[:admin]
    @song = find_song
    slim :edit_song
  end

  put '/:id' do
    halt(401, 'Not Authorized') unless session[:admin]
    song = find_song
    if song.update(params[:song])
      flash[:notice] = "Song successfully updated"
    end
    redirect to("/songs/#{song.id}")
  end

  delete '/:id' do
    halt(401, 'Not Authorized') unless session[:admin]
    if find_song.destroy
      flash[:notice] = "Song deleted"
    end
    redirect to('/songs')
  end

  post '/:id/like' do
    @song = find_song
    @song.likes = @song.likes.next
    @song.save
    redirect to"/songs/#{@song.id}" unless request.xhr?
    slim :like, :layout => false
  end
end


DataMapper.finalize


