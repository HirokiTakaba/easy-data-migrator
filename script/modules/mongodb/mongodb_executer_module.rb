module MongodbExecuter

  def save(collection_name, hashs, settings)
    con = Mongo::Connection.new
    db = con.db(settings['mongodb']['database'])
    collection = db.collection(collection_name)
    hashs.each_with_index do |hash, i|
      collection.save(hash)
      p hash
    end

  end

  def remove_all(collection_name, settings)
    con = Mongo::Connection.new
    db = con.db(settings['mongodb']['database'])
    collection = db.collection(collection_name)
    collection.drop()
  end

end