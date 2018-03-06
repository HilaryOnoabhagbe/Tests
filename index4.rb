require 'sinatra'
require 'omniauth-twitter'
require 'erb'
set :bind, '0.0.0.0' # Only needed if you're running from Codio

configure do
    enable :sessions
end

#omniauth setup, install omniauth-twitter gem every time
use OmniAuth::Builder do
    provider :twitter, 'EeiZlPpIVcNFjY7V7rSQXyHgk', 'GPxIoK2dKa5nNYjNhyfqX952Ip8jbOKpd3CbIh6uiui0iR7yz4'
end

#logged in method
helpers do
    def logged?
        session[:logged]
    end
end

#home page
get '/' do
    @message = "Click here to login" 
    @hyperlink = "/auth/twitter"            #this hyerlink takes you to the twitter login
    erb :home
end

#this is a test page to make sure cookies is working. If not logged in, you should get the error
get '/private' do  
    halt(401, 'Not Authorised') unless logged? #logged? queries whether user is logged in
    "This is the private page - members only"
end


#when login with twitter is successful, this route happens
get '/auth/twitter/callback' do
    session[:logged] = true
    
    if logged? then
        session[:profile] = env['omniauth.auth']['info']['image']         #extract user profile picture
        session[:username] = env['omniauth.auth']['info']['name']         #extract username
        @message = "Welcome #{session[:username]}. Click here to logout"
        @profile_pic = "<img src='#{session[:profile]}'>"
        @hyperlink = "/logout"
    end
    
    erb :home
end

#when login is unsuccessful, this route happens
get '/auth/failure' do
    params[:message]  #displays the message from twitter as to why authentification failed - don't have to create meesage
end

get '/logout' do
    session[:logged] = nil #deletes the session
    "You are now logged out" # replace this message with a erb/ views page or redirect to homepage?
end
    