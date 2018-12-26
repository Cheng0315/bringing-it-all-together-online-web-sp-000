class Dog
  attr_accessor :name, :breed, :id

  def initialize(attr_hash)
    attr_hash.each {|k, v| self.send(("#{k}="), v)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
    end
  end

  def self.create(attr_hash)
    dog = Dog.new(attr_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten

    hash = {id: row[0], name: row[1], breed: row[2]}

  end
end
