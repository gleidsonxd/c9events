# Eventos API

##Eventos

###Create

Para criar um evento, deve-se enviar alguns parametros:

```
param nome,        String,          required, nome do evento
param dataIni,     String,          required, no formato dd/MM/yyyy HH:mm
param dataFim,     String,          required, no formato dd/MM/yyyy HH:mm. Fazer validação das datas.
param desc,        String,                    a descrição do sistema
param user_id,     Int,                       id do usuario que está solicitando a criação do evento
```  
  
```
POST /eventos
curl -d "evento[user_id]=1&evento[nome]=Evento tal&evento[dataIni]=10/10/2010 09:00&evento[dataFim]=10/10/2010 12:00&evento[desc]=Descricao Tall" localhost:3000/eventos

Retorna o ID do evento criado:
HTTP/1.1 200 Ok
{
 "id":"1"
 "message":"evento criado com sucesso"
}
```
---

###Update

O usuario que criar um evento tambem vai poder alterar esse evento. Para atualizar um evento, deve-se enviar alguns parametros:

```
param id           Int              required, id do evento
param nome,        String,          required, nome do evento
param dataIni,     String,          required, no formato dd/MM/yyyy HH:mm
param dataFim,     String,          required, no formato dd/MM/yyyy HH:mm. Fazer validação das datas.
param desc,        String,                    a descrição do evento
param user_id,     Int,                       id do usuario que alterou o evento
```  

```
PUT /eventos
curl -X PUT -d "evento[nome]=Evento_Mod&evento[dataIni]=10/10/2010 09:00&evento[dataFim]=10/10/2010 12:00&evento[desc]=Descricao Tall_mod&evento[user_id]=1" localhost:3000/eventos/2


Retorna o ID do evento alterado:
HTTP/1.1 200 Ok
{
 "id":"2"
 "message":"evento alterado com sucesso"
}
```
---
###Delete

Um usuario pode apagar um evento que ele criou.

```
DELETE /eventos
curl -X DELETE localhost:3000/eventos/2

Retorna a mensagem de sucesso:
HTTP/1.1 200 Ok
{
 
 "message":"Evento excluido com sucesso"
}
```
---
###Read

O usuario vai poder ver os detalhes dos eventos que criou.Para ver um evento, deve-se acessar a URL:

```
GET/eventos/2

curl localhost:3000/eventos/2

Retorna o JSON:
HTTP/1.1 200 Ok
[
  "evento":{"nome":"nome_evento","dataIni":"10/10/2010 09:00","dataFim":"10/10/2010 12:00","desc": "Descricao Tall"}}
]

```
---
###List
O usuario vai poder ver todos os eventos cadastrados.Para ver os eventos, deve-se acessar a URL:

```
GET/eventos

curl localhost:3000/eventos

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"evento":{"nome":"nome_evento", "dataIni":"10/10/2010 09:00","dataFim":"10/10/2010 12:00","desc": "Descricao Tall"}},
  {"evento":{"nome":"nome_evento2","dataIni":"11/10/2010 09:00","dataFim":"12/10/2010 12:00","desc": "Descricao"}},
  {"evento":{"nome":"nome_evento3","dataIni":"12/10/2010 09:00","dataFim":"13/10/2010 12:00","desc": "Descricao"}}
  
]

```
---

##Serviço

###Create

Um serviço é alocado para os eventos. Eles compoem as coisas necessárias para que o evento aconteça. Exemplo: banner, folder, divulgação no site do instituto, filmagens, etc.
Se for criar um evento que precise de um serviço, é necessário criar os serviços primeiro e enviar os ids para o método de criar eventos.
Os serviços não são obrigatórios para a criação de um evento. Os eventos podem ser independentes.
Para criar um serviço, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome do evento
param tempo,       Int,         required, tempo para o servico ficar pronto. Tempo em dias
param coord_id,    Int       required,  id da coordenacao que oferece o servico
```  

```
POST /servicos
curl -d "servico[nome]=Nome_Servico&servico[tempo]=15&servico[coord_id]=1"localhost:3000/servicos

Retorna o ID do servico criado:
HTTP/1.1 200 Ok
{
 "id":"1"
 "message":"servico criado com sucesso"
}
```
---
###Update

O usuario administrador vai poder alterar os serviços. Para atualizar um serviço, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome do evento
param tempo,       Int,         required, tempo para o servico ficar pronto. Tempo em dias
param coord_id     Int,         required, id da coordenação.
```  

```
PUT /servicos/2
curl -X PUT -d "servico[nome]=Nome_Servico_Mod&servico[tempo]=20"localhost:3000/servicos/2


Retorna o ID do serviço alterado:
HTTP/1.1 200 Ok
{
 "id":"2"
 "message":"serviço alterado com sucesso"
}
```
---
###Delete

Um usuario administrador pode apagar um serviço.

```
DELETE /servicos
curl -X DELETE localhost:3000/servicos/2

Retorna a mensagem de sucesso:
HTTP/1.1 200 Ok
{
 
 "message":"Serviço excluido com sucesso"
}
```
---
###Read

O administrador vai poder ver um serviço específico.Para ver um serviço, deve-se acessar a URL:

```
GET/servicos/1

curl localhost:3000/servicos/1

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"servicos":{"nome":"serv1","tempo":15,"coord":"coord eventos"}}
]

```
---
###List

O administrador vai poder ver todos os serviços cadastrados.Para ver os serviços, deve-se acessar a URL:

```
GET/servicos

curl localhost:3000/servicos

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"servicos":{"nome":"serv1","tempo":15,"coord":"coord eventos"}},
  {"servicos":{"nome":"serv2","tempo":25,"coord":"coord 2"}},
  {"servicos":{"nome":"serv3","tempo":30, "coord":"coord 3"}}
]

```
---
##Usuario

###Create

Os usuarios do sistema vão se logar utilizando o email institucional, na primeira que se logarem no sistema, irão completar seu cadastro no sistema. Para criar um usuario, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome do usuario
param email,       String,      required, email do usuario
```

```
POST /usuarios
curl -d "usuario[nome]=Nome_Usuario&usuario[email]=usuario@email.com"localhost:3000/usuarios

Retorna a mensagem de sucesso:
HTTP/1.1 200 Ok
{
  "message":"Usuario criado com sucesso"
}
```
---
###Update

O usuario vai poder alterar os dados do seu cadastro. Para atualizar um usuario, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome do usuario

```

```
PUT /usuarios/2
curl -X PUT -d "usuario[nome]=Nome_Usuario_Mod"localhost:3000/usuarios/2

Retorna a mensagem de sucesso:
HTTP/1.1 200 Ok
{
 
 "message":"Nome alterado com sucesso"
}
```
---
###Delete

Um usuario administrador pode apagar um usuario.

```
DELETE /usuarios
curl -X DELETE localhost:3000/usuarios/2

Retorna a mensagem de sucesso:
HTTP/1.1 200 Ok
{
 
 "message":"Usuario excluido com sucesso"
}
```
---
###Read

O administrador vai poder ver os dados de um usuário específico. Para ver um usuário, deve-se acessar a URL:

```
GET/usuarios/1

curl localhost:3000/usuarios/1

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"usuarios":{"nome":"nome_user","email":"user@email.com"}}    
]

```
---
###List

O administrador vai poder ver todos os usuários cadastrados. Para ver os usuários, deve-se acessar a URL:

```
GET/usuarios

curl localhost:3000/usuarios

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"usuarios":{"nome":"nome_user","email":"user@email.com"}},
  {"usuarios":{"nome":"nome_user2","email":"user2@email.com"}},
  {"usuarios":{"nome":"nome_user3","email":"user3@email.com"}}
]

```
---
##Lugar

###Create

É necessario cadastrar os lugares antes de se cadastrar um eventos. Para criar um lugar, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome do lugar
param qntPessoas,  Int,         required, quantidade de pessoas
```

```
POST /lugars
curl -d "lugar[nome]=Patio&lugar[qntPessoas]=150"localhost:3000/lugars

Retorna o ID do lugar criado:
HTTP/1.1 200 Ok
{
  "id":"1"
  "message":"Lugar criado com sucesso"
}
```
---
###Update

O usuario administrador vai poder alterar os dados dos locais cadastrados. Para atualizar um lugar, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome do lugar
param qntPessoas,  Int,         required, quantidade de pessoas

```

```

PUT /lugars/1
curl -X PUT -d "lugar[nome]=Patio&lugar[qntPessoas]=250"localhost:3000/lugars/1

Retorna o ID do lugar alterado:
HTTP/1.1 200 Ok
{
  "id":"1"
  "message":"Lugar alterado com sucesso"
}
```
---
###Delete

Um usuario administrador pode apagar um lugar cadastrado.

```
DELETE /lugars
curl -X DELETE localhost:3000/lugars/2

Retorna a mensagem de sucesso:
HTTP/1.1 200 Ok
{
 
 "message":"Lugar excluido com sucesso"
}
```
---
###Read

O administrador vai poder ver os dados de um lugar específico. Para ver um lugar, deve-se acessar a URL:

```
GET/lugars/1

curl localhost:3000/lugars/1

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"lugars":{"nome":"nome_lugar","qntPessoas":100}}       
]

```
---
###List

O administrador vai poder ver todos os lugares cadastrados. Para ver os lugares, deve-se acessar a URL:

```
GET/lugars

curl localhost:3000/lugars

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"lugars":{"nome":"nome_lugar","qntPessoas":100}},
  {"lugars":{"nome":"nome_lugar2","qntPessoas":140}},
  {"lugars":{"nome":"nome_lugar3","qntPessoas":150}}    
]

```
---

##Coordenação
###Create

É necessario cadastrar as coordenações antes de se cadastrar um serviço. Para criar uma coordenação, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome da coordenação
```

```
POST /coords
curl -d "nome=Coordenacao_eventos"localhost:3000/coords

Retorna o ID da coordenação criada:
HTTP/1.1 200 Ok
{
  "id":"1"
  "message":"Coordenação criada com sucesso"
}
```
---
###Update

O usuario administrado vai poder alterar os dados dos locais cadastrados. Para atualizar um lugar, deve-se enviar alguns parametros:

```
param nome,        String,      required, nome da coordenação

```

```
PUT /coords
curl -X PUT -d "id=1&nome=Coordenacao_eventos"localhost:3000/coords

Retorna o ID da coordenação alterada:
HTTP/1.1 200 Ok
{
  "id":"1"
  "message":"Coordenação alterada com sucesso"
}
```
---
###Delete

Um usuario administrador pode apagar uma coordenação cadastrada.

```
DELETE /coords
curl -X DELETE localhost:3000/coords/2

Retorna a mensagem de sucesso:
HTTP/1.1 200 Ok
{
 
 "message":"Coordenação excluida com sucesso"
}
```
---
###Read

O administrador vai poder ver os dados de uma coordenação específica. Para ver uma coordenação, deve-se acessar a URL:

```
GET/coords/1

curl localhost:3000/coords/1

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"coords":{"nome":"coord_eventos"}}       

]

```
---
###List

O administrador vai poder ver todas as coordenações cadastradas. Para ver as coordenações, deve-se acessar a URL:

```
GET/coords

curl localhost:3000/coords

Retorna o JSON:
HTTP/1.1 200 Ok
[
  {"coords":{"nome":"coord_eventos"}} 
  {"coords":{"nome":"coord2"}} 
  {"coords":{"nome":"coord3"}}       
]

```
---