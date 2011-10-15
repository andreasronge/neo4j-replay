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

      # Mainly for testing, deletes the reply node and removes all classes it has replay on.
      def clear
        # make sure there is nothing attached to ref node
        if Neo4j::Replay.instance?
          new_tx
          Neo4j::Replay.instance.destroy
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

      def instance
        # create a new if it does not exist
        if instance?
          Neo4j.ref_node.node(:outgoing, :replay)
        else
          create_instance
        end
      end
    end
  end

end
