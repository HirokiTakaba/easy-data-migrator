module ProjectUtil

  def validate(env, import_file_path)
    if env == 'product'
      if import_file_path.include?("/user/")
        raise ArgumentError, "本番環境は「/user」フォルダの操作が禁止されています。どうしても行いたい場合はこの判定を一時的にコメントアウトしてください。"
      end
    end
  end

  def get_records
    return YAML.load_file('resource/config_local.yml')
  end

end