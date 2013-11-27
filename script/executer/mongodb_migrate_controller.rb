require 'rubygems'
require "csv"
require 'mongo'
require 'find'
require 'yaml'

require './script/modules/csv/csv_reader_module.rb'
require './script/modules/mongodb/mongodb_executer_module.rb'
require './script/modules/mongodb/mongodb_generator_module.rb'
require './script/modules/setting/table_setting_module.rb'
include CsvReader
include MongodbExecuter
include MongodbGenerator
include TableSetting

class MongodbMigrateController

  def save(env, import_file_path)
    @settings = get_settings(env)
    files = CsvReader.get_files(import_file_path)
    files.each do |file|
      # table setting
      if TableSetting.is_ignore_table(file, @settings)
        next
      end
      # datasource
      collection_name = CsvReader.get_table_name(file)
      headers = CsvReader.get_headers_for_nosql(file)
      rows = CsvReader.get_rows(file)
      # hash
      hashs = MongodbGenerator.generate_hashs(headers, rows)
      # execute
      MongodbExecuter.save(collection_name[0][0], hashs, @settings)
    end
  end

  def remove_all(env, import_file_path)
    @settings = get_settings(env)
    files = CsvReader.get_files(import_file_path)
    files.each do |file|
      # table setting
      if TableSetting.is_ignore_table(file, @settings)
        next
      end
      # datasource
      collection_name = CsvReader.get_table_name(file)
      # execute
      MongodbExecuter.remove_all(collection_name[0][0], @settings)
    end
  end

  def get_settings(env)
    return YAML.load_file('resource/config_' + env + '.yml')
  end

end