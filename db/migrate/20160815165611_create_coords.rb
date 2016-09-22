class CreateCoords < ActiveRecord::Migration
  def up
      create_table :coords do |t|
          t.string :nome
          t.string :email
      end
  end
  
  def down
      drop_table :coords
  end
end
