module Neo4j
  module Replay
    class ReplayNode
      include Neo4j::NodeMixin

      has_list :events

      def on_node_created(node)
        return unless Neo4j::Replay.replay_on?(node[:_classname])
        puts "  -- haha"
        Neo4j::Transaction.run do
          Neo4j::Replay.instance.events << CreateNodeEvent.new_replay_for(node)
        end
      end

      def on_property_changed(node, key, old_value, new_value)
        puts "prop changed"
        return unless Neo4j::Replay.replay_on?(node[:_classname])

      end

      def destroy
        Neo4j.db.event_handler.remove(self)
        self.del
      end

      def init_on_create(*)
        super
        puts "init on create"
        Neo4j.db.event_handler.add(self) unless Neo4j.read_only?
      end
    end

  end

end
