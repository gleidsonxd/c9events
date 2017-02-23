require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'dotenv/load'
require './config/environments' #database configuration
require './models/evento'
require './models/usuario'
require './models/lugar'
require './models/servico'
require './models/coord'
#require './models/teste'
require './lib/sinatra/application_helper'
require 'net/smtp'
require "openssl"
require "base64"

# configure :production do
#   set :database, {adapter: 'postgresql',  encoding: 'unicode', database: 'eventosdb', pool: 2, username: 'xd', password: 'xd'}
# end

set :database_file, 'config/database.yml'

helpers ApplicationHelper


get '/' do
    erb :index
end



#Rotas Eventos
get     '/eventos' do
    protected!
    content_type :json
    eventos = Evento.all
    eventos.to_json(:include => [:servicos])
end

get     '/eventos/:id' do
    protected!
    content_type :json
    
    if eventExist(params[:id])
        evento = Evento.find(params[:id])
        evento.to_json(:include => [:servicos, :lugars,:usuario])
    else
        halt 404, "Not found\n"
    end
    
end



post    '/eventos' do
    protected!
    content_type :json
    evento = Evento.new params[:evento]
    if(evento.usuario.admin == true) #verificação do admin
        if params[:lugares] != ''
            lugares = params[:lugares].split(',')
            lugares.each do |l|
                if lugarExist(Integer(l))
                    evento.lugars << Lugar.find(l)
                else
                    halt 404, "Lugar Not found\n"
                end
            end
        else
            #puts "lista de Lugares vazia"
        end
        if params[:servicos] != ''
            servicos = params[:servicos].split(',')
            servicos.each do |s|
                if servicoExist(Integer(s))
                    mailToCoord(s,"create")
                    evento.servicos << Servico.find(s) 
                else
                     halt 404, "Serviço Not found\n"
                end
            end
        else
           # puts "lista de Serviço vazia"
        end
        if evento.save
            status 201
            json "Evento Criado com Sucesso"
        else
            status 500
            json evento.errors.full_messages#implementar validação
        end 
        
    else #Fim da verificação do admin
    #puts"Usuario não é admin"
        if params[:lugares] != ''
            lugares = params[:lugares].split(',')
            lugares.each do |l|
                if lugarExist(Integer(l))
                    evento.lugars << Lugar.find(l)
                else
                    halt 404, "Lugar Not found\n"
                end
            end
            
        else
            #puts "lista de Lugares vazia"
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
                    json "Evento Criado com Sucesso"
                else
                    status 500
                    json evento.errors.full_messages#implementar validação
                end 
            else
            status 500
            json evento.errors.full_messages#implementar validação
            end
        
        else
            #puts "EVENTO INDEPENDENTE"
            if evento.save
                status 201
                json "Evento Criado com Sucesso"
            else
                status 500
                json evento.errors.full_messages#implementar validação
            end 
            
        end
        
        
    end     
     
   
    
end
put     '/eventos/:id' do 
    protected!
    content_type :json
    if params[:usuarioid] == nil
        halt 404, "Not found\n"
    end
    if usuarioExist(params[:usuarioid]) ==false
        halt 404, "Not found\n"
    end
    evento = Evento.find(params[:id])
    if Usuario.find(params[:usuarioid]).admin.eql?false 
       # puts "Update nao admin"
        if adminOrOwner(params[:usuarioid],evento)
            if validaservico(evento)
                if eventExist(evento.id)
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
                    halt 404, "Not found\n"
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
       # puts "Update admin"
    
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
delete  '/eventos/:id' do 
    protected!
    content_type :json
    if eventExist(params[:id])
      evento = Evento.find(params[:id]) 
    else
        halt 404, "Not found\n"
    end
    if adminOrOwner(params[:usuarioid],evento)
        if evento.destroy
            status 200
            json "O evento foi removido"
        else
            status 500
            json "Error: Ocorreu um erro ao remover o evento"
        end
    else
        status 500
        json "Error: Usuario NAO criou o evento e NAO é admin"
    end
    
end

#Rotas Servico
get     '/servicos' do
    protected!
    content_type :json
        servicos = Servico.all
        #servicos.to_json(:include => :coord => {:only => :nome} )
        servicos.to_json(:include => {:coord => { :only => [:id,:nome]}})
end

get     '/servicos/:id' do
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if servicoExist(params[:id])
            servico = Servico.find(params[:id])
            servico.to_json(:include => :coord)
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end

post    '/servicos' do
    protected!
    if valida_admin(params[:usuarioid])
        content_type :json
        servico = Servico.new params[:servico]
        if servico.save
            status 201
            json "Servico Criado."
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
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if servicoExist(params[:id])
            servico = Servico.find(params[:id])   
            if servico.update_attributes (params[:servico])
                status 200
                servico.to_json(:include => :coord)
            else
                status 500
                json servico.errors.full_messages
            end
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end

delete  '/servicos/:id' do
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if servicoExist(params[:id])
            servico = Servico.find(params[:id])   
            if servico.destroy
                status 200
                json "O servico foi removido"
            else
                status 500
                json "Ocorreu um erro ao remover o servico"
            end
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 

end

#Rotas Usuario#
get     '/usuarios' do
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        usuarios = Usuario.all
        usuarios.to_json
   else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end
get     '/usuarios/:id' do 
    protected!
    content_type :json
    if usuarioExist(params[:id])
        user = Usuario.find(params[:usuarioid])
        if((user.admin.eql?true) || (Integer(params[:usuarioid]).eql?Integer(params[:id])))
            usuario = Usuario.find(params[:id])
            usuario.to_json
        else
            status 403
            json "Usuario sem acesso suficiente."
        end 
    else
        halt 404, "Not found\n"
    end
    
end
post    '/usuarios' do
    protected!
    content_type :json
    usuario = Usuario.new params[:usuario]
    if usuario.save
        status 201
        json "Usuario Criado."
    else
        status 500
        json usuario.errors.full_messages
    end
    
end

put     '/usuarios/:id' do  #APENAS ADMIN OU DONO
    protected!
    content_type :json
    if params[:usuarioid] == nil
        halt 404, "Invalid\n"
    end
    if usuarioExist(params[:usuarioid]) != false
        user = Usuario.find(params[:usuarioid])
        if((user.admin.eql?true) || (Integer(params[:usuarioid]).eql?Integer(params[:id])))
            if usuarioExist(params[:id])    
                usuario = Usuario.find(params[:id])   
                if usuario.update_attributes (params[:usuario])
                    status 200
                    usuario.to_json
                else
                    status 500
                    json usuario.errors.full_messages
                end
            else
                halt 404, "Not found\n"
            end
        else
            status 403
            json "Usuario sem acesso suficiente."
        end 

    else
        halt 404, "Not found\n"
    end
end

delete  '/usuarios/:id' do #APENAS ADMIN
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if usuarioExist(params[:id])
            usuario = Usuario.find(params[:id])
            if usuario.destroy
                status 200
                json "O usuario foi removido"
            else
                status 500
                json "Ocorreu um erro ao remover o usuario"
            end
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end 
end


#Rotas Lugar
get     '/lugars' do
    protected!
    content_type :json
    
        lugares = Lugar.all
        lugares.to_json
         
end

get     '/lugars/:id' do
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if lugarExist(params[:id])
            lugar = Lugar.find(params[:id])
            lugar.to_json
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end    
end
post    '/lugars' do
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        lugar = Lugar.new params[:lugar]
        if lugar.save
            status 201
            json "Lugar Criado."
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
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if lugarExist(params[:id])
            lugar = Lugar.find(params[:id])   
            if lugar.update_attributes (params[:lugar])
                status 200
                lugar.to_json
            else
                status 500
                json lugar.errors.full_messages
            end
        else
            halt 404, "Not found\n"
        end  
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

delete  '/lugars/:id' do 
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if lugarExist(params[:id])
            lugar = Lugar.find(params[:id])
            if lugar.destroy
                status 200
                json "O local foi removido"
            else
                status 500
                json "Ocorreu um erro ao remover o local"
            end
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

#Rotas Coordenação
get      '/coords' do
    protected!
    content_type :json
    
    if valida_admin(params[:usuarioid])
        coords = Coord.all
        coords.to_json
    elsif Usuario.find(params[:usuarioid]).tcoord == true
        coords = Coord.all
        coords.to_json
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
       
end

get      '/coords/:id' do
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if coordExist(params[:id])
            coord = Coord.find(params[:id])
            coord.to_json
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

post     '/coords' do
    protected!
    content_type :json
    if (valida_admin(params[:usuarioid]))
        coord = Coord.new params[:coord]
        if coord.save
            status 201
            json "Coordenacao Criada."
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
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if coordExist(params[:id])
            coord = Coord.find(params[:id])   
            if coord.update_attributes (params[:coord])
                status 200
                coord.to_json
            else
                status 500
                json coord.errors.full_messages
            end
        else
            halt 404, "Not found\n"
        end
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

delete   '/coords/:id' do
    protected!
    content_type :json
    if valida_admin(params[:usuarioid])
        if coordExist(params[:id])
            coord = Coord.find(params[:id])
            if coord.destroy
                status 200
                json "A coordenação foi removida"
            else
                status 500
                json "Ocorreu um erro ao remover a coordenação"
            end
        else
            halt 404, "Not found\n"
        end
        
    else
        status 403
        json "Usuario sem acesso suficiente."
    end
end

post     '/login' do
    #puts params[:password]
    senha = decrypt(params[:password])
    
    # if (params[:email]!="eventos-jp@ifpb.edu.br")
    #      usuario = Usuario.all
    #      usuario.each do |u|
    #     if((params[:email]) == u.email)
    #         return {:email => u.email, :id => u.id, :logado => 1, :pri => 0,:adm => u.admin,:tcoord => u.tcoord}.to_json
    #     end
    # end
    # else
        settings = {
    		 address: ENV['EADDRESS'],
    		 port: ENV['EPORT'],
    		 domain: ENV['EDOMAIN'],
    		 authentication: ENV['EAUTHENTICATION'],
    		 enable_starttls_auto: ENV['ESTARTTLS_AUTO'],
    		 user_name: ENV['EUSER'],
    		 password: ENV['EPASS']
    	  }
        smtp = Net::SMTP.new(settings[:address], settings[:port])
        smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto)
    
           
        begin
          @teste = true
          smtp.start(settings[:domain], params[:email], senha,
          settings[:authentication]) do |smtp| 
          end
        rescue Net::SMTPAuthenticationError
          @teste = false
        end
        
        if @teste
        	"passou"
        	usuario = Usuario.all
            usuario.each do |u|
                if((params[:email]) == u.email)
                    return {:email => u.email, :id => u.id, :logado => 1, :pri => 0,:adm => u.admin,:tcoord => u.tcoord}.to_json
                end
            end
        else
        	 return {:erro =>  "Usuario e senha incorretos!"}.to_json

        end
        
    #end
end
