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
require 'net/smtp'



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
    evento.to_json(:include => [:servicos, :lugars,:usuario])
   
    
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
put     '/eventos/:id' do #add verificação admin, nao esta atualizando 
    #protected!
    content_type :json
    evento = Evento.find(params[:id])
    if Usuario.find(params[:usuarioid]).admin.eql?false 
        puts "Update nao admin"
        if adminOrOwner(params[:usuarioid],evento)
            if validaservico(evento)
                evento.servicos.destroy
                
                if evento.update_attributes (params[:evento])
                    #mailToCoord(create)
                    status 200
                    evento.to_json(:include => [:servicos, :lugars,:usuario])
                else
                    status 500
                    json evento.errors.full_messages
                end
            else
                status 500
                json evento.errors.full_messages
            
            end
        else
            status 500
            json "Usuario NAO criou o evento e NAO é admin"
        end
    else
        puts "Update admin"
        if evento.update_attributes (params[:evento])
            #mailToCoord(create)
            status 200
            evento.to_json(:include => [:servicos, :lugars,:usuario])
        else
            status 500
            json evento.errors.full_messages
        end
    end
end
delete  '/eventos/:id' do # Validar se usuario e o dono ou admin
    content_type :json
    evento = Evento.find(params[:id]) 
    if adminOrOwner(params[:usuarioid],evento)
        if evento.destroy
            status 200
            json "O evento foi removido"
        else
            status 500
            json "Ocorreu um erro ao remover o evento"
        end
    else
        status 500
        json "#Usuario NAO criou o evento e NAO é admin"
    end
    
end

#Rotas Servico
get     '/servicos' do
    content_type :json
    if valida_admin(params[:usuarioid])
        servicos = Servico.all
        servicos.to_json
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end

get     '/servicos/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        servico = Servico.find(params[:id])
        
        servico.to_json(:include => :coord)
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end

post    '/servicos' do
    if valida_admin(params[:usuarioid])
        content_type :json
        servico = Servico.new params[:servico]
        if servico.save
            status 201
        else
            status 500
            json servico.errors.full_messages#implementar validação
            
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end
put     '/servicos/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        servico = Servico.find(params[:id])   
        if servico.update_attributes (params[:servico])
            status 200
            servico.to_json(:include => :coord)
        else
            status 500
            json servico.errors.full_messages
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end

delete  '/servicos/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        servico = Servico.find(params[:id])   
        if servico.destroy
            status 200
            json "O servico foi removido"
        else
            status 500
            json "Ocorreu um erro ao remover o servico"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 

end

#Rotas Usuario#
get     '/usuarios' do #APENAS ADMIN
    content_type :json
    if valida_admin(params[:usuarioid])
        usuarios = Usuario.all
        usuarios.to_json
   else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end
get     '/usuarios/:id' do #APENAS ADMIN OU DONO
    content_type :json
    user = Usuario.find(params[:usuarioid])
    if((user.admin.eql?true) || (Integer(params[:usuarioid]).eql?Integer(params[:id])))
        usuario = Usuario.find(params[:id])
        usuario.to_json
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
    
end
post    '/usuarios' do
    content_type :json
    usuario = Usuario.new params[:usuario]
    if usuario.save
        status 201
    else
        status 500
        json usuario.errors.full_messages
    end
    
end

put     '/usuarios/:id' do  #APENAS ADMIN OU DONO
    content_type :json
    user = Usuario.find(params[:usuarioid])
    if((user.admin.eql?true) || (Integer(params[:usuarioid]).eql?Integer(params[:id])))
        usuario = Usuario.find(params[:id])   
        if usuario.update_attributes (params[:usuario])
            status 200
            usuario.to_json
        else
            status 500
            json usuario.errors.full_messages
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end

delete  '/usuarios/:id' do #APENAS ADMIN
    content_type :json
    if valida_admin(params[:usuarioid])
        usuario = Usuario.find(params[:id])
        if usuario.destroy
            status 200
            json "O usuario foi removido"
        else
            status 500
            json "Ocorreu um erro ao remover o usuario"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end


#Rotas Lugar
get     '/lugars' do
    content_type :json
    if valida_admin(params[:usuarioid])
        lugares = Lugar.all
        lugares.to_json
    else
        status 403
        json "Usuario sem acesso suficiente."
    end        
end

get     '/lugars/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        lugar = Lugar.find(params[:id])
        lugar.to_json
    else
        status 403
        json "Usuario sem acesso suficiente."
    end    
end
post    '/lugars' do
    content_type :json
    if valida_admin(params[:usuarioid])
        lugar = Lugar.new params[:lugar]
        if lugar.save
            status 201
        else
            status 500
            json lugar.errors.full_messages
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end
put     '/lugars/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        lugar = Lugar.find(params[:id])   
        if lugar.update_attributes (params[:lugar])
            status 200
            lugar.to_json
        else
            status 500
            json lugar.errors.full_messages
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

delete  '/lugars/:id' do 
    content_type :json
    if valida_admin(params[:usuarioid])
        lugar = Lugar.find(params[:id])
        if lugar.destroy
            status 200
            json "O local foi removido"
        else
            status 500
            json "Ocorreu um erro ao remover o local"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

#Rotas Coordenação
get      '/coords' do
    content_type :json
    
    if valida_admin(params[:usuarioid])
        coords = Coord.all
        coords.to_json
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
       
end

get      '/coords/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        coord = Coord.find(params[:id])
        coord.to_json
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

post     '/coords' do
    content_type :json
    if valida_admin(params[:usuarioid])
        coord = Coord.new params[:coord]
        if coord.save
            status 201
        else
            status 500
            json coord.errors.full_messages
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

put      '/coords/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        coord = Coord.find(params[:id])   
        if coord.update_attributes (params[:coord])
            status 200
            coord.to_json
        else
            status 500
            json coord.errors.full_messages
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

delete   '/coords/:id' do
    content_type :json
    if valida_admin(params[:usuarioid])
        coord = Coord.find(params[:id])
        if coord.destroy
            status 200
            json "A coordenação foi removida"
        else
            status 500
            json "Ocorreu um erro ao remover a coordenação"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

post     '/login' do
    # smtp = Net::SMTP.new('mail.ifpb.edu.br', 587)
    # @teste = true
    # smtp.start('localhost', 'params[:email]', 'params[:senha]', :plain) do |smtp| 
    # end
    # rescue  Net::SMTPAuthenticationError
    # @teste = false
    usuario = Usuario.all
    usuario.each do |u|
        if((params[:email]) == u.email)
            return {:user => u.email, :logado => 1, :pri => 0,:adm => u.admin}.to_json
        end
    end
    
end