require 'sinatra/base'
require 'gmail'

module ApplicationHelper
  
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
  
  def teste
    "Hello Mundo"
  end
  
  def mailToCoord(servico_id,metodo)
    serv = Servico.find(servico_id)
    puts serv.coord.nome
    
    if metodo == "create"
      assunto = "Um Evento foi criado para a Coord "+serv.coord.nome+"."
      mail(serv.coord.email,assunto)
    
    elsif metodo == "update"
      assunto = "Um Evento que a Coord "+serv.coord.nome+" fazia parte foi atualizado."
      mail(serv.coord.email,assunto)
    else
      assunto = "Um Evento que a Coord "+serv.coord.nome+" fazia parte foi deletado."
      mail(serv.coord.email,assunto)
    end
    
   
      
    
  end
 
  def valida_evento_data (servicos,eventoData)
    evento =  Evento.all
    evento.each do |e|
      if eventoData == e.data_ini
        puts "Ja existe um evento nessa data"
        return false
      end
    end
    
    
    time= Time.now
    servicos.each do |s|
      serv = Servico.find(s)
      puts time + serv.tempo.days
      if time + (serv.tempo.days) <= eventoData
          puts "EVENTO OK"
          
      else
          puts "POUCO TEMPO"
          return false
          
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
  
  def validaservico(evento, servico_ids)
        evento.servicos.each do |s|
          t = (s.tempo*0.3).round
          if Time.now <=  evento.created_at + t.days
            puts "Pode alterar"
            return true
          else
            puts "Não pode alterar"
            return false
          end
          
        end
  end
  
  def valida_admin(usuarioid)
    usuario = Usuario.find(usuarioid)
    
    if usuario.admin == true
      return true
    else
      return false
    end
  
  end
end
