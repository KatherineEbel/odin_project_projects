require 'sinatra/base'
require 'slim'
require 'sass'
require './song.rb'
require 'sinatra/flash'
require 'pony'
require 'v8'
require 'coffee-script'
#require 'sinatra/reloader' if development?

class Website < Sinatra::Base
  register Sinatra::Flash

  configure :development do
  end

  configure do
    enable :sessions
    set :username, 'frank'
    set :password, 'sinatra'
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

  def send_message
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => 'username@gmail.com',
      :subject => params[:name] + " has contacted you",
      :body => params[:message],
      :via => :smtp,
      :via_options => {
        :address => 'smtp.gmail.com',
        :port => '587',
        :enable_starttls_auto => true,
        :user_name => 'username',
        :password => 'password',
        :authentication => :plain,
        :domain => 'localhost.localdomain'
      })
  end

  get('/styles.css') { scss :styles }

  get('/javascripts/application.js') { coffee :application }

  get '/login' do
    slim :login
  end

  get '/logout' do
    session.clear
    redirect to('/login')
  end

  post '/contact' do
    send_message
    flash[:notice] = "Thank you for your message. We'll be in touch soon."
    redirect to('/')
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

  #run! if app_file == $0
end

