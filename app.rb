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


helpers ApplicationHelper


get '/' do
    erb :index
end

get '/teste2' do
    # protected!
    # #Gerando chaves em arquivos
    # #Criando a chave privada
    # chave_privada= OpenSSL::PKey::RSA.new 1024
    # arq = File.open "chave.pri","w"
    # arq.write chave_privada
    # arq.close
    # #Criando a chave publica
    # chave_publica=chave_privada.public_key
    # arq = File.open "chave.pub","w"
    # arq.write chave_publica
    # arq.close
    # #Lendo chave privada para cifrar a mensagem
    # #Lendo arquivo
    # chave_publica = OpenSSL::PKey::RSA.new(chave_publica)
    # #Cifrando o texto
    # texto_cifrado=chave_publica.public_encrypt("123")
    # #texto_cifrado= %Q(MJtk86SkRfmouP4GR/Za9FHsYSeY9dDfUUETFOHVjtMnk+x1qRMgQytPIGdbPYY9YQaDyrFZGNSCOwip7RejVsbnaCr7A3PKb+AsDL4cFBqwOHypaUGVyNuKsnU6sKAI4Xu522VVyt4wjKzvppqCaWvHuuokkG+KbVQ2CShddLo=)
    
    # #Gravando texto cifrado
    # arq = File.open "texto.txt","w"
    # arq.write Base64.encode64(texto_cifrado)
    # arq.close
    # #Imprimindo o texto
    # puts texto_cifrado
    # #Lendo texto cifrado
    # texto_cifrado = File.read "texto.txt"
    # #Imprimindo o texto
    # puts "//////////////////"
    # puts texto_cifrado
    # chave_privada=OpenSSL::PKey::RSA.new(chave_privada)
    # puts chave_privada.private_decrypt(Base64.decode64(texto_cifrado))
   
end

get '/mjoker' do
    
    joker
    
    
end

get '/mail' do
	
    settings = {
		 address: "mail.ifpb.edu.br",
		 port: 587,
		 domain: "ifpb.edu.br",
		 authentication: "plain",
		 enable_starttls_auto: true,
		 user_name: "eventos-jp",
		 password: "eventosifpb2016"
	  }
    smtp = Net::SMTP.new(settings[:address], settings[:port])
    smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto)

    begin
      @teste = true
      smtp.start(settings[:domain], "eventos-jp@ifpb.edu.br", settings[:password],
      settings[:authentication]) do |smtp| 
      end
    rescue Net::SMTPAuthenticationError
      @teste = false
    end
    
    if @teste
    	"passou"
    else
    	"erro"
    end
    	
end

get '/teste' do
    dest = "gleidsonsou@gmail.com"
    assunto ="LOL hue3"
    mail(dest,assunto)
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
    evento = Evento.find(params[:id])
    evento.to_json(:include => [:servicos, :lugars,:usuario])
   
    
end



post    '/eventos' do
    protected!
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
    protected!
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
delete  '/eventos/:id' do 
    protected!
    content_type :json
    evento = Evento.find(params[:id]) 
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
    # if valida_admin(params[:usuarioid])
        servicos = Servico.all
        servicos.to_json
    # else
    #     status 403
    #     json "Usuario sem acesso suficiente."
    # end 
end

get     '/servicos/:id' do
    protected!
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
    protected!
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
    protected!
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
    protected!
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
    protected!
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
    protected!
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
    protected!
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
    protected!
    content_type :json
    # if valida_admin(params[:usuarioid])
        lugares = Lugar.all
        lugares.to_json
    # else
    #     status 403
    #     json "Usuario sem acesso suficiente."
    # end        
end

get     '/lugars/:id' do
    protected!
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
    protected!
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
    protected!
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
    protected!
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
        coord = Coord.find(params[:id])
        coord.to_json
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
    protected!
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
    #puts params[:password]
    senha = decrypt(params[:password])
    
    if (params[:email]!="eventos-jp@ifpb.edu.br")
         usuario = Usuario.all
         usuario.each do |u|
        if((params[:email]) == u.email)
            return {:email => u.email, :id => u.id, :logado => 1, :pri => 0,:adm => u.admin,:tcoord => u.tcoord}.to_json
        end
    end
    else
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
        	"erro"
        end
        
    end
end