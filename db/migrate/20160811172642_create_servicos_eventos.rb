class CreateServicosEventos < ActiveRecord::Migration
  def up
      create_table :servicos_eventos, id: false do |t|
        t.belongs_to :servico, index: true
        t.belongs_to :event, index: true
      end
  end
  
  def down
      drop_table :servicos_eventos
  end
end
