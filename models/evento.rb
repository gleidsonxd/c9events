class Evento <ActiveRecord::Base
    belongs_to :usuario
    has_and_belongs_to_many :lugars
    has_and_belongs_to_many :servicos
    
    validates :nome,  presence: true
        
end