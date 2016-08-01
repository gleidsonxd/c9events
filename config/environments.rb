#The enviroment variable DATABASE_URL should ve in the following format:
# => postgres://{user}:{password}@host:{port}path
configure :production, :development do
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres:localhost/eventosdb')
    
    ActiveRecord::Base.establish_connection(
                    :adapter     => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
                    :host       => db.host,
                    :username   => db.user,
                    :password   => db.password,
                    :database   => db.path,
                    :encoding   =>'utf8'
    )
end