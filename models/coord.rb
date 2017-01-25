class Coord <ActiveRecord::Base
    has_many :servicos
    
    validates :nome, :email, presence: { message: "Blank: Can't be blank" }
    validates :email, uniqueness: { case_sensitive: false, message: "Error: Email ja existe!" }
end