class Usuario <ActiveRecord::Base
    has_many :eventos
    
    validates :nome, :email, :matricula, presence: true
end