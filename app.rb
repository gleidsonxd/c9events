require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require './config/environments' #database configuration
require './models/evento'
require './models/usuario'
require './models/lugar'
require './models/servico'
require './models/coord'


get '/' do
    erb :index
end

#post '/submit' do
 #       @model = Model.new(params[:model])
  #      if @model.save
   #            redirect '/models'
    #    else
    #            "Sorry, there was an error!"
     #   end
#end

#get '/models' do
 #   @models = Model.all
  #  erb :models
#end

# post '/create' do
#     evento = Evento.new
#     evento.save
#     'ok'
# end

# get '/create' do
#     evento = Evento.new
#     evento.save
#     'ok'
# end

#Rotas Eventos
#get     '/eventos'
#get     '/eventos/:id'
#post    '/eventos'
#put     '/eventos/:id'
#delete  '/eventos/:id'

#Rotas Servico
#get     '/sevicos'
#get     '/sevicos/:id'
#post    '/sevicos'
#put     '/sevicos/:id'
#delete  '/sevicos/:id'

#Rotas Usuario#
#get     '/usuarios'
#get     '/usuarios/:id'
#post    '/usuarios'
#put     '/usuarios/:id'
#delete  '/usuarios/:id'
#
#Rotas Lugar
get     '/lugars' do
    content_type :json 
    lugares = Lugar.all
    lugares.to_json
end

get     '/lugars/:id' do
    content_type :json
    lugar = Lugar.find(params[:id])
    lugar.to_json
end
post    '/lugars' do
    content_type :json
    lugar = Lugar.new params[:lugar]
    if lugar.save
        status 201
    else
        status 500
        json lugar.errors.full_messages#implementar validação
    end
end
put     '/lugars/:id' do
    content_type :json
    lugar = Lugar.find(params[:id])   
    if lugar.update_attributes (params[:lugar])
        status 200
        lugar.to_json
    else
        status 500
        json lugar.errors.full_messages
    end
end
delete  '/lugars/:id' do 
    content_type :json
    lugar = Lugar.find(params[:id])
    if lugar.destroy
        status 200
        json "O local foi removido"
    else
        status 500
        json "Ocorreu um erro ao remover o local"
    end
end

#Rotas Coordenação
get      '/coords' do
    content_type :json
    coords = Coord.all
    coords.to_json
    
end

get      '/coords/:id' do
    content_type :json
    coord = Coord.find(params[:id])
    coord.to_json
end

post     '/coords' do
    content_type :json
    coord = Coord.new params[:coord]
    if coord.save
        status 201
    else
        status 500
        json coord.errors.full_messages#implementar validação
    end
end

put      '/coords/:id' do
    content_type :json
    coord = Coord.find(params[:id])   
    if coord.update_attributes (params[:coord])
        status 200
        coord.to_json
    else
        status 500
        json coord.errors.full_messages
    end
end

delete   '/coords/:id' do
    content_type :json
    coord = Coord.find(params[:id])
    if coord.destroy
        status 200
        json "A coordenação foi removida"
    else
        status 500
        json "Ocorreu um erro ao remover a coordenação"
    end
end