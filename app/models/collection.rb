require 'csv'

class Collection

  attr_accessor :id, :institution_id, :name, :size_int, :types_of_things, :subjects, :places,
    :people, :dates, :digitized_metadata_size_int, :digitized_size_int, :department, :academic_departments, :divisions

  def initialize(metadata)
    @metadata = metadata
    @id = metadata['gfs_id']
    @institution_id = metadata['institution']
    @department = metadata['department']
    @name = metadata['collection']
    @size_int = metadata['size'].to_s.gsub(',', '').to_i
    @digitized_metadata_size_int = metadata['published_digital_records'].to_s.gsub(',', '').to_i
    @digitized_size_int = metadata['how_many_digitized_versions'].to_s.gsub(',', '').to_i
    @types_of_things = metadata['type_of_things'].to_s.split(';').collect(&:strip).reject(&:blank?).collect(&:downcase)
    @subjects = metadata['subjects'].to_s.split(/[\,;]/).collect(&:strip).reject(&:blank?).collect(&:downcase)
    @academic_departments = metadata['academic department'].to_s.split(/[\,;]/).collect(&:strip).reject(&:blank?)
    @divisions = metadata['division'].to_s.split(/[\,;]/).collect(&:strip).reject(&:blank?)
    @places = metadata['places'].to_s.split(/[,;]/).collect(&:strip).reject(&:blank?)
    @people = metadata['names'].to_s.split(/[,;]/).collect(&:strip).reject(&:blank?)
    @dates = metadata['dates']
  end

  def [](test)
    @metadata[test]
  end

  def catalog_url
    @catalog_url ||= begin

      catalog_url = @metadata['catalog_url'].strip

      catalog_url.blank? ? nil : catalog_url
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
