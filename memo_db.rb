class MemoDB
  def initialize(database)
    @conn = PG.connect(dbname: database)
    create_table
  end

  def deallocate_statement
    sql = 'DEALLOCATE ALL'
    @conn.exec(sql)
  end

  def create_table
    sql = 'CREATE TABLE IF NOT EXISTS Memos
          ( memo_id SERIAL,
            title   VARCHAR(30)  NOT NULL,
            body    VARCHAR(500),
            PRIMARY KEY (memo_id)
          )'
    @conn.exec(sql)
  end

  def select(memo_id)
    sql = 'SELECT title, body FROM Memos WHERE memo_id = $1'
    result = @conn.exec_params(sql, [memo_id])
    result[0]
  end

  def select_all
    memos = {}
    sql = 'SELECT * FROM Memos ORDER BY memo_id'
    result = @conn.exec(sql)
    result.each do |tuple|
      memos[tuple['memo_id']] = { 'title' => tuple['title'], 'body' => tuple['body'] }
    end
    memos
  end

  def insert(title, body)
    sql = 'INSERT INTO Memos (title, body) VALUES ($1, $2)'
    deallocate_statement
    @conn.prepare('statement', sql)
    @conn.exec_prepared('statement', [title, body])
  end

  def delete(memo_id)
    sql = 'DELETE FROM Memos WHERE memo_id = $1'
    @conn.exec_params(sql, [memo_id])
  end

  def update(memo_id, title, body)
    sql = 'UPDATE Memos SET (title, body) = ($1, $2) WHERE memo_id = $3'
    deallocate_statement
    @conn.prepare('statement', sql)
    @conn.exec_prepared('statement', [title, body, memo_id])
  end
end
