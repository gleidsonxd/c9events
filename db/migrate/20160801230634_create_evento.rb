class CreateEvento < ActiveRecord::Migration
    def up
        create_table :eventos do |t|
            t.string :nome
            t.text :descricao
            t.date :data_ini
            t.date :data_fim
            t.belongs_to :usuario, index: true
            
            t.timestamps
        end
    end
  
  def down 
        drop_table :eventos
  end
end
