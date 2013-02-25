#config.ru

require './app'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

DataMapper.auto_upgrade!

run Rack::URLMap.new({
  "/" => App,
  "/admin" => Admin
})

