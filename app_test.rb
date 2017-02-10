ENV['RACK_ENV'] = 'test'

require_relative "app"
require "test/unit"
require "rack/test"
require "json"
set :environment, :test
class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  
   ###############COORDS###########################
   #GET
   def test_all_coords
   	#good
  	authorize "admin","admin"
    get '/coords',:usuarioid=>"1"
    tmp = Coord.all.length
    assert_equal JSON.parse(last_response.body).length, Coord.all.length
  	#bad1
  	authorize "",""
    get '/coords',:usuarioid=>"1"
    tmp = Coord.all.length
    assert_equal "Not authorized\n", last_response.body
    #bad2
    authorize "admin","admin"
    get '/coords'
    tmp = Coord.all.length
    assert_equal "Invalid\n", last_response.body
    #bad3
    authorize "admin","admin"
    get '/coords/1',:usuarioid=>"2"
    assert_equal "\"Usuario sem acesso suficiente.\"", last_response.body
  end
  #LIST
  def test_one_coords
  	#good
  	authorize "admin","admin"
    get '/coords/1',:usuarioid=>"1"
    tmp = Coord.all.length
    assert_equal JSON.parse(last_response.body)['nome'], 'C1'
  	#bad1
  	authorize "",""
    get '/coords/1',:usuarioid=>"1"
    tmp = Coord.all.length
    assert_equal "Not authorized\n", last_response.body
    #bad2
    authorize "admin","admin"
    get '/coords/1'
    assert_equal "Invalid\n", last_response.body
    #bad3
    authorize "admin","admin"
    get '/coords/1',:usuarioid=>"2"
    assert_equal "\"Usuario sem acesso suficiente.\"", last_response.body
    #bad4
    authorize "admin","admin"
    get '/coords/0',:usuarioid=>"1"
    assert_equal last_response.body, "Not found\n"
  end
  #POST
  def test_create_coord
    #good
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Coord Test',:email=>"ct@ifpb.edu.br"}
    assert_equal last_response.body,"\"Coordenacao Criada.\""
    Coord.find_by('nome'=>'Coord Test').destroy
    #bad1
    authorize "",""
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Coord Test',:email=>"ct@ifpb.edu.br"}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    post '/coords',:coord=>{nome:'Coord Test',:email=>"ct@ifpb.edu.br"}
    assert_equal last_response.body,"Invalid\n"
    #bad3
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{:email=>"ct@ifpb.edu.br"}
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\"]"
    #bad4
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Coord Test'}
    assert_equal last_response.body,"[\"Email Blank: Can't be blank\"]"
    #bad5
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1"
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\",\"Email Blank: Can't be blank\"]"
    #bad6
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Coord Test',:email=>"coord3@ifpb.edu.br"}
    assert_equal last_response.body,"[\"Email Error: Email ja existe!\"]"
  end

  ###############LUGARES#######################
  #LIST
  def test_all_lugars
   	#good
  	authorize "admin","admin"
    get '/lugars'
    tmp = Lugar.all.length
    assert_equal JSON.parse(last_response.body).length, Lugar.all.length
  	#bad1
  	authorize "",""
    get '/lugars'
    tmp = Lugar.all.length
    assert_equal "Not authorized\n", last_response.body
    
  end
  #GET
  def test_one_lugars
   	#good
  	authorize "admin","admin"
    get '/lugars/1',:usuarioid=>"1"
    tmp = Lugar.all.length
    assert_equal JSON.parse(last_response.body)['nome'], 'L1'
  	#bad1
  	authorize "",""
    get '/lugars/1',:usuarioid=>"1"
    tmp = Lugar.all.length
    assert_equal "Not authorized\n", last_response.body
    #bad2
    authorize "admin","admin"
    get '/lugars/1'
    assert_equal "Invalid\n", last_response.body
    #bad3
    authorize "admin","admin"
    get '/lugars/1',:usuarioid=>"2"
    assert_equal "\"Usuario sem acesso suficiente.\"", last_response.body
    #bad4
    authorize "admin","admin"
    get '/lugars/0',:usuarioid=>"1"
    assert_equal last_response.body, "Not found\n"
  end
  #POST
  def test_create_lugar
    #good
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Lugar Test',:quantidade=>500}
    assert_equal last_response.body,"\"Lugar Criado.\""
    Lugar.find_by('nome'=>'Lugar Test').destroy
    #bad1
    authorize "",""
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Lugar Test',:quantidade=>500}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    post '/lugars',:lugar=>{nome:'Lugar Test',:quantidade=>500}
    assert_equal last_response.body,"Invalid\n"
    # #bad3
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{:quantidade=>500}
    assert_equal last_response.body,"[\"Nome can't be blank\"]"
    #bad4
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Lugar Test'}
    assert_equal last_response.body,"[\"Quantidade is not a number\"]"
    #bad5
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Lugar Test',:quantidade=>'vinte'}
    assert_equal last_response.body,"[\"Quantidade is not a number\"]"
    #bad6
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1"
    assert_equal last_response.body,"[\"Nome can't be blank\",\"Quantidade is not a number\"]"
  end

  ###############USUARIOS#######################
  #LIST
  def test_all_usuarios
  	#good
  	authorize "admin","admin"
    get '/usuarios',:usuarioid=>"1"
    tmp = Usuario.all.length
    assert_equal JSON.parse(last_response.body).length, Usuario.all.length
  	#bad1
  	authorize "",""
    get '/usuarios',:usuarioid=>"1"
    tmp = Usuario.all.length
    assert_equal "Not authorized\n", last_response.body
    #bad2
    authorize "admin","admin"
    get '/usuarios'
    tmp = Usuario.all.length
    assert_equal "Invalid\n", last_response.body
    #bad3
    authorize "admin","admin"
    get '/usuarios',:usuarioid=>"2"
    assert_equal "\"Usuario sem acesso suficiente.\"", last_response.body
  end
  #GET
  def test_one_usuarios
   	#good
  	authorize "admin","admin"
    get '/usuarios/1',:usuarioid=>"1"
    assert_equal JSON.parse(last_response.body)['nome'], 'Admin'
  	#bad1
  	authorize "",""
    get '/usuarios/1',:usuarioid=>"1"
    assert_equal "Not authorized\n", last_response.body
    #bad2
    authorize "admin","admin"
    get '/usuarios/1',:usuarioid=>"2"
    assert_equal "\"Usuario sem acesso suficiente.\"", last_response.body
   	#bad3
    authorize "admin","admin"
    get '/usuarios/0',:usuarioid=>"1"
    assert_equal last_response.body, "Not found\n"
  end
  #POST
  def test_create_usuario
    #good
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Usuario Test',:email=>'usuarioteste@ifpb.edu.br',:matricula=>'123'}
    assert_equal last_response.body,"\"Usuario Criado.\""
    Usuario.find_by('nome'=>'Usuario Test').destroy
    #good1
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Usuario Test',:email=>'usuarioteste@ifpb.edu.br'}
    assert_equal last_response.body,"\"Usuario Criado.\""
    Usuario.find_by('nome'=>'Usuario Test').destroy
    #bad1
    authorize "",""
    post '/usuarios',:usuario=>{nome:'Usuario Test',:email=>'usuarioteste@ifpb.edu.br',:matricula=>'123'}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    post '/usuarios',:usuario=>{:email=>'usuarioteste@ifpb.edu.br',:matricula=>'123'}
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\"]"
    # #bad3
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Usuario Test',:matricula=>'123'}
    assert_equal last_response.body,"[\"Email Blank: Can't be blank\"]"
    #bad4
    authorize "admin","admin"
    post '/usuarios',:usuarioid=>"1"
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\",\"Email Blank: Can't be blank\"]"
    #bad5
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Usuario Test',:email=>'admin@ifpb.edu.br'}
    assert_equal last_response.body,"[\"Email Error: Email ja existe!\"]"
  end

  #################SERVICOS########################
  #LIST
  def test_all_servicos
   	#good
  	authorize "admin","admin"
    get '/servicos'
    tmp = Servico.all.length
    assert_equal JSON.parse(last_response.body).length, Servico.all.length
  	#bad1
  	authorize "",""
    get '/servicos'
    tmp = Servico.all.length
    assert_equal "Not authorized\n", last_response.body
  end
  #GET
  def test_one_servicos
  	#good
  	authorize "admin","admin"
    get '/servicos/1',:usuarioid=>"1"
    tmp = Lugar.all.length
    assert_equal JSON.parse(last_response.body)['nome'], 'S1'
  	#bad1
  	authorize "",""
    get '/servicos/1',:usuarioid=>"1"
    tmp = Lugar.all.length
    assert_equal "Not authorized\n", last_response.body
    #bad2
    authorize "admin","admin"
    get '/servicos/1'
    assert_equal "Invalid\n", last_response.body
    #bad3
    authorize "admin","admin"
    get '/servicos/1',:usuarioid=>"2"
    assert_equal "\"Usuario sem acesso suficiente.\"", last_response.body
    #bad4
    authorize "admin","admin"
    get '/servicos/0',:usuarioid=>"1"
    assert_equal last_response.body, "Not found\n"
  end
  #POST
  def test_create_servicos
    #good
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Servico Test',:tempo=>50,:coord_id=>3}
    assert_equal last_response.body,"\"Servico Criado.\""
    Servico.find_by('nome'=>'Servico Test').destroy
    #bad1
    authorize "",""
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Servico Test',:tempo=>50,:coord_id=>3}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    post '/servicos',:servico=>{nome:'Servico Test',:tempo=>50,:coord_id=>3}
    assert_equal last_response.body,"Invalid\n"
    #bad3
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{:tempo=>50,:coord_id=>3}
    assert_equal last_response.body,"[\"Nome can't be blank\"]"
    #bad4
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Servico Test',:coord_id=>3}
    assert_equal last_response.body,"[\"Tempo is not a number\"]"
    #bad5
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Servico Test',:tempo=>"vinte",:coord_id=>3}
    assert_equal last_response.body,"[\"Tempo is not a number\"]"
    #bad6
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1"
    assert_equal last_response.body,"[\"Tempo is not a number\",\"Nome can't be blank\"]"
    
  end
  #############EVENTOS###############
  def test_all_events
  	#good
  	authorize "admin","admin"
    get '/eventos'
    tmp = Evento.all.length
    assert_equal JSON.parse(last_response.body).length, Evento.all.length
    #bad
    authorize "",""
    get '/eventos'
    tmp = Evento.all.length
    assert_equal "Not authorized\n", last_response.body
  end

  def test_one_events
  	#good
  	authorize "admin","admin"
    get '/eventos/1'
    assert_equal JSON.parse(last_response.body)['nome'], 'E1'
    #bad
    get '/eventos/0'
    assert_equal last_response.body, "Not found\n"
   end
end