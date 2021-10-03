# frozen_string_literal: true

class MemoDB
  def initialize(database)
    @conn = PG.connect(dbname: database)
    create_table
    @conn.prepare('select_statement', 'SELECT title, body FROM memos WHERE id = $1')
    @conn.prepare('select_all_statement', 'SELECT * FROM memos ORDER BY id')
    @conn.prepare('insert_statement', 'INSERT INTO memos (title, body) VALUES ($1, $2)')
    @conn.prepare('delete_statement', 'DELETE FROM memos WHERE id = $1')
    @conn.prepare('update_statement', 'UPDATE memos SET (title, body) = ($1, $2) WHERE id = $3')
  end

  def create_table
    sql = <<~SQL
      CREATE TABLE IF NOT EXISTS memos
      ( id      SERIAL,
        title   VARCHAR(30)  NOT NULL,
        body    VARCHAR(500),
        PRIMARY KEY (id)
      )
    SQL
    @conn.exec(sql)
  end

  def select(id)
    result = @conn.exec_prepared('select_statement', [id])
    result.first
  end

  def select_all
    result = @conn.exec_prepared('select_all_statement')
    result.to_h do |tuple|
      [tuple['id'], { 'title' => tuple['title'], 'body' => tuple['body'] }]
    end
  end

  def insert(title, body)
    @conn.exec_prepared('insert_statement', [title, body])
  end

  def delete(id)
    @conn.exec_prepared('delete_statement', [id])
  end

  def update(id, title, body)
    @conn.exec_prepared('update_statement', [title, body, id])
  end
end
