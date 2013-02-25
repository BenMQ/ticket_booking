#config.ru

require './app'

run Rack::URLMap.new({
  "/" => App,
  "/admin" => Admin
})