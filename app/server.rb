require 'data_mapper'
require 'sinatra'
require 'database_cleaner'
require 'sinatra/flash'


env = ENV["RACK_ENV"] || "development"

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'
require './lib/tag'
require './lib/user'


DataMapper.finalize


set :partial_template_engine, :erb

enable :sessions

get '/' do 	
	flash.now[:notice] = "this is flash notice"
	@links = Link.all
	erb :index
end

post '/links' do
	url = params["url"]
	title = params["title"]
	tags = params["tags"].split(" ").map do |tag|
  		Tag.first_or_create(:text => tag)
	end
	Link.create(:url => url, :title => title, :tags => tags)
	redirect to('/')
end
 get '/tags/:text' do 
 	tag = Tag.first(:text => params[:text])
 	@links = tag ? tag.links : []
 	erb :index
 end

 get '/users/new' do
 	@user = User.new
 	erb :"users/new"
 end

post '/users' do
  @user = User.new(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])  
  if @user.save
    session[:user_id] = @user.id
    redirect to('/')
  else
  	flash.now[:notice] = "Sorry, your passwords don't match"
    erb :"users/new"
  end
end

helpers do

  def current_user    
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end

end

get '/delete_all' do
	links = Link.first
	links.destroy
		redirect to('/')
end




