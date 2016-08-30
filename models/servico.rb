class Servico <ActiveRecord::Base
    has_and_belongs_to_many :eventos
    belongs_to :coord
    
    validates :tempo, numericality: {only_integer: true}
    validates :nome, presence: true
    
end