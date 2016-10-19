require 'csv'

class TypeOfThing

  attr_accessor :name, :super_type

  def initialize(name, super_type)
    @name = name
    @super_type = super_type
  end

  def self.find(name)
    all.detect {|type| type.name == name } || new(name, nil)
  end

  def self.all
    @all ||= begin

      things = []

      data = CSV.read("#{Rails.root.join("db", "types_of_things.csv").to_s}", headers: true)

      data[1..-1].each do |row|

        row.to_h.reject {|key, value| value.blank? }.each_pair do |key, value|
          things << self.new(value, SuperType.new(key))
        end
      end

      things
    end

  end


end