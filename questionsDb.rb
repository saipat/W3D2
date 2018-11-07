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
  attr_accessor :title, :body, :user_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end
  
  def self.find_by_user_id(user_id)
    user_id = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT 
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    return nil unless user_id.length > 0
    
    Questions.new(user_id.first)
  end
  
  def self.find_by_question_id(id)
    question_id = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless question_id.length > 0
    
    Questions.new(question_id.first)
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end
  
  def author
    Users.find_by_id(@id)
  end
  
  def replies
    Replies.find_by_question_id(@id)
  end
end

class Users
  attr_accessor :fname, :lname
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
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
  
  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT 
        *
      FROM
        users
      WHERE
        fname = ?, lname = ?
    SQL
    return nil unless users.length > 0
    
    Users.new(users.first)
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def authored_questions
    Questions.find_by_user_id(@id)
  end
  
  def authored_replies
    Replies.find_by_user_id(@id)
  end
end

class QuestionsFollows
  attr_accessor :user_id, :question_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionsFollows.new(datum) }
  end
  
  def self.find_by_id(user_id)
    question_follows = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT 
        *
      FROM
        question_follows
      WHERE
        user_id = ?
    SQL
    return nil unless question_follows.length > 0
    
    QuestionsFollows.new(question_follows.first)
  end
  
  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        users ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL
    return nil unless followers.length > 0
    
    arr = []
    followers.each do |user|
      arr << Users.new(user)
    end
    
    arr
  end
  
  def self.followers_for_user_id(user_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL
    return nil unless followers.length > 0
    
    arr = []
    followers.each do |question|
      arr << Questions.new(question)
    end
    
    arr
  end
  
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

class Replies
  attr_accessor :body, :question_id, :reply_id, :user_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Replies.new(datum) }
  end
  
  def self.find_by_id(id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless replies.length > 0
    
    Replies.new(replies.first)
  end
  
  def self.find_by_user_id(user_id)
    user_id = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT 
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless user_id.length > 0
    
    Replies.new(user_id.first)
  end
  
  def self.find_by_question_id(question_id)
    question_id = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless question_id.length > 0
    
    Replies.new(question_id.first)
  end
  
  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
  end
  
  def author
    Users.find_by_id(@id)
  end
  
  def question
    Questions.find_by_question_id(@id)
  end
  
  def parent_reply
    parent_reply = QuestionsDatabase.instance.execute(<<-SQL, @reply_id)
      SELECT 
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless parent_reply.length > 0
    
    Replies.new(parent_reply.first)
  end
  
  def child_replies
    child_reply = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT 
        *
      FROM
        replies
      WHERE
        reply_id = ?
    SQL
    return nil unless child_reply.length > 0
    
    arr = []
    child_reply.each do |reply|
      arr << Replies.new(reply)
    end
    
    arr
  end
end

class QuestionLikes
  attr_accessor :user_id, :question_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLikes.new(datum) }
  end
  
  def self.find_by_id(id)
    question_likes = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil unless question_likes.length > 0
    
    QuestionLikes.new(question_likes.first)
  end
  
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
