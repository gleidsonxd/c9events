require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  "Pagina Principal"
end

