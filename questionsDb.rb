require "singleton"
require "sqlite3"

class QuestionsDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('aa_questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Questions
  attr_accessor :title, :body
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map {|datum| Questions.new(datum)}
  end
  
  def self.find_by_id(id)
    users = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless users.length > 0
    
    Users.new(users.first)
  end
end

class Users
  attr_accessor :fname, :lname
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map {|datum| Users.new(datum)}
  end
  
  def self.find_by_id(id)
    users = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless users.length > 0
    
    Users.new(users.first)
  end
end
