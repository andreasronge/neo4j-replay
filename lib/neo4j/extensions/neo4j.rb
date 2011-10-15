module Neo4j::Replay
  module Extension
    def _extend_with_custom_uuid(uuid_key)
      meta = class << self; self; end

      meta.send(:define_method, :get_replay_uuid) do |node|
        node[uuid_key]
      end

      meta.send(:define_method, :set_replay_uuid) do |node, uuid|
        node[uuid_key] = uuid
      end

      meta.send(:define_method, :find_by_replay_uuid) do |uuid|
        self.send("find_by_#{uuid_key}")
      end

      def self.init_replay_uuid(_)
      end
    end

    def _extend_with_default_uuid
      self.index :replay_uuid
      self.property :replay_uuid

      #self.send(:alias_method, :to_s, :foobar)
      def self.init_replay_uuid(node)
        set_replay_uuid(node, UUID.generate )
      end

      def self.set_replay_uuid(node, uuid)
        node['replay_uuid'] = uuid
      end

      def self.get_replay_uuid(node)
        node['replay_uuid']
      end
    end

    def replay(options={})
      puts "REPLAY #{options.inspect}, self=#{self}"
      uuid_key = options[:uuid]
      if uuid_key
        _extend_with_custom_uuid(uuid_key.to_s)
      else
        _extend_with_default_uuid
      end
      Neo4j::Replay.add_replay_on(self)
    end
  end
end

Neo4j::Rails::Model.extend Neo4j::Replay::Extension


module Neo4j::Replay
  module Mixin

    def self.extended(other)
      other.index :replay_uuid
      other.property :replay_uuid
    end

  end


end