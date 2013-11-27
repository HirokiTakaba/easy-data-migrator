require 'rubygems'
require "csv"
require 'mysql'
require 'find'
require 'yaml'

require './script/modules/csv/csv_reader_module.rb'
require './script/modules/mysql/sql_executer_module.rb'
require './script/modules/mysql/sql_generator_module.rb'
require './script/modules/mysql/sql_util_module.rb'
require './script/modules/setting/table_setting_module.rb'
require './script/modules/util/project_util_module.rb'
include CsvReader
include SqlExecuter
include SqlGenerator
include SqlUtil
include TableSetting
include ProjectUtil

class MysqlMigrateController

  def create_table(env, import_file_path)
    ProjectUtil.validate(env, import_file_path)
    @settings = get_settings(env)
    # reader
    files = CsvReader.get_files(import_file_path)
    files.each do |file|
      # table setting
      if TableSetting.is_ignore_table(file, @settings)
        next
      end
      # datasource
      table_name = CsvReader.get_table_name(file)
      headers = CsvReader.get_headers(file, @settings)
      # console log
      puts '------------------------------'
      puts '---  '
      puts '---  Drop and Create table'
      puts '---  ' + table_name
      puts '---  '
      puts '------------------------------'
      # execute
      SqlExecuter.execute(SqlGenerator.generate_drop_table_ddl(table_name), @settings)
      SqlExecuter.execute(SqlGenerator.generate_create_table_ddl(table_name, headers, @settings), @settings)
    end
  end

  def upload(env, import_file_path)
    ProjectUtil.validate(env, import_file_path)
    @settings = get_settings(env)
    # reader
    files = CsvReader.get_files(import_file_path)
    files.each do |file|
      # table setting
      if TableSetting.is_ignore_table(file, @settings)
        next
      end
      # datasource
      table_name = CsvReader.get_table_name(file)
      headers = CsvReader.get_headers(file, @settings)
      rows = CsvReader.get_rows(file, headers)
      # console log
      puts '------------------------------'
      puts '---  '
      puts '---  Upload data'
      puts '---  ' + table_name
      puts '---  '
      puts '------------------------------'
      # execute delete table
      if TableSetting.is_insert_only_table(file, @settings) == false
        SqlExecuter.execute(SqlGenerator.generate_delete_ddl(table_name), @settings)
      end
      # execute insert
      SqlExecuter.execute(SqlGenerator.generate_insert_ddl(table_name, headers, rows), @settings)
    end
  end

  def get_settings(env)
    return YAML.load_file('resource/config_' + env + '.yml')
  end

end