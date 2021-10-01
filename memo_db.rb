# frozen_string_literal: true

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
    sql = 'CREATE TABLE IF NOT EXISTS memos
          ( id      SERIAL,
            title   VARCHAR(30)  NOT NULL,
            body    VARCHAR(500),
            PRIMARY KEY (id)
          )'
    @conn.exec(sql)
  end

  def select(id)
    sql = 'SELECT title, body FROM memos WHERE id = $1'
    result = @conn.exec_params(sql, [id])
    result[0]
  end

  def select_all
    # memos = {}
    sql = 'SELECT * FROM memos ORDER BY id'
    result = @conn.exec(sql)
    result.to_h do |tuple|
      [tuple['id'], { 'title' => tuple['title'], 'body' => tuple['body'] }]
    end
    # memos
  end

  def insert(title, body)
    sql = 'INSERT INTO memos (title, body) VALUES ($1, $2)'
    deallocate_statement
    @conn.prepare('statement', sql)
    @conn.exec_prepared('statement', [title, body])
  end

  def delete(id)
    sql = 'DELETE FROM memos WHERE id = $1'
    @conn.exec_params(sql, [id])
  end

  def update(id, title, body)
    sql = 'UPDATE memos SET (title, body) = ($1, $2) WHERE id = $3'
    deallocate_statement
    @conn.prepare('statement', sql)
    @conn.exec_prepared('statement', [title, body, id])
  end
end
