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
    #bad4
    authorize "admin","admin"
    get '/coords/1',:usuarioid=>"0"
    assert_equal "Invalid\n", last_response.body
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
    #bad2
    authorize "admin","admin"
    get '/coords/1',:usuarioid=>"0"
    assert_equal "Invalid\n", last_response.body
  end
  #POST
  def test_create_coords
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
    #bad7
    authorize "admin","admin"
    post '/coords',:usuarioid=>"0",:coord=>{nome:'Coord Test',:email=>"ct@ifpb.edu.br"}
    assert_equal last_response.body,"Invalid\n"
  end
  #PUT
  def test_update_coords
    #good
    authorize "admin","admin"
    put'/coords/2', :usuarioid=>"1",:coord=>{nome:'Coord 2 Test'}
    c = Coord.find_by('nome'=>'Coord 2 Test')
    r = JSON.parse(last_response.body)
    assert_equal c['nome'], r['nome']
    Coord.update(2,nome:'C2')
    #bad1
    authorize "",""
    put'/coords/2', :usuarioid=>"1",:coord=>{nome:'Coord 2 Test'}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    put'/coords/2', :coord=>{nome:'Coord 2 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad3
    authorize "admin","admin"
    put'/coords/2', :usuarioid=>"2",:coord=>{nome:'Coord 2 Test'}
    assert_equal last_response.body,"\"Usuario sem acesso suficiente.\""
    #bad4
    authorize "admin","admin"
    put'/coords/2', :usuarioid=>"1",:coord=>{email:'coord3@ifpb.edu.br'}
    assert_equal last_response.body,"[\"Email Error: Email ja existe!\"]"
    #bad5
    authorize "admin","admin"
    put'/coords/2', :usuarioid=>"1",:coord=>{nome:''}
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\"]"
    #bad6
    authorize "admin","admin"
    put'/coords/2', :usuarioid=>"1",:coord=>{email:''}
    assert_equal last_response.body,"[\"Email Blank: Can't be blank\"]"
    #bad7
    authorize "admin","admin"
    put'/coords/2', :usuarioid=>"1",:coord=>{nome:'',email:''}
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\",\"Email Blank: Can't be blank\"]"
    #bad8
    authorize "admin","admin"
    put'/coords/2',:usuarioid=>"0", :coord=>{nome:'Coord 2 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad9
    authorize "admin","admin"
    put'/coords/0', :usuarioid=>"1",:coord=>{nome:'Coord 2 Test'}
    assert_equal last_response.body,"Not found\n"
  end
  #DELETE
  def test_delete_coords
    #good
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Delete Coord',:email=>"delc@ifpb.edu.br"}
    i = Coord.find_by('nome'=>'Delete Coord').id
    delete "/coords/#{i}",:usuarioid=>"1"
    assert_equal "\"A coordenação foi removida\"", last_response.body
    assert Coord.find_by('nome'=>'Delete Coord').nil?
    #bad1
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Delete Coord',:email=>"delc@ifpb.edu.br"}
    i = Coord.find_by('nome'=>'Delete Coord').id
    authorize "",""
    delete "/coords/#{i}",:usuarioid=>"1"
    assert_equal "Not authorized\n", last_response.body
    Coord.find_by('nome'=>'Delete Coord').destroy
    assert Coord.find_by('nome'=>'Delete Coord').nil?
    #bad2
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Delete Coord',:email=>"delc@ifpb.edu.br"}
    i = Coord.find_by('nome'=>'Delete Coord').id
    delete "/coords/#{i}"
    assert_equal "Invalid\n", last_response.body
    Coord.find_by('nome'=>'Delete Coord').destroy
    assert Coord.find_by('nome'=>'Delete Coord').nil?
    #bad3
    authorize "admin","admin"
    post '/coords',:usuarioid=>"1",:coord=>{nome:'Delete Coord',:email=>"delc@ifpb.edu.br"}
    i = Coord.find_by('nome'=>'Delete Coord').id
    delete "/coords/0",:usuarioid=>"1"
    assert_equal "Not found\n", last_response.body
    Coord.find_by('nome'=>'Delete Coord').destroy
    assert Coord.find_by('nome'=>'Delete Coord').nil?
  end
  

  ###############LUGARES#######################
  #LIST
  def test_all_lugares
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
  def test_one_lugares
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
    #bad5
    authorize "admin","admin"
    get '/lugars/1', :usuarioid=>"0"
    assert_equal "Invalid\n", last_response.body
  end
  #POST
  def test_create_lugares
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
    #bad7
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"0",:lugar=>{nome:'Lugar Test',:quantidade=>500}
    assert_equal last_response.body,"Invalid\n"
    #bad8
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"2",:lugar=>{nome:'Lugar Test',:quantidade=>'vinte'}
    assert_equal last_response.body,"\"Usuario sem acesso suficiente.\""
end
  #PUT
  def test_update_lugares
    #good1
    authorize "admin","admin"
    put'/lugars/3', :usuarioid=>"1",:lugar=>{nome:'Lugar 3 Test', quantidade:350}
    l = Lugar.find_by('nome'=>'Lugar 3 Test')
    r = JSON.parse(last_response.body)
    assert_equal l['nome'], r['nome']
    Lugar.update(3,nome:'L3',quantidade:300)
    #good2
    authorize "admin","admin"
    put'/lugars/3', :usuarioid=>"1",:lugar=>{nome:'Lugar 3 Test'}
    l = Lugar.find_by('nome'=>'Lugar 3 Test')
    r = JSON.parse(last_response.body)
    assert_equal l['nome'], r['nome']
    Lugar.update(3,nome:'L3')
    #bad1
    authorize "",""
    put'/lugars/3', :usuarioid=>"1",:lugar=>{nome:'Lugar 3 Test'}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    put'/lugars/3', :lugar=>{nome:'Lugar 3 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad3
    authorize "admin","admin"
    put'/lugars/3',:usuarioid=>"0",:lugar=>{nome:'Lugar 3 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad4
    authorize "admin","admin"
    put '/lugars/3',:usuarioid=>"1",:lugar=>{quantidade:'vinte'}
    assert_equal last_response.body,"[\"Quantidade is not a number\"]"
    #bad5
    authorize "admin","admin"
    put '/lugars/3',:usuarioid=>"1",:lugar=>{nome:''}
    assert_equal last_response.body,"[\"Nome can't be blank\"]"
    #bad6
    authorize "admin","admin"
    put '/lugars/3',:usuarioid=>"2",:lugar=>{nome:'Lugar Test'}
    assert_equal last_response.body,"\"Usuario sem acesso suficiente.\""
    #bad7
    authorize "admin","admin"
    put '/lugars/3',:usuarioid=>"1", :lugar=>{nome:'',quantidade:''}
    assert_equal last_response.body,"[\"Nome can't be blank\",\"Quantidade is not a number\"]"
    #bad8
    authorize "admin","admin"
    put '/lugars',:usuarioid=>"2",:lugar=>{nome:'Lugar Test'}
    assert_equal last_response.body,"<h1>Not Found</h1>"
    #bad9
    authorize "admin","admin"
    put'/lugars/0',:usuarioid=>"1",:lugar=>{nome:'Lugar 3 Test'}
    assert_equal last_response.body,"Not found\n"
  end
  #DELETE
  def test_delete_lugares
    #good
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Delete Lugar',:quantidade=>500}
    i = Lugar.find_by('nome'=>'Delete Lugar').id
    delete "/lugars/#{i}",:usuarioid=>"1"
    assert_equal "\"O local foi removido\"", last_response.body
    assert Lugar.find_by('nome'=>'Delete Lugar').nil?
    #bad1
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Delete Lugar',:quantidade=>500}
    i = Lugar.find_by('nome'=>'Delete Lugar').id
    authorize "",""
    delete "/lugars/#{i}",:usuarioid=>"1"
    assert_equal "Not authorized\n", last_response.body
    Lugar.find_by('nome'=>'Delete Lugar').destroy
    assert Lugar.find_by('nome'=>'Delete Lugar').nil?
    #bad2
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Delete Lugar',:quantidade=>500}
    i = Lugar.find_by('nome'=>'Delete Lugar').id
    delete "/lugars/#{i}"
    assert_equal "Invalid\n", last_response.body
    Lugar.find_by('nome'=>'Delete Lugar').destroy
    assert Lugar.find_by('nome'=>'Delete Lugar').nil?
    #bad3
    authorize "admin","admin"
    post '/lugars',:usuarioid=>"1",:lugar=>{nome:'Delete Lugar',:quantidade=>500}
    i = Lugar.find_by('nome'=>'Delete Lugar').id
    delete "/lugars/0",:usuarioid=>"1"
    assert_equal "Not found\n", last_response.body
    Lugar.find_by('nome'=>'Delete Lugar').destroy
    assert Lugar.find_by('nome'=>'Delete Lugar').nil?
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
    #bad4
    authorize "admin","admin"
    get '/usuarios',:usuarioid=>"0"
    tmp = Usuario.all.length
    assert_equal "Invalid\n", last_response.body
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
    #bad3
    authorize "admin","admin"
    get '/usuarios/0',:usuarioid=>"0"
    assert_equal last_response.body, "Not found\n"
  end
  #POST
  def test_create_usuarios
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
    #good2
    post '/usuarios',:usuario=>{nome:'Usuario Coord Test',:email=>'coordtest@ifpb.edu.br',:tcoord=>true}
    assert_equal last_response.body,"\"Usuario Criado.\""
    Usuario.find_by('nome'=>'Usuario Coord Test').destroy
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
  #PUT
  def test_update_usuarios
    #good1
    authorize "admin","admin"
    put'/usuarios/2', :usuarioid=>"1",:usuario=>{nome:'Usuario 2 Test'}
    u = Usuario.find_by('nome'=>'Usuario 2 Test')
    r = JSON.parse(last_response.body)
    assert_equal u['nome'], r['nome']
    Usuario.update(2,nome:'noadmin')
    #good2
    authorize "admin","admin"
    put'/usuarios/2', :usuarioid=>"2",:usuario=>{nome:'Usuario 2 Test2'}
    u = Usuario.find_by('nome'=>'Usuario 2 Test2')
    r = JSON.parse(last_response.body)
    assert_equal u['nome'], r['nome']
    Usuario.update(2,nome:'noadmin')
    #bad1
    authorize "",""
    put'/usuarios/2', :usuarioid=>"1",:usuario=>{nome:'Usuario 2 Test'}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    put'/usuarios/2',:usuario=>{nome:'Usuario 2 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad3
    authorize "admin","admin"
    put'/usuarios/2',:usuario=>{nome:'Usuario 2 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad4
    authorize "admin","admin"
    put'/usuarios/2', :usuarioid=>"1",:usuario=>{nome:''}
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\"]"
    #bad5
    authorize "admin","admin"
    put'/usuarios/2', :usuarioid=>"1",:usuario=>{email:''}
    assert_equal last_response.body,"[\"Email Blank: Can't be blank\"]"
    #bad6
    authorize "admin","admin"
    put'/usuarios/2', :usuarioid=>"1",:usuario=>{email:'admin@ifpb.edu.br'}
    assert_equal last_response.body,"[\"Email Error: Email ja existe!\"]"
    #bad7
    authorize "admin","admin"
    put'/usuarios/2', :usuarioid=>"0",:usuario=>{email:'admin@ifpb.edu.br'}
    assert_equal last_response.body,"Not found\n"
    #bad8
    put'/usuarios/2', :usuarioid=>"5",:usuario=>{email:'admin@ifpb.edu.br'}
    assert_equal last_response.body,"\"Usuario sem acesso suficiente.\""
    #bad9
    authorize "admin","admin"
    put'/usuarios/0',:usuarioid=>"1",:usuario=>{nome:'Usuario 2 Test'}
    assert_equal last_response.body,"Not found\n"
  end
  #DELETE
  def test_delete_usuarios
    #good
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Delete Usuario',:email=>'usuariodelete@ifpb.edu.br',:matricula=>'123'}
    i = Usuario.find_by('nome'=>'Delete Usuario').id
    delete "/usuarios/#{i}",:usuarioid=>"1"
    assert_equal "\"O usuario foi removido\"", last_response.body
    assert Usuario.find_by('nome'=>'Delete Usuario').nil?
    #bad1
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Delete Usuario',:email=>'usuariodelete@ifpb.edu.br',:matricula=>'123'}
    i = Usuario.find_by('nome'=>'Delete Usuario').id
    authorize "",""
    delete "/usuarios/#{i}",:usuarioid=>"1"
    assert_equal "Not authorized\n", last_response.body
    Usuario.find_by('nome'=>'Delete Usuario').destroy
    assert Usuario.find_by('nome'=>'Delete Usuario').nil?
    #bad2
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Delete Usuario',:email=>'usuariodelete@ifpb.edu.br',:matricula=>'123'}
    i = Usuario.find_by('nome'=>'Delete Usuario').id
    delete "/usuarios/#{i}"
    assert_equal "Invalid\n", last_response.body
    Usuario.find_by('nome'=>'Delete Usuario').destroy
    assert Usuario.find_by('nome'=>'Delete Usuario').nil?
    #bad3
    authorize "admin","admin"
    post '/usuarios',:usuario=>{nome:'Delete Usuario',:email=>'usuariodelete@ifpb.edu.br',:matricula=>'123'}
    i = Usuario.find_by('nome'=>'Delete Usuario').id
    delete "/usuarios/0",:usuarioid=>"1"
    assert_equal "Not found\n", last_response.body
    Usuario.find_by('nome'=>'Delete Usuario').destroy
    assert Usuario.find_by('nome'=>'Delete Usuario').nil?
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
    #bad2
    authorize "admin","admin"
    get '/servicos/1',:usuarioid=>"0"
    assert_equal "Invalid\n", last_response.body
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
    #bad7
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"0",:servico=>{nome:'Servico Test',:tempo=>50,:coord_id=>3}
    assert_equal last_response.body,"Invalid\n"
  end
  #PUT
  def test_update_servicos
    #good1
    authorize "admin","admin"
    put'/servicos/4', :usuarioid=>"1",:servico=>{nome:'Serv 4 Test'}
    s = Servico.find_by('nome'=>'Serv 4 Test')
    r = JSON.parse(last_response.body)
    assert_equal s['nome'], r['nome']
    Servico.update(4,nome:'S4')
    #bad1
    authorize "",""
    put'/servicos/4', :usuarioid=>"1",:servico=>{nome:'Serv 4 Test'}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    put'/servicos/4',:servico=>{nome:'Serv 4 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad3
    authorize "admin","admin"
    put'/servicos/4',:usuarioid=>"0",:servico=>{nome:'Serv 4 Test'}
    assert_equal last_response.body,"Invalid\n"
    #bad4
    authorize "admin","admin"
    put'/servicos/0',:usuarioid=>"1",:servico=>{nome:'Serv 4 Test'}
    assert_equal last_response.body,"Not found\n"
    #bad4
    authorize "admin","admin"
    put'/servicos/4',:usuarioid=>"1",:servico=>{nome:''}
    assert_equal last_response.body,"[\"Nome can't be blank\"]"
    #bad5
    authorize "admin","admin"
    put'/servicos/4',:usuarioid=>"1",:servico=>{tempo:''}
    assert_equal last_response.body,"[\"Tempo is not a number\"]"
    #bad6
    put'/servicos/4',:usuarioid=>"2",:servico=>{nome:'Serv 4 Test'}
    assert_equal last_response.body,"\"Usuario sem acesso suficiente.\""
  end
  #DELETE
  def test_delete_servicos
    #good
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Delete Servico',:tempo=>50,:coord_id=>3}
    i = Servico.find_by('nome'=>'Delete Servico').id
    delete "/servicos/#{i}",:usuarioid=>"1"
    assert_equal "\"O servico foi removido\"", last_response.body
    assert Servico.find_by('nome'=>'Delete Servico').nil?
    #bad1
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Delete Servico',:tempo=>50,:coord_id=>3}
    i = Servico.find_by('nome'=>'Delete Servico').id
    authorize "",""
    delete "/servicos/#{i}",:usuarioid=>"1"
    assert_equal "Not authorized\n", last_response.body
    Servico.find_by('nome'=>'Delete Servico').destroy
    assert Servico.find_by('nome'=>'Delete Servico').nil?
    #bad2
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Delete Servico',:tempo=>50,:coord_id=>3}
    i = Servico.find_by('nome'=>'Delete Servico').id
    delete "/servicos/#{i}"
    assert_equal "Invalid\n", last_response.body
    Servico.find_by('nome'=>'Delete Servico').destroy
    assert Servico.find_by('nome'=>'Delete Servico').nil?
    #bad3
    authorize "admin","admin"
    post '/servicos',:usuarioid=>"1",:servico=>{nome:'Delete Servico',:tempo=>50,:coord_id=>3}
    i = Servico.find_by('nome'=>'Delete Servico').id
    delete "/servicos/0",:usuarioid=>"1"
    assert_equal "Not found\n", last_response.body
    Servico.find_by('nome'=>'Delete Servico').destroy
    assert Servico.find_by('nome'=>'Delete Servico').nil?
  end
  #############EVENTOS###############
  #LIST
  def test_all_eventos
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
  #GET
  def test_one_eventos
  	#good
  	authorize "admin","admin"
    get '/eventos/1'
    assert_equal JSON.parse(last_response.body)['nome'], 'E1'
    #bad
    get '/eventos/0'
    assert_equal last_response.body, "Not found\n"
   end
  #POST
  def test_create_eventos
    #good1 Craindo como usuario normal
    # authorize "admin","admin"
    # post '/eventos',:servicos=>"1,2",:lugares=>"1,2",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/17T12:00',:usuario_id=>2}
    # assert_equal last_response.body,"\"Evento Criado com Sucesso\""
    # Evento.find_by('nome'=>'Evento Test').destroy
    #good2
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Evento Test Ind',:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    assert_equal last_response.body,"\"Evento Criado com Sucesso\""
    Evento.find_by('nome'=>'Evento Test Ind').destroy
    #good3 Criando como Adm
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"1",:evento=>{nome:'Evento Test Admin',:data_ini=>'2017/01/16T11:00',:data_fim=>'2017/01/16T12:00',:usuario_id=>1}
    assert_equal last_response.body,"\"Evento Criado com Sucesso\""
    Evento.find_by('nome'=>'Evento Test Admin').destroy
    #bad1
    authorize "",""
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    post '/servicos',:servico=>{nome:'Servico Test',:tempo=>50,:coord_id=>3}
    assert_equal last_response.body,"Invalid\n"
    #bad3
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\"]"
    #bad4
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Evento Test',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    assert_equal last_response.body,"[\"Data ini Blank: Can't be blank\"]"
    #bad5
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/16T12:00',:usuario_id=>2}
    assert_equal last_response.body,"[\"Data fim Blank: Can't be blank\"]"
    #bad6 Com Admin
    authorize "admin","admin"
    post '/eventos',:servicos=>"0",:lugares=>"1,2",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/17T12:00',:usuario_id=>1}
    assert_equal last_response.body,"Serviço Not found\n"
    #bad7 Com Admin
    authorize "admin","admin"
    post '/eventos',:servicos=>"1",:lugares=>"0",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/17T12:00',:usuario_id=>1}
    assert_equal last_response.body,"Lugar Not found\n"
    #bad8 Com Admin
    authorize "admin","admin"
    post '/eventos',:servicos=>"0",:lugares=>"0",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/17T12:00',:usuario_id=>1}
    assert_equal last_response.body,"Lugar Not found\n"
    #bad9 Sem Admin
    authorize "admin","admin"
    post '/eventos',:servicos=>"0",:lugares=>"1,2",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/18T11:00',:data_fim=>'2017/02/18T12:00',:usuario_id=>2}
    assert_equal last_response.body,"Serviço Not found\n"
    #bad10 Sem Admin
    authorize "admin","admin"
    post '/eventos',:servicos=>"1",:lugares=>"0",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/17T12:00',:usuario_id=>2}
    assert_equal last_response.body,"Lugar Not found\n"
    #bad11 Sem Admin
    authorize "admin","admin"
    post '/eventos',:servicos=>"0",:lugares=>"0",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/17T12:00',:usuario_id=>2}
    assert_equal last_response.body,"Lugar Not found\n"
    #bad12
    authorize "admin","admin"
    post '/eventos',:servicos=>"3",:lugares=>"1,2",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/10T11:00',:data_fim=>'2017/02/10T12:00',:usuario_id=>2}
    assert_equal last_response.body,"[]"
    #bad13
    authorize "admin","admin"
    post '/eventos',:servicos=>"1",:lugares=>"1,2",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/17T12:00',:usuario_id=>2}
    assert_equal last_response.body,"[]"
    #bad14
    authorize "admin","admin"
    post '/eventos',:servicos=>"0",:lugares=>"1,2",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/18T12:00',:usuario_id=>2}
    assert_equal last_response.body,"[]"
    #bad15
    authorize "admin","admin"
    post '/eventos',:servicos=>"1",:lugares=>"0",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/18T12:00',:usuario_id=>2}
    assert_equal last_response.body,"Lugar Not found\n"
    #bad16
    authorize "admin","admin"
    post '/eventos',:servicos=>"0",:lugares=>"0",:evento=>{nome:'Evento Test',:data_ini=>'2017/02/17T11:00',:data_fim=>'2017/02/18T12:00',:usuario_id=>2}
    assert_equal last_response.body,"Lugar Not found\n"
  end
  #PUT
  def test_update_eventos
    #good1
    authorize "admin","admin"
    put'/eventos/354', :usuarioid=>"1",:evento=>{nome:'Evento Test'}
    e = Evento.find_by('nome'=>'Evento Test')
    r = JSON.parse(last_response.body)
    assert_equal e['nome'], r['nome']
    Evento.update(354,nome:'bad13')
    #bad0
    authorize "admin","admin"
    put'/eventos/354', :usuarioid=>"2",:evento=>{nome:'Evento Test'}
    assert_equal last_response.body, "[]"
    #bad1
    authorize "",""
    put'/eventos/354', :usuarioid=>"1",:evento=>{nome:'Evento Test'}
    assert_equal last_response.body,"Not authorized\n"  
    #bad2
    authorize "admin","admin"
    put'/eventos/354',:usuarioid=>"0",:evento=>{nome:'Evento Test'}
    assert_equal last_response.body,"Not found\n"
    #bad3
    authorize "admin","admin"
    put'/eventos/354',:evento=>{nome:'Evento Test'}
    assert_equal last_response.body,"Not found\n"
    #bad4
    authorize "admin","admin"
    put'/eventos/354',:usuarioid=>'1',:evento=>{nome:''}
    assert_equal last_response.body,"[\"Nome Blank: Can't be blank\"]"
    #bad5
    authorize "admin","admin"
    put'/eventos/354',:usuarioid=>'1',:evento=>{data_ini:''}
    assert_equal last_response.body,"[\"Data ini Blank: Can't be blank\"]"
    #bad6
    authorize "admin","admin"
    put'/eventos/354',:usuarioid=>'1',:evento=>{data_fim:''}
    assert_equal last_response.body,"[\"Data fim Blank: Can't be blank\"]"
    #bad7
    authorize "admin","admin"
    put'/eventos/354',:usuarioid=>'2',:evento=>{nome:'Teste mod'}
    assert_equal last_response.body,"[]"
  end
  #DELETE
  def test_delete_eventos
    #good
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Delete Evento',:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    i = Evento.find_by('nome'=>'Delete Evento').id
    delete "/eventos/#{i}",:usuarioid=>"1"
    assert_equal "\"O evento foi removido\"", last_response.body
    assert Evento.find_by('nome'=>'Delete Evento').nil?
    #bad1
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Delete Evento',:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    i = Evento.find_by('nome'=>'Delete Evento').id
    authorize "",""
    delete "/eventos/#{i}",:usuarioid=>"1"
    assert_equal "Not authorized\n", last_response.body
    Evento.find_by('nome'=>'Delete Evento').destroy
    assert Evento.find_by('nome'=>'Delete Evento').nil?
    #bad2
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Delete Evento',:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    i = Evento.find_by('nome'=>'Delete Evento').id
    delete "/eventos/#{i}"
    assert_equal "Invalid\n", last_response.body
    Evento.find_by('nome'=>'Delete Evento').destroy
    assert Evento.find_by('nome'=>'Delete Evento').nil?
    #bad3
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Delete Evento',:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    i = Evento.find_by('nome'=>'Delete Evento').id
    delete "/eventos/0",:usuarioid=>"1"
    assert_equal "Not found\n", last_response.body
    Evento.find_by('nome'=>'Delete Evento').destroy
    assert Evento.find_by('nome'=>'Delete Evento').nil?
    #bad4
    authorize "admin","admin"
    post '/eventos',:servicos=>"",:lugares=>"",:evento=>{nome:'Delete Evento',:data_ini=>'2017/02/16T11:00',:data_fim=>'2017/02/16T12:00',:usuario_id=>2}
    i = Evento.find_by('nome'=>'Delete Evento').id
    delete "/eventos/#{i}",:usuarioid=>"3"
    assert_equal "\"Error: Usuario NAO criou o evento e NAO é admin\"", last_response.body
    Evento.find_by('nome'=>'Delete Evento').destroy
    assert Evento.find_by('nome'=>'Delete Evento').nil?
  end
end