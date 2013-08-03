require 'spec_helper'

describe FollowerMaze::User do

  let(:connection)  { double }
  subject { FollowerMaze::User.new 1, connection }
  let(:user) { FollowerMaze::User.new 2, connection }

  its(:id)          { should eql 1 }
  its(:connection)  { should eql connection }
  its(:followers)   { should eql [] }

  let(:message) { 'message' }

  describe '#add_follower' do
    before do
      FollowerMaze::UserStore.should_receive(:find).with(2).once { user }
      subject.add_follower user
    end

    its(:followers) { should include user }
  end

  describe '#remove_follower' do
    before do
      subject.follower_ids << 2
      subject.remove_follower user
    end

    its(:followers) { should_not include user }
  end

  describe '#notify' do
    before { subject.notify message }

    its(:messages_to_send) { should eql message }
  end

  describe '#reset_messages!' do
    before do
      subject.notify message
      subject.reset_messages!
    end

    its(:messages_to_send) { should be_empty }
  end

end
