require 'spec_helper'

describe Neo4j::Replay::ChangePropertyEvent do
  before(:each) do
    Neo4j::Replay.clear
  end

  context "when a property changes on a node" do
    it "should create a Neo4j::Replay::ChangePropertyEvent" do
      pending
      Neo4j::Replay.instance.events.size.should == 1
      Neo4j::Replay.instance.events.first.wrapper.should be_kind_of(Neo4j::Replay::ChangePropertyEvent)
    end
  end

  context "node does not exist which should change" do
    before(:each) do
      @node = NodeWithDefaultUUID.new
      NodeWithDefaultUUID.stub!(:find_by_replay_uuid).with('uuid1').and_return(nil)
      NodeWithDefaultUUID.should_receive(:get_replay_uuid).and_return('uuid1')
      new_tx
      @event = Neo4j::Replay::ChangePropertyEvent.new_replay_for(@node, 'key', 'oldval', 'newval')
      finish_tx
    end

    describe "#replay" do
      before(:each) do
        new_tx
        @event.replay
        finish_tx
      end

      it "does not change the property" do
        @node['key'].should be_nil
      end

      it "sets an error flag on the event" do
        @event[:error].should == "Can't find NodeWithDefaultUUID node with replay uuid = 'uuid1'"
      end

    end
  end

  context "node exist which should change" do
    before(:each) do
      @node = NodeWithDefaultUUID.new
      NodeWithDefaultUUID.stub!(:find_by_replay_uuid).with('uuid1').and_return(@node)
      NodeWithDefaultUUID.should_receive(:get_replay_uuid).and_return('uuid1')
      new_tx
      @event = Neo4j::Replay::ChangePropertyEvent.new_replay_for(@node, 'key', 'oldval', 'newval')
      finish_tx
    end

    describe "#replay" do
      before(:each) do
        @event.replay
      end

      it "change the property" do
        @node['key'].should == 'newval'
      end
    end


    describe "#rewind" do
      before(:each) do
        @event.rewind
      end

      it "change the property" do
        @node['key'].should == 'oldval'
      end
    end

  end
end

