# encoding: utf-8
require "rubygems"
require "bundler/setup"
require "sinatra/base"
require "zurb-foundation"
require "haml"
require "pony"
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
    day1 = params[:ticket1].to_i
    day2 = params[:ticket2].to_i
    day3 = params[:ticket3].to_i
    content = "Dear #{params[:name]},\nThank you for pre-ordering the tickets for Project Republica 2013. Here are the details of the order for your reference. Note: This is not a confirmation of payment.\n感谢您预订理想国2013演出门票，以下是您的确认信息供您保留。注：本邮件非付款确认。\n\nName: #{params[:name]}\nContact Number: #{params[:phone]}\nSchool: #{params[:school]}\nHostel: #{params[:hostel]}\nAddress:\n    #{params[:address1]}\n    #{params[:address2]}\n    Singapore #{params[:zip]}\n#{day1>0 ? "Tickets for 17 May: #{day1}\n" : ""}#{day2>0 ? "Tickets for 18 May: #{day2}\n" : ""}#{day3>0 ? "Tickets for 18 May: #{day3}\n" : ""}\n\nThank you for supporting Project Republica 2013.\n感谢您对理想国计划2013的支持。谢谢！\n\n\n Regards,\n Project Republica 2013 Team\n理想国计划2013团队"
    

    begin
      Pony.mail(:to => "#{params[:email]}",
              :from => "#{ENV['FROM_EMAIL']}",
              :subject => 'Project Republica 2013 Pre-order confirmation',
              :body =>  content,
              :charset => 'utf-8',
              :via => :smtp, :via_options => {
                :address       => 'smtp.gmail.com',
                :port       => '587',
                :user_name       => "#{ENV['MAILER_USERNAME']}",
                :password   => "#{ENV['MAILER_PASSWORD']}",
                :authentication  => :plain,
                :domain     => "facultyofcreativity.org"
               }
             )
      haml :success
    rescue
      haml :mail_error
    end
    
  end

  get "/stylesheets/*.css" do |path|
    content_type "text/css", charset: "utf-8"
    scss :"scss/#{path}"
  end
end

class Admin <Sinatra::Base
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV['ADMIN_USERNAME'] && password == ['ADMIN_PASSWORD']
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

  get '/entry/' do
    redirect to('./entry')
  end


  get '/entry/:id.html' do
    @entry = Booking.get(params[:id])
    @success = params[:update] == "1"
    haml :entry, :layout => :admin_layout
  end

  post '/entry/:id.html' do
    entry = Booking.get(params[:id])
    entry.paid = ! params[:paid].nil?
    entry.delivered = ! params[:delivered].nil?
    entry.name = params[:name]
    entry.email = params[:email]
    entry.phone = params[:phone]
    entry.school = params[:school]
    entry.hostel = params[:hostel]
    entry.address1 = params[:address1]
    entry.address2 = params[:address2]
    entry.zip = params[:zip]
    entry.ticket1 = params[:ticket1].to_i
    entry.ticket2 = params[:ticket2].to_i
    entry.ticket3 = params[:ticket3].to_i
    entry.payment_method = params[:payment_method]
    entry.note = params[:note]
    entry.save
    redirect to("/entry/#{params[:id]}.html?update=1")
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

  post '/delete/:id.html' do
    entry = Booking.get(params[:id])
    entry.destroy

    redirect to('/entry')
  end


  get "/stylesheets/*.css" do |path|
    content_type "text/css", charset: "utf-8"
    scss :"scss/#{path}"
  end
end