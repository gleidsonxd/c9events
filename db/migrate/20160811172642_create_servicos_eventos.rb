class CreateServicosEventos < ActiveRecord::Migration
  def up
      create_table :eventos_servicos, id: false do |t|
        t.belongs_to :servico, index: true
        t.belongs_to :evento, index: true
      end
  end
  
  def down
      drop_table :eventos_servicos
  end
end
