require 'csv'

class Collection

  attr_accessor :id, :institution_id, :name

  def initialize(metadata)
    @metadata = metadata
    @id = metadata['gfs_id']
    @institution_id = metadata['institution']
    @name = metadata['collection']
  end

  def [](test)
    @metadata[test]
  end

  # TODO: Cache this in memory
  def self.all

    data = CSV.read("#{File.dirname(__FILE__)}/../../db/collections.csv", headers: true)

    data[2..-1].collect do |row|
      self.new(row.to_h.merge({'size_int' => row['size'].to_s.gsub(',', '').to_i}))
    end

  end

  def self.find(id)
    all.detect {|c| c.id == id }
  end


end