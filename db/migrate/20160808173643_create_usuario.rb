class CreateUsuario < ActiveRecord::Migration
  def up
    create_table :usuarios do |t|
            t.string :nome
            t.string :email
            t.string :matricula
            t.boolean :admin,default: false
            t.boolean :tcoord,default: false
           
            t.timestamps
      end
      
    Usuario.create  nome: 'Administrador',
                    email: 'eventos-jp@ifpb.edu.br',
                    matricula: '00000',
                    admin: true,
                    tcoord: false
  end
 

  def down
    drop_table :usuarios
  end
end
