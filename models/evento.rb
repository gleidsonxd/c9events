class Evento <ActiveRecord::Base
    belongs_to :usuario
    has_and_belongs_to_many :lugars
    has_and_belongs_to_many :servicos
    
    #validates :nome,  presence: true
    
   # attr_accessor :servico, :servico_tempo, :servico_id, :servico_ids, :lugar, :lugar_id, :lugar_ids
    #attr_accessor :servicos_attributes, :lugars_attributes
    
   
   
    
    accepts_nested_attributes_for :servicos, allow_destroy: true 
        
end