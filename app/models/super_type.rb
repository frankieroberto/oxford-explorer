class SuperType

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def types_of_thing
    TypeOfThing.all.select {|type| type.super_type == self }
  end

  def ==(other)
    self.class === other && other.name == name
  end


end