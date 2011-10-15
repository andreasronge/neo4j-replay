module Neo4j::Replay
  module Extension
    def _extend_with_custom_uuid(uuid_key)
      meta = class << self; self; end

      meta.send(:define_method, :get_replay_uuid_key) { uuid_key }

      meta.send(:alias_method, :find_by_replay_uuid, :"find_by_#{uuid_key}")

      def self.init_replay_uuid(_)
      end
    end

    def _extend_with_default_uuid
      self.index :_replay_uuid
      self.property :_replay_uuid

      def self.get_replay_uuid_key
        :_replay_uuid
      end

      def self.init_replay_uuid(node)
        node[get_replay_uuid_key] = UUID.generate
      end
    end

    def replay(options={})
      uuid_key = options[:uuid]
      if uuid_key
        _extend_with_custom_uuid(uuid_key.to_s)
      else
        _extend_with_default_uuid
      end

      def self.set_replay_uuid(node, uuid)
        key = get_replay_uuid_key
        node[key] = uuid
      end

      def self.get_replay_uuid(node)
        key = get_replay_uuid_key
        node[key]
      end

      Neo4j::Replay.add_replay_on(self)
    end
  end
end

Neo4j::Rails::Model.extend Neo4j::Replay::Extension


module Neo4j::Replay
  module Mixin

    def self.extended(other)
      other.index :_replay_uuid
      other.property :_replay_uuid
    end

  end


end