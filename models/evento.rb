class Evento <ActiveRecord::Base
    belongs_to :usuario
    has_many :lugares
    has_and_belongs_to_many :servicos
        
end