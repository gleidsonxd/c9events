require 'sinatra/base'
require 'pony'

module ApplicationHelper
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
    
    contsDia = 86400
    
    time= Time.new
    servicos.each do |s|
      serv = Servico.find(s)
      puts time + (serv.tempo*contsDia)
      if time + (serv.tempo*contsDia)<= eventoData
          puts "EVENTO OK"
          
      else
          puts "POUCO TEMPO"
          return false
          
      end
      
    end
  end
  
  def mail(args)
  Pony.mail :to => args[:to],
            :from => 'devlaravelx@gmail.com',
            :cc => args[:cc],
            :via => :smtp,
            :body => args[:body],
            :bcc => args[:bcc],
            :subject => args[:subject],
            :via_options => {
              :host                 => 'smtp.gmail.com',
              :port                 =>  '25',
              :enable_starttls_auto => true,
              :user_name            => 'devlaravelx',
              :password             => 'laravel1111',
              :authentication       => :plain,
              :domain               => 'gmail.com',
              
              :ssl => true
            }
     # return m
    #mail(to: args[:to],
    #     cc: args[:cc],
    #     bcc: args[:bcc],
    #     body: args[:body],
    #     subject: args[:subject]).deliver
  end
  
end
