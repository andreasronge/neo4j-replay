class Person < Neo4j::Rails::Model
  property :name
  replay
end


class Company < Neo4j::Rails::Model
  property :name
  index :name

  replay :uuid => :name
end


class NodeWithDefaultUUID < HashWithIndifferentAccess
  def initialize
    super
    self[:_classname] = self.class.to_s
  end

  def self.index(*)
  end

  def self.property(*)
  end

  extend Neo4j::Replay::Extension
  replay
end


class NodeWithCustomUUID < HashWithIndifferentAccess
  def initialize
    super
    self[:_classname] = self.class.to_s
    self['my_uuid'] = 4242
  end

  def self.find_by_my_uuid(*)
    puts "find_by_my_uuid called"
    nil
  end
  extend Neo4j::Replay::Extension
  replay :uuid => :my_uuid
end
