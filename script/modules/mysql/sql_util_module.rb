module SqlUtil

  def is_support_column_type(column_type)
    column_type = remove_size_from_column_type(column_type)
    case column_type
      when "INTEGER"
        return true
      when "BIGINT"
        return true
      when "TINYINT"
        return true
      when "CHAR"
        return true
      when "VARCHAR"
        return true
      when "TEXT"
        return true
      when "DATE"
        return true
      when "DATETIME"
        return true
      else
        raise ArgumentError, "サポートされていない型が指定されています" + column_type
    end
  end

  def is_string_type(column_type)
    column_type = remove_size_from_column_type(column_type)
    is_support_column_type(column_type)
    case column_type
      when "CHAR"
        return true
      when "VARCHAR"
        return true
      when "TEXT"
        return true
      when "DATE"
        return true
      when "DATETIME"
        return true
      else
        return false
    end
  end

  def is_support_column_option_type(option_type)
    case option_type
      when "AUTO_INCREMENT"
        return true
      when "NULL"
        return true
      when "NOT NULL"
        return true
      when "unsigned"
        return true
      else
        if option_type.include?("DEFAULT ")
          return true
        else
          return false
        end
    end
  end

  def is_support_table_option_type(option_type)
    case option_type
      when "PRIMARY_KEY"
        return true
      when "INDEX_KEY"
        return true
      when "AUTO_INCREMENT"
        return true # primary_key
      else
        return false
    end
  end

  def is_primary_key(table_option_type)
    case table_option_type
      when "PRIMARY_KEY"
        return true
      when "AUTO_INCREMENT"
        return true # primary_key
      else
        return false
    end
  end

  def is_index_key(table_option_type)
    case table_option_type
      when "INDEX_KEY"
        return true
      else
        return false
    end
  end

  def is_unique_key(table_option_type)
    case table_option_type
      when "UNIQUE_KEY"
        return true
      else
        return false
    end
  end

  def add_single_quatation_for_string(value, column_type)
    if value.include?("\n")
      value = value.gsub("\n",'\n')
    end
    if is_string_type(column_type)
      return "\'" + value + "\'"
    else
      return value
    end
  end

  def remove_size_from_column_type(column_type)
    return column_type.gsub(/\(.*\)/, "")
  end

  def convert_ddl_to_sql(ddl)
    return ddl.gsub(/\r\n|\r|\n|\t/, "")
  end

end
