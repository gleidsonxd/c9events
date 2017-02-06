ENV['RACK_ENV'] = 'test'

require_relative "app"
require "test/unit"
require "rack/test"
require "json"

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  
   ###############COORDS###########################
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
  ###############LUGARES#######################
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

  ###############USUARIOS#######################
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

  #################SERVICOS########################
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