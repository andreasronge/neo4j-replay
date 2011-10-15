module Neo4j
  module Replay
    class ReplayNode
      include Neo4j::NodeMixin

      has_list :events

    end

  end

end
