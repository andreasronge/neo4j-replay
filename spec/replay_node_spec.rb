require 'spec_helper'


describe "Neo4j::Replay" do

  before(:each) do
    Neo4j::Replay.clear
  end

  context "when neo4j starts" do
    it "should create a new Replay node" do
      Neo4j.shutdown
      Neo4j.start
      Neo4j::Replay.instance?.should be_false
      Neo4j::Replay.instance.should be_kind_of(Neo4j::Replay::ReplayNode)
      Neo4j::Replay.instance?.should be_true
    end
  end

  describe "#on_node_created" do
    subject { Neo4j::Replay.instance }

    context "the created node is replayable" do
      before(:each) do
        Neo4j::Replay.add_replay_on("Something")
        Something = mock("Something")
        Something.should_receive(:init_replay_uuid)
        Something.should_receive(:get_replay_uuid).and_return("my_uuid")
      end

      after(:each) do
        Object.send(:remove_const, :Something)
      end

      subject do
        Neo4j::Replay.instance
      end

      it "creates an event with an replay_uuid and replay_class" do
        subject.on_node_created({:_classname => 'Something'})
        event = subject.events.first
        event[:replay_class].should == 'Something'
        event[:replay_uuid].should == 'my_uuid'
      end

      it "creates a new event" do
        subject.events.size.should == 0
        subject.on_node_created({:_classname => 'Something'})
        subject.events.size.should == 1
      end

      it "creates a CreateNodeEvent" do
        subject.on_node_created({:_classname => 'Something'})
        subject.events.first.wrapper.should be_kind_of(Neo4j::Replay::CreateNodeEvent)
      end
    end
  end
end

