require 'spec_helper'

describe FollowerMaze::EventQueue do

  let(:payload) { '10|F|2|3' }
  let(:event) { FollowerMaze::Event.new payload }

  describe '#add_event' do
    let(:expected_events) { { 10 => event } }
    before { subject.add_event event }

    its(:events) { should eql expected_events }
  end

  describe '#complete_event_processing' do
    let(:expected_events) { {} }
    before { subject.complete_event_processing event }

    its(:events) { should eql expected_events }
    its(:last_event_sequence_num) { should eql event.sequence_num }
  end

  describe '#next_event' do
    before do
      subject.stub(:next_event_sequence_num) { 10 }
      subject.add_event event
    end

    its(:next_event) { event }
  end


  describe '#has_events?' do
    it 'returns true if there are events in the queue' do
      subject.add_event event
      subject.should have_events
    end

    it 'returns false if there are no events in the queue' do
      subject.should_not have_events
    end
  end
end
