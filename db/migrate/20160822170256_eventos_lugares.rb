class EventosLugares < ActiveRecord::Migration
  def up
      create_table :eventos_lugars, id: false do |t|
        t.belongs_to :lugar, index: true
        t.belongs_to :evento, index: true
      end
  end
  
  def down
      drop_table :eventos_lugars
  end
end
