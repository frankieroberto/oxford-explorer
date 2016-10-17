require 'csv'

class Institution

  attr_accessor :id, :name, :founded, :website, :photo_licence, :photo_credit, :photo_url, :photo_source_url

  def initialize(metadata)
    @metadata = metadata
    @id = metadata['institution_shortcode']
    @name = metadata['institution_name']
    @founded = metadata['institution_founded'].to_i
    @website = metadata['institution_url']
    @photo_licence = metadata['institution_photo_licence']
    @photo_credit = metadata['institution_photo_credit']
    @photo_url = metadata['institution_photo_url']
    @photo_source_url = metadata['institution_photo_source_url']
  end

  def [](test)
    @metadata[test]
  end

  def things_count
    collections.collect {|c| c.size_int }.compact.sum
  end

  # Return all subjects from collections, ordered by frequency
  # of occurance (descending).
  def subjects
    collections
      .collect {|c| c.subjects }
      .flatten
      .group_by(&:itself)
      .sort_by {|x| x[1].size }
      .reverse
      .collect {|x| x[0] }
  end

  def collections
    @collections ||= Collection.all.select {|c| c.institution_id == id }
  end

  def self.all
    @data ||= setup_data
  end

  def self.setup_data
    data = CSV.read("#{Rails.root.join("db", "institutions.csv").to_s}", headers: true)

    data[1..-1].collect do |row|
      self.new(row.to_h)
    end
  end

  def self.find(id)
    institution = all.detect {|c| c.id == id }
  end


end
