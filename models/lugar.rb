class Lugar <ActiveRecord::Base
    has_and_belongs_to_many :eventos
    
    validates :nome, presence: true
    validates :quantidade, numericality:{ only_integer: true}
    
   
end