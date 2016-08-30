class Coord <ActiveRecord::Base
    has_many :servicos
    
    validates :nome, presence: true
end