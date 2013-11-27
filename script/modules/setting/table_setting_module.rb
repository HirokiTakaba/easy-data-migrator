module TableSetting

  def is_ignore_table(file, settings)
    ignore_tables = settings['datastore_setting']['ignore_tables']
    ignore_tables.each do |ignore_table|
      if file.include?(ignore_table)
        return true
      end
    end
    return false
  end

  def is_insert_only_table(file, settings)
    insert_only_tables = settings['datastore_setting']['insert_only_tables']
    insert_only_tables.each do |insert_only_table|
      if file.include?(insert_only_table)
        return true
      end
    end
    return false
  end

end