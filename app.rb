require "rubygems"
require "bundler/setup"
require "sinatra/base"
require "zurb-foundation"
require "haml"
require "data_mapper"
require "./db.rb"

class App < Sinatra::Base
  # configure :production, :development do
  #  enable :logging
  # end

  configure do
    Compass.configuration do |config|
      config.project_path = File.dirname __FILE__
      config.sass_dir = File.join "views", "scss"
      config.images_dir = File.join "views", "images"
      config.http_path = "/"
      config.http_images_path = "/images"
      config.http_stylesheets_path = "/stylesheets"
    end

    set :scss, Compass.sass_engine_options
  end

  get "/" do
    haml :index
  end

  get "/index_en.html" do
    haml :index_en
  end

  post "/submit" do
    Booking.create(
      name: params[:name],
      email: params[:email],
      phone: params[:phone],
      school: params[:school],
      hostel: params[:hostel],
      address1: params[:address1],
      address2: params[:address2],
      zip: params[:zip],
      ticket1: params[:ticket1].to_i,
      ticket2: params[:ticket2].to_i,
      ticket3: params[:ticket3].to_i,
      payment_method: params[:payment_method],
      note: params[:note],
      placed: Time.now
      )
    
    haml :success
  end

  get "/stylesheets/*.css" do |path|
    content_type "text/css", charset: "utf-8"
    scss :"scss/#{path}"
  end
end

class Admin <Sinatra::Base
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'foo' && password == 'bar'
  end

  configure do
    Compass.configuration do |config|
      config.project_path = File.dirname __FILE__
      config.sass_dir = File.join "views", "scss"
      config.images_dir = File.join "views", "images"
      config.http_path = "/"
      config.http_images_path = "/images"
      config.http_stylesheets_path = "/stylesheets"
    end

    set :scss, Compass.sass_engine_options
  end

  get '/' do
    redirect to('./entry')
  end

  get '/entry' do
    @entries = Booking.all
    haml :lists, :layout => :admin_layout
  end

  get '/entry/:id.html' do
    @entry = Booking.get(params[:id])
    haml :entry, :layout => :admin_layout
  end

  post '/entry' do
    
    entry = Booking.get(params[:id])
    if params[:mode] == "pay" 
      entry.paid = !entry.paid
    else
      entry.delivered = !entry.delivered
    end
    entry.save

    redirect to('.')
  end


  get "/stylesheets/*.css" do |path|
    content_type "text/css", charset: "utf-8"
    scss :"scss/#{path}"
  end
end