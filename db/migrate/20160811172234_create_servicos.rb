class CreateServicos < ActiveRecord::Migration
  def up
      create_table :servicos do |t|
          t.integer :tempo
          t.string :nome
          t.belongs_to :coord, index: true
      end
  end
  
  def down
      drop_table :servicos
  end
end
