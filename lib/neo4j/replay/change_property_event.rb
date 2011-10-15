module Neo4j
  module Replay

    class ChangePropertyEvent
      include Neo4j::NodeMixin
      property :replay_uuid
      property :replay_class

      property :key
      property :new_value
      property :old_value
      property :error

      def replay
        classname = self[:replay_class]
        clazz = classname.constantize
        node = clazz.find_by_replay_uuid(replay_uuid)
        if node
          node[key] = new_value
        else
          self.error = "Can't find #{classname} node with replay uuid = '#{replay_uuid}'"
        end

        node
      end

      def rewind
        classname = self[:replay_class]
        clazz = classname.constantize
        node = clazz.find_by_replay_uuid(replay_uuid)
        node[key] = old_value
        node
      end

      def self.new_replay_for(node, key, old_value, new_value)
        classname = node[:_classname]
        clazz = classname.constantize
        uuid = clazz.get_replay_uuid(node)
        ChangePropertyEvent.new(:replay_class => classname, :replay_uuid => uuid, :key => key, :new_value => new_value, :old_value => old_value)
      end
    end
  end
end
