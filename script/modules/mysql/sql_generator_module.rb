module SqlGenerator

  FORMAT_COMMA = ", "
  FORMAT_UNDER_BAR = "_"
  FORMAT_SPACE = " "
  FORMAT_INDENT = "\t"
  FORMAT_LINE_BREAK = "\n"

  FORMAR_DROP_TABLE = "DROP TABLE IF EXISTS %s;" + FORMAT_LINE_BREAK
  FORMAT_START_CREATE_TABLE = "CREATE TABLE %s (" + FORMAT_LINE_BREAK + "%s"
  FORMAT_PRIMARY_KEY = "PRIMARY KEY (%s)"
  FORMAT_INDEX_KEY = "INDEX %s (%s)" + FORMAT_LINE_BREAK
  FORMAT_UNIQUE_KEY = "UNIQUE KEY %s (%s)" + FORMAT_LINE_BREAK
  FORMAT_END_CREATE_TABLE = ") CHARACTER SET %s COLLATE %s;" + FORMAT_LINE_BREAK
  FORMAT_DELETE = "DELETE FROM %s;"
  FORMAT_INSERT_COLUMN = "INSERT INTO %s (%s) "
  FORMAT_INSERT_VALUES_FIRST = "VALUES"+ FORMAT_LINE_BREAK + "(%s)"
  FORMAT_INSERT_VALUES = "(%s)"

  def generate_drop_table_ddl(table_name)
    return sprintf(FORMAR_DROP_TABLE, table_name)
  end

  def generate_create_table_ddl(table_name, headers, settings)
    ddl_create_table = create_start_create_table_ddl(table_name, headers, settings)
    ddl_create_table << create_table_option_ddl(headers)
    ddl_create_table << create_end_create_table_ddl(settings)
    return ddl_create_table
  end

  def generate_delete_ddl(table_name)
    return sprintf(FORMAT_DELETE, table_name)
  end

  def generate_insert_ddl(table_name, headers, rows)
    ddl_insert = create_columns_ddl(table_name, headers)
    ddl_insert << create_values_ddl(rows, headers)
    return ddl_insert
  end

  def create_start_create_table_ddl(table_name, headers, settings)
    ddl_column_pairs_ddl = ""
    headers.each_with_index do |column_detail, i|
      if column_detail.ignore_flag == true
        next
      end
      # validate
      if column_detail.column == nil || column_detail.column_type == nil
        raise ArgumentError, "カラムかデータ型が正しく定義されていない列があります。table_name = " + table_name
      end
      # add column and column_type
      ddl_column_pairs_ddl << FORMAT_INDENT + column_detail.column + FORMAT_SPACE + column_detail.column_type
      # add column_option
      column_detail.column_options.each do |column_option|
        ddl_column_pairs_ddl << FORMAT_SPACE + column_option
      end
      # comment
      if column_detail.comment != nil
        if column_detail.comment != ""
          ddl_column_pairs_ddl << FORMAT_SPACE + "COMMENT" + FORMAT_SPACE + "'" + column_detail.comment + "'"
        end
      end
      if headers.size != i + 1
        ddl_column_pairs_ddl << FORMAT_COMMA + FORMAT_LINE_BREAK
      end
    end
    return sprintf(FORMAT_START_CREATE_TABLE, table_name, ddl_column_pairs_ddl)
  end

  def create_table_option_ddl(headers)
    primary_keys = []
    index_keys = []
    unique_keys = []
    # table_options
    headers.each do |detail|
      if detail.ignore_flag == true
        next
      end
      detail.table_options.each do |table_option|
        if is_primary_key(table_option)
          primary_keys.push(detail.column)
        elsif is_index_key(table_option)
          index_keys.push(detail.column)
        elsif is_unique_key(table_option)
          unique_keys.push(detail.column)
        end
      end
    end
    # create options ddl
    ddl_primary_key = create_primary_key_ddl(primary_keys)
    ddl_index_key = create_index_key_ddl(index_keys)
    ddl_unique_key = create_unique_key_ddl(unique_keys)
    # result
    ddl_option = ""
    if ddl_primary_key != ""
      ddl_option << FORMAT_COMMA + FORMAT_LINE_BREAK
      ddl_option << ddl_primary_key
    end
    if ddl_index_key != ""
      ddl_option << FORMAT_COMMA + FORMAT_LINE_BREAK
      ddl_option << ddl_index_key
    end
    if ddl_unique_key != ""
      ddl_option << FORMAT_COMMA + FORMAT_LINE_BREAK
      ddl_option << ddl_unique_key
    end
    return ddl_option
  end

  def create_end_create_table_ddl(settings)
    return sprintf(FORMAT_END_CREATE_TABLE, settings['mysql_setting']['charactor_set'],
                   settings['mysql_setting']['collate'])
  end

  def create_primary_key_ddl(primary_keys)
    ddl_primary_key = ""
    primary_keys.each_with_index do |primary_key, i|
      ddl_primary_key << primary_key
      if primary_keys.size != i + 1
        ddl_primary_key << FORMAT_COMMA
      end
    end
    return sprintf(FORMAT_PRIMARY_KEY, ddl_primary_key)
  end

  def create_index_key_ddl(index_keys)
    if index_keys.size == 0
      return ""
    else
      ddl_index_key_name = "index_"
    end
    ddl_index_keys = ""
    index_keys.each_with_index do |index_key, i|
      ddl_index_keys << index_key
      ddl_index_key_name << index_key
      if index_keys.size != i + 1
        ddl_index_keys << FORMAT_COMMA
        ddl_index_key_name << FORMAT_UNDER_BAR
      end
    end
    return sprintf(FORMAT_INDEX_KEY, ddl_index_key_name, ddl_index_keys)
  end

  def create_unique_key_ddl(unique_keys)
    if unique_keys.size == 0
      return ""
    end
    ddl_unique_keys = ""
    ddl_unique_key_name = ""
    unique_keys.each_with_index do |unique_key, i|
      ddl_unique_keys << unique_key
      ddl_unique_key_name << unique_key
      if unique_keys.size != i + 1
        ddl_unique_keys << FORMAT_COMMA
        ddl_unique_key_name << FORMAT_UNDER_BAR
      end
    end
    return sprintf(FORMAT_UNIQUE_KEY, ddl_unique_key_name, ddl_unique_keys)
  end

  def create_columns_ddl(table_name, headers)
    ddl_columns = ""
    headers.each_with_index do |column_detail, i|
      if column_detail.ignore_flag == true
        next
      end
      ddl_columns << column_detail.column
      if headers.size != i + 1
        ddl_columns << FORMAT_COMMA
      end
    end
    return sprintf(FORMAT_INSERT_COLUMN, table_name, ddl_columns)
  end

  def create_values_ddl(rows, headers)
    ddl_insert_values = ""
    rows.each_with_index do |row, i|
      ddl_values = ""
      values = row
      headers.each_with_index do |header, j|
        if header.ignore_flag == true
          next
        end
        value = values[j]
        if value == nil
          if header.comment == "自動追加カラム(DATETIME型)"
            ddl_values << "sysdate()"
          elsif header.column_type == "DATETIME"
            ddl_values << "NULL"
          else
            ddl_values << "\'\'"
          end
        elsif value == "NULL"
          if header.column_type == "DATETIME"
           ddl_values << "NULL"
          else
           ddl_values << "NULL"
          end
        else
          ddl_values << SqlUtil.add_single_quatation_for_string(value, header.column_type)
        end
        if headers.size != j + 1
          ddl_values << FORMAT_COMMA
        end
      end
      if i == 0
        ddl_insert_values << sprintf(FORMAT_INSERT_VALUES_FIRST, ddl_values)
      else
        ddl_insert_values << FORMAT_COMMA + FORMAT_LINE_BREAK
        ddl_insert_values << sprintf(FORMAT_INSERT_VALUES, ddl_values)
      end
    end
    return ddl_insert_values
  end

end
