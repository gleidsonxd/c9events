class CreateUsuario < ActiveRecord::Migration
  def up
    create_table :usuarios do |t|
            t.string :nome
            t.string :email
            t.string :matricula
            
           
            t.timestamps
      end
  end
  
  def down
  end
end
