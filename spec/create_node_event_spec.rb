require 'spec_helper'

describe Neo4j::Replay::CreateNodeEvent do
  before(:each) do
    Neo4j::Replay.clear
  end


  context "when a new node is created" do
    it "creates a new Neo4j::Replay::CreateNodeEvent event" do
      Neo4j::Replay.instance.events.size.should == 0
      Person.all.size.should == 0
      Person.create
      finish_tx
      Person.all.size.should == 1
      Neo4j::Replay.events.size.should == 1
      Neo4j::Replay.events.first.wrapper.should be_kind_of(Neo4j::Replay::CreateNodeEvent)
    end
  end

  context "using default UUID generator" do
    before(:each) do
      new_tx
      @node = NodeWithDefaultUUID.new
      @event = Neo4j::Replay::CreateNodeEvent.new_replay_for(@node)
      finish_tx
    end

    it "creates a UUID for the event" do
      @event.replay_uuid.should_not be_nil
      @event.replay_uuid.should_not be_empty
      @event.replay_uuid.size.should > 5 # at least 5 characters
    end

    describe "#replay" do
      it "creates a new instance" do
        new_tx
        node = @event.replay
        finish_tx
        node['_replay_uuid'].should_not be_nil
        node['_replay_uuid'].should_not be_empty
        node['_classname'].should == 'NodeWithDefaultUUID'
      end
    end

    describe "#rewind" do
      it "deletes the instance" do
        node = mock('existing instance')
        node.should_receive(:destroy)
        NodeWithDefaultUUID.stub!(:find_by_replay_uuid).and_return(node)
        @event.rewind
      end
    end
  end


  context "using custom UUID generator" do
    before(:each) do
      new_tx
      @node = NodeWithCustomUUID.new
      @event = Neo4j::Replay::CreateNodeEvent.new_replay_for(@node)
      finish_tx
    end

    it "creates an UUID for the event" do
      @event.replay_uuid.should == @node['my_uuid']
      @event.replay_uuid.should_not be_nil
    end

    describe "#replay" do
      it "creates a new instance" do
        new_tx
        node = @event.replay
        finish_tx
        node['my_uuid'].should == 4242
        node['my_uuid'].should == @event.replay_uuid
      end
    end

    describe "#rewind" do
      it "deletes the instance" do
        node = mock('existing instance')
        node.should_receive(:destroy)
        NodeWithCustomUUID.stub!(:find_by_replay_uuid).and_return(node)
        @event.rewind
      end
    end

  end

end
