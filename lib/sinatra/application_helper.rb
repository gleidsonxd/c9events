require 'sinatra/base'
require 'pony'
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
  
  def h(text)
    Rack::Utils.escape_html(text)
  end
 
  def valida_evento_data (servicos,eventoData)
    evento =  Evento.all
    evento.each do |e|
      if eventoData == e.data_ini
        puts "Ja existe um evento nessa data"
        return false
      end
    end
    
    #contsDia = 86400
    
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
    gmail =  Gmail.new("devlaravelx","laravel1111")
      email = gmail.generate_message do
        to dest
        subject "TESTE"
        body assunto
      end
      gmail.deliver(email)    
    gmail.logout  
  end
  
  def validaservico(evento, servico_ids)
    # puts "AKI"
    # puts servico_ids
    # puts"FIM"
    
      evento.servicos.each do |s|
        # if s.id != servico_ids
        #   puts "DIFERENTE"
        # else
        #   puts"IGUAL"
        # end
        t = (s.tempo*0.3).round
          if Time.now <=  evento.created_at + t.days
            puts "Pode alterar"
            return true
          else
            puts "Não pode alterar"
            return false
            #return false
          end
        puts 
      
      end
    end
end
