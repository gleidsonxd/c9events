class Usuario <ActiveRecord::Base
    has_many :eventos
    
    validates :nome, :matricula, :email, presence: { message: "Blank: Can't be blank" }
    validates :email, uniqueness: { case_sensitive: false, message: "Error: Email ja existe!" }
end