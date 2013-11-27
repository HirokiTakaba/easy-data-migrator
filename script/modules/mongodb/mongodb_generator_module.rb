module MongodbGenerator

  def generate_hashs(headers, rows)
    hashs = []
    rows.each_with_index do |row, i|
      hash = Hash.new
      values = row.to_s.split(",")
      values.each_with_index do |value, j|
        hash.store(headers[j].column, value)
      end
      hashs.push(hash)
    end
    return hashs
  end

end