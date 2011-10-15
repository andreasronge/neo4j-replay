require 'uuid'
require 'neo4j/extensions/neo4j'
require 'neo4j/replay/replay_node'
require 'neo4j/replay/create_node_event'
require 'neo4j/replay/change_property_event'


module Neo4j
  module Replay

    class << self
      attr_reader :replay_on

      def add_replay_on(clazz)
        @replay_on ||= []
        @replay_on << clazz.to_s unless @replay_on.include?(clazz.to_s)
      end

      def replay_on?(clazz)
        @replay_on && @replay_on.include?(clazz.to_s)
      end

      def to_s
        "Replay (on #{@replay_on.join(', ')})"
      end

      # Mainly for testing, deletes the reply node and removes all classes it has replay on.
      def clear
        # make sure there is nothing attached to ref node
        if instance?
          new_tx
          Neo4j.ref_node.outgoing(:replay).each{|r| r.del}
          finish_tx
        end
      end

      def instance?
        Neo4j.ref_node.rel?(:replay)
      end

      def create_instance
        raise "Already created replay instance" if instance?
        Neo4j::Transaction.run do
          r = ReplayNode.new
          Neo4j.ref_node.outgoing(:replay) << r
          r.events.to_a # a little bug maybe, needs to initialize the list
          r
        end
      end

      def events
        instance.events
      end

      def instance
        # create a new if it does not exist
        if instance?
          Neo4j.ref_node.node(:outgoing, :replay)
        else
          create_instance
        end
      end

      def enable
        return if Neo4j.read_only?
        db = Neo4j.running? ? Neo4j.db : Neo4j.unstarted_db
        db.event_handler.add(Neo4j::Replay)
      end

      def disable
        db = Neo4j.running? ? Neo4j.db : Neo4j.unstarted_db
        db.event_handler.remove(Neo4j::Replay)
      end


      # ----------------------------------------------------------------------------------------------------------------
      # Event handling

      def on_node_created(node)
        return unless handle_class?(node)
        Neo4j::Transaction.run { instance.events << CreateNodeEvent.new_replay_for(node) }
      end

      def on_property_changed(node, key, old_value, new_value)
        return unless handle_class?(node)
        return unless handle_property?(node, key)
        Neo4j::Transaction.run { instance.events << ChangePropertyEvent.new_replay_for(node, key, old_value, new_value) }
      end

      def handle_class?(node)
       replay_on?(node[:_classname])
      end

      def handle_property?(node, key)
        return false if key[0].chr == '_'  # internal property, not sure if we should handle it
        classname = node[:_classname]
        clazz = classname.constantize
        clazz.get_replay_uuid_key.to_s != key
      end
    end


    Neo4j.unstarted_db.event_handler.add(Neo4j::Replay) unless Neo4j.read_only?

  end

end
