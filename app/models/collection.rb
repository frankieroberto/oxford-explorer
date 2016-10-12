require 'csv'

class Collection

  attr_accessor :id, :institution_id, :name, :size_int, :types_of_things, :subjects, :places,
    :people, :dates

  def initialize(metadata)
    @metadata = metadata
    @id = metadata['gfs_id']
    @institution_id = metadata['institution']
    @name = metadata['collection']
    @size_int = metadata['size'].to_s.gsub(',', '').to_i
    @types_of_things = metadata['type_of_things'].to_s.split(';').collect(&:strip)
    @subjects = metadata['subjects'].to_s.split(',').collect(&:strip)
    @places = metadata['places'].to_s.split(',').collect(&:strip)
    @people = metadata['names'].to_s.split(';').collect(&:strip)
    @dates = metadata['dates']
  end

  def [](test)
    @metadata[test]
  end

  # TODO: Cache this in memory
  def self.all

    data = CSV.read("#{File.dirname(__FILE__)}/../../db/collections.csv", headers: true)

    data[2..-1].collect do |row|
      self.new(row.to_h)
    end

  end

  def self.find(id)
    all.detect {|c| c.id == id }
  end


end