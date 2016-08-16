class CreateLugares < ActiveRecord::Migration
  def up
       create_table :lugars do |t|
          t.string :nome
          t.integer :quantidade 
          t.belongs_to :evento, index: true
      end
  end
  
  def down
      drop_table :lugars
  end
end
