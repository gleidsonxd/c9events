require 'sinatra/base'
require 'dotenv/load'
require "base64"
require 'openssl'
require 'net/smtp'
require 'mailfactory'



module ApplicationHelper
  
  
  
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['APIUSER'], ENV['APIPASS']]
  end
  
  def teste
    "Hello Mundo"
  end
  
  def eventExist(id)
    if (Evento.exists?(Integer(id)) == false)
      return false
    else
      return true
    end  
  end

  def coordExist(id)
    if (Coord.exists?(Integer(id)) == false)
        return false
    else
        return true
    end
  end
  
  def lugarExist(id)
    if (Lugar.exists?(Integer(id)) == false)
        return false
    else
        return true
    end
  end

  def usuarioExist(id)
    if (Usuario.exists?(Integer(id)) == false)
        return false
    else
        return true
    end
    
  end

  def servicoExist(id)
    if (Servico.exists?(Integer(id)) == false)
        return false
    else
        return true
    end
    
  end

  def mailToCoord(servico_id,metodo)
    serv = Servico.find(servico_id)
    #puts serv.coord.nome
    
    args = {
        to: serv.coord.email,
        from: ENV['EMAILFULL'],

    }
    settings = {
        address: ENV['EADDRESS'],
        port: ENV['EPORT'],
        domain: ENV['EDOMAIN'],
        authentication: ENV['EAUTHENTICATION'],
        enable_starttls_auto: ENV['ESTARTTLS_AUTO'],
        user_name: ENV['EUSER'],
        password: ENV['EPASS']
    }

    mail = MailFactory.new()
    mail.to = args[:to]
    mail.from = args[:from]
    mail.subject = "Novo Evento"
    
    smtp = Net::SMTP.new(settings[:address], settings[:port])
    smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto)

    smtp.start(settings[:domain], ENV['EMAILFULL'], settings[:password],
    settings[:authentication]) do |smtp| 
    
    if metodo == "create"
      mail.text = "Um Evento foi criado para a Coordenação "+serv.coord.nome+"."
      smtp.send_message mail.to_s(), ENV['EMAILFULL'], args[:to]
    end
    smtp.finish
    end
 
  end
 
  def valida_evento_data (servicos,eventoData)
    evento =  Evento.all
    evento.each do |e|
      if ((eventoData >= e.data_ini) && (eventoData <= e.data_fim))
       # puts "Ja existe um evento nessa data"
        return false
      end
    end
    
    
    time= Time.now
    servicos.each do |s|
      if servicoExist(s)
        serv = Servico.find(s)
        #puts time + serv.tempo.days
        #puts eventoData
        if time + (serv.tempo.days) <= eventoData
           # puts "EVENTO OK" 
        else
           # puts "POUCO TEMPO"
            return false 
        end
      
    else
        halt 404, "Serviço Not found\n"
      end

    end
  end
  
  def mail(dest, assunto)
    
    Gmail.connect("devlaravelx","laravel1111") do |gmail|
      if gmail.logged_in?
        email = gmail.compose do
          to dest
          subject "TESTE"
          body assunto
        end
        email.deliver! # or: gmail.deliver(email)
      end
    end
  end
  
  def validaservico(evento)
     
    
        evento.servicos.each do |s|
          t = (s.tempo*0.3).round
          if Time.now <=  evento.created_at + t.days
           # puts "Pode alterar"
            return true
          else
           # puts "Não pode alterar"
            return false
          end
          
        end
  end
  
  def valida_admin(usuarioid)
    
    if ((usuarioid == nil)|| usuarioExist(usuarioid)==false)
      halt 500, "Invalid\n"
    end
    usuario = Usuario.find(usuarioid)
    if usuario.admin == true
      return true
    else
      return false
    end
  
  end
  
  def adminOrOwner(usuarioid,evento)
    if ((usuarioid == nil)|| usuarioExist(usuarioid)==false)
      halt 500, "Invalid\n"
    end
      user =  Usuario.find(usuarioid)
    if (evento.usuario_id.eql?Integer(usuarioid)) || (user.admin.eql?true)
     # puts "Usuario criou o evento ou é admin"
      return true
    else
     # puts "Usuario NAO criou o evento e NAO é admin"
      return false
      
    end
    
  end

  def decrypt (pass)
    
    iv = ENV['IVCRIP']
    key = ENV['KEYCRIP']
    decipher = OpenSSL::Cipher::AES256.new(:CBC)
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv
    
    senha = decipher.update(pass) + decipher.final
    
    
    return senha
  end
  
end
