# rerun "ruby app.rb"
require "sinatra"
require "sinatra/cors"
require "sqlite3"

db = SQLite3::Database.open "teashop.db"
GENERIC_TEA_SELECT = "SELECT teas.id,teas.name,description,image,link,price,tea_types.name AS type FROM teas 
INNER JOIN tea_types on teas.type_id=tea_types.id "

set :allow_origin, "*"
set :port, 3000
before do
  content_type :json
end
get "/teaTypes" do
    db.results_as_hash = false
    teaItems = []
    db.execute( "SELECT name from tea_types" ) do |teaItem|
      teaItems += teaItem
    end

    teaItems.to_json
end
get "/teas" do
    db.results_as_hash = true
    teaItems = []
    db.execute( GENERIC_TEA_SELECT ) do |teaItem|
      teaItems.push(teaItem)
    end

    teaItems.to_json
end
get "/teas/featured" do
  db.results_as_hash = true
  teaItems = []
  db.execute( GENERIC_TEA_SELECT + "WHERE price > 50" ) do |teaItem|
    teaItems.push(teaItem)
  end
  
  teaItems.to_json
end
get "/teas/:id" do |id|
    db.results_as_hash = true
    stm = db.prepare( GENERIC_TEA_SELECT + "WHERE teas.id=?" )
    stm.bind_param 1, id
    tea = stm.execute.next
    if tea
      tea.to_json
    else
      halt 400, {'Content-Type' => 'text/plain'}, 'bad input parameter'
    end
end