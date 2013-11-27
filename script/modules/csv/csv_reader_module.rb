module CsvReader

  def get_files(dir)
    if dir == nil
      raise ArgumentError, "インポートするディレクトリが指定されていません"
    end
    files = []
    Find.find(dir) { |f|
      if File.fnmatch("*.csv", f)
        files.push(f)
      end
    }
    if files.empty?
      raise ArgumentError, "インポートできるファイルが存在しません"
    end
    return files
  end

  def get_table_name(filename)
    table_name = filename.scan(/.*\/(.*)\.csv/)
    return table_name[0][0]
  end

  def get_headers(filename, settings)
    readers = CSV.open(filename, "r")
    reader1 = readers.take(1)[0]
    reader2 = readers.take(1)[0]
    reader3 = readers.take(1)[0]
    column_names = reader1
    column_types = reader2
    option_lists = reader3
    return create_headers(column_names, column_types, option_lists, settings)
  end

  def get_headers_for_nosql(filename)
    readers = CSV.open(filename, "r")
    reader = readers.take(1)[0]
    header = reader.take(1)[0]
    return create_headers_for_nosql(header)
  end

  def create_headers(column_names, column_types, option_lists, settings)
    details = []
    column_names.each_with_index do |column_name, i|
      column_name_and_comment = column_name.to_s.split("/")
      options = option_lists[i].to_s.split("/")
      detail = ColumnDetail.new
      if column_name_and_comment.include?("memo")
        detail.ignore_flag = true
        details.push(detail)
        next
      end
      detail.column = column_name_and_comment[0] # column name
      detail.column_type = column_types[i]
      detail.column_options = get_column_options(options) # column_option
      detail.table_options = get_table_options(options) # table_option
      if column_name_and_comment[1] != nil || column_name_and_comment[1] != ""
        detail.comment = column_name_and_comment[1] # column comment
      end
      detail.ignore_flag = false
      details.push(detail)
    end
    ## 追加カラム（datetime）
    add_datetime_columns = settings['mysql_setting']['add_datetime_columns']
    if add_datetime_columns != nil
      add_datetime_columns.each_with_index do |add_datetime_column, i|
        detail = ColumnDetail.new
        detail.column = add_datetime_column # column name
        detail.column_type = "DATETIME" # column type
        detail.column_options = ["NOT NULL"]
        detail.table_options = []
        detail.comment = "自動追加カラム(DATETIME型)"
        details.push(detail)
      end
    end
    return details
  end

  def create_headers_for_nosql(header)
    details = []
    header_columns = header.to_s.split(",")
    header_columns.each_with_index do |header_column, i|
      strs = header_column.split("/")
      detail = ColumnDetail.new
      detail.column = strs[0] # column name
      details.push(detail)
    end
    return details
  end

  class ColumnDetail
    attr_accessor :column, :column_type, :column_options, :table_options, :comment, :ignore_flag
  end

  def get_column_options(options)
    column_options = []
    options.each_with_index do |option, i|
      if SqlUtil.is_support_column_option_type(option)
        column_options.push(option)
      end
    end
    return column_options
  end

  def get_table_options(options)
    table_options = []
    options.each_with_index do |option, i|
      if SqlUtil.is_support_table_option_type(option)
        table_options.push(option)
      end
    end
    return table_options
  end

  def get_rows(filename, headers)
    readers = CSV.open(filename, "r")
    reader = readers.take(1)[0]
    if readers.take(1)[0] == nil
      raise ArgumentError, "Excelで編集されたファイルは改行コード不正のため使用出来ません"
    else
      readers = CSV.open(filename, "r")
      readers.take(1)[0] # column_name and commentを抜く
      readers.take(1)[1] # column_typeを抜く
      readers.take(1)[2] # column_optionsを抜く
      rows = readers
    end
    return rows
  end

end
