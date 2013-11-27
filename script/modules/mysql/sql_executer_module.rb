module SqlExecuter

  def execute(ddl, settings)
    sql = SqlUtil.convert_ddl_to_sql(ddl)
    puts ddl
    begin
      con = Mysql.connect(settings['mysql']['hostname'],
                          settings['mysql']['username'],
                          settings['mysql']['password'],
                          settings['mysql']['database'],
                          settings['mysql']['port']
      )
      con.charset = settings['mysql_setting']['charactor_set']
      con.query("START TRANSACTION")
      con.query(sql)
      con.commit
    rescue => e
      con.rollback
      raise e
    ensure
      con.close if con
    end
  end

end
