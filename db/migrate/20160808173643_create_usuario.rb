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
  end
  
  def down
  end
end
