require 'csv'

class Collection

  attr_accessor :id, :institution_id, :name, :size_int, :subjects, :places, :metadata,
    :people, :dates, :digitized_metadata_size_int, :digitized_size_int, :department, :academic_departments, :divisions

  def initialize(metadata)
    @metadata = metadata
    @id = metadata['gfs_id']
    @institution_id = metadata['institution']
    @department = metadata['department']
    @name = metadata['collection']
    @digitized_metadata_size_int = metadata['published_digital_records'].to_s.gsub(',', '').to_i
    @digitized_size_int = metadata['how_many_digitized_versions'].to_s.gsub(',', '').to_i
    @subjects = metadata['subjects'].to_s.split(/[\,;]/).collect(&:strip).reject(&:blank?).collect(&:downcase)
    @academic_departments = metadata['academic_department'].to_s.split(/[\;]/).collect(&:strip).reject(&:blank?)
    @divisions = metadata['division'].to_s.split(/[\,;]/).collect(&:strip).collect {|c| c.gsub("MPLS", "Mathematical, Physical & Life Sciences")}.reject(&:blank?)
    @places = metadata['places'].to_s.split(/[,;]/).collect(&:strip).reject(&:blank?)
    @people = metadata['names'].to_s.split(/[,;]/).collect(&:strip).reject(&:blank?)
    @dates = metadata['dates']
  end

  def [](test)
    @metadata[test]
  end

  def types_of_things
    @types_of_things ||= begin

      type_of_thing_names = @metadata['type_of_things'].to_s
        .split(';').collect(&:strip).reject(&:blank?)
        .collect(&:downcase)
        .collect {|type_of_thing_name| TypeOfThing.find(type_of_thing_name) }

    end
  end

  def type_of_thing_names
    "test"
    #type_of_things.collect(&:name)
  end

  def catalog_url
    @catalog_url ||= begin

      catalog_url = @metadata['catalog_url'].to_s.strip

      catalog_url.blank? ? nil : catalog_url
    end
  end

  def catalog_comments
    @catalog_comments ||= begin
      catalog_comments = @metadata['catalog_comments'].to_s.strip
      catalog_comments.blank? ? nil : catalog_comments
    end
  end

  def size_int
    @size_int ||= begin

      metadata_size_int = metadata['size'].to_s.gsub(',', '').to_i
      computed_data_size = computed_data['count'].to_i

      [metadata_size_int, computed_data_size].max
    end
  end

  def self.subjects
    all.map(&:subjects).flatten.uniq.compact.sort
  end

  def self.types_of_things
    all.map(&:types_of_things).flatten.uniq.compact.map(&:name).sort
  end

  private

  def computed_data
    Collection.all_computed_data.detect {|collection| collection['item'] == id } || {}
  end

  def self.all_computed_data

    @all_computed_data ||= begin
      CSV.read("#{Rails.root.join("db", "collections_computed.csv").to_s}", headers: true).collect do |row|
        row.to_h
      end
    end

  end

  def self.all
    @all ||= begin

      data = CSV.read("#{Rails.root.join("db", "collections.csv").to_s}", headers: true)

      data[2..-1].collect do |row|
        self.new(row.to_h)
      end
    end
  end

  def self.find(id)
    all.detect {|c| c.id == id }
  end


end
