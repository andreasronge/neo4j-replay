module Neo4j
  module Replay

    class CreateNodeEvent
      include Neo4j::NodeMixin
      property :replay_uuid
      property :replay_class


      def replay
        node = Neo4j::Node.new(:_classname => replay_class)
        clazz = replay_class.constantize
        clazz.set_replay_uuid(node, replay_uuid)
        node
      end

      def rewind
        clazz = replay_class.constantize
        node = clazz.find_by_replay_uuid(replay_uuid)
        node.destroy
      end

      def self.new_replay_for(node)
        classname = node[:_classname]
        clazz = classname.constantize
        clazz.init_replay_uuid(node)
        CreateNodeEvent.new(:replay_class => node[:_classname], :replay_uuid => clazz.get_replay_uuid(node))
      end
    end
  end
end
