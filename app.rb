require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require './config/environments' #database configuration
require './models/evento'
require './models/usuario'
require './models/lugar'
require './models/servico'
require './models/coord'
#require './models/teste'
require './lib/sinatra/application_helper'


helpers ApplicationHelper


get '/' do
    erb :index
end

get '/teste2' do
    protected!
    
    "hello"
end

get '/teste' do
    dest = "gleidsonsou@gmail.com"
    assunto ="LOL hue3"
    mail(dest,assunto)
end


#Rotas Eventos
get     '/eventos' do
    content_type :json
    eventos = Evento.all
    eventos.to_json
end

get     '/eventos/:id' do
    content_type :json
    evento = Evento.find(params[:id])
   
    evento.to_json
end

post    '/eventos' do
    content_type :json
    evento = Evento.new params[:evento]
    
    if(evento.usuario.admin == true) #verificação do admin
        if params[:lugares] != ''
            lugares = params[:lugares].split(',')
            lugares.each do |l|
                evento.lugars << Lugar.find(l)
            end
        else
            puts "lista de Lugares vazia"
        end
        if params[:servicos] != ''
            servicos = params[:servicos].split(',')
            servicos.each do |s|
                mailToCoord(s,"create")
                evento.servicos << Servico.find(s) 
            end
        else
            puts "lista de Serviço vazia"
        end
        if evento.save
            status 201
        else
            status 500
            json evento.errors.full_messages#implementar validação
        end 
        
    else #Fim da verificação do admin
    puts"Usuario não é admin"
        if params[:lugares] != ''
            lugares = params[:lugares].split(',')
            lugares.each do |l|
                evento.lugars << Lugar.find(l)
            end
            
        else
            puts "lista de Lugares vazia"
        end
        
        if params[:servicos] != ''
            servicos = params[:servicos].split(',')
            if valida_evento_data(servicos,evento.data_ini)
                servicos.each do |s|
                    mailToCoord(s,"create")
                    evento.servicos << Servico.find(s) 
                end
                if evento.save
                    status 201
                else
                    status 500
                    json evento.errors.full_messages#implementar validação
                end 
            else
            status 500
            json evento.errors.full_messages#implementar validação
            end
        
        else
            puts "EVENTO INDEPENDENTE"
            if evento.save
                status 201
            else
                status 500
                json evento.errors.full_messages#implementar validação
            end 
            
        end
        
        
    end     
     
   
    
end
put     '/eventos/:id' do
    #protected!
    content_type :json
    evento = Evento.find(params[:id])
    if validaservico(evento,params[:evento][:servico_ids])
        #evento.servicos.destroy
        
        if evento.update_attributes (params[:evento])
            #mailToCoord(create)
            status 200
            evento.to_json
        else
            status 500
            json evento.errors.full_messages
        end
    else
        status 500
        json evento.errors.full_messages
    
    end
end
delete  '/eventos/:id' do
    content_type :json
    evento = Evento.find(params[:id]) 
    
    if evento.destroy
        status 200
        json "O evento foi removido"
    else
        status 500
        json "Ocorreu um erro ao remover o evento"
    end
end

#Rotas Servico
get     '/servicos' do
    content_type :json
    servicos = Servico.all
    servicos.to_json
end

get     '/servicos/:id' do
    content_type :json
    servico = Servico.find(params[:id])
    servico.to_json
end

post    '/servicos' do
    content_type :json
    servico = Servico.new params[:servico]
    if servico.save
        status 201
    else
        status 500
        json servico.errors.full_messages#implementar validação
        
    end
end
put     '/servicos/:id' do
    content_type :json
    servico = Servico.find(params[:id])   
    if servico.update_attributes (params[:servico])
        status 200
        servico.to_json
    else
        status 500
        json servico.errors.full_messages
    end
end

delete  '/servicos/:id' do
    content_type :json
    servico = Servico.find(params[:id])   
    if servico.destroy
        status 200
        json "O servico foi removido"
    else
        status 500
        json "Ocorreu um erro ao remover o servico"
    end
end

#Rotas Usuario#
get     '/usuarios' do
    content_type :json
    usuarios = Usuario.all
    usuarios.to_json
end
get     '/usuarios/:id' do
    content_type :json
    usuario = Usuario.find(params[:id])
    usuario.to_json
    
end
post    '/usuarios' do
    content_type :json
    usuario = Usuario.new params[:usuario]
    if usuario.save
        status 201
    else
        status 500
        json usuario.errors.full_messages#implementar validação
    end
    
end

put     '/usuarios/:id' do
    content_type :json
    usuario = Usuario.find(params[:id])   
    if usuario.update_attributes (params[:usuario])
        status 200
        usuario.to_json
    else
        status 500
        json usuario.errors.full_messages
    end
end

delete  '/usuarios/:id' do
    content_type :json
    usuario = Usuario.find(params[:id])
    if usuario.destroy
        status 200
        json "O usuario foi removido"
    else
        status 500
        json "Ocorreu um erro ao remover o usuario"
    end
end


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
        json lugar.errors.full_messages
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
        json coord.errors.full_messages
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