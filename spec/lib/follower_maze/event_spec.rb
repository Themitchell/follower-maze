require 'spec_helper'

describe FollowerMaze::Event do

  let(:payload) { '3|F|1|2' }
  let(:user1) { double FollowerMaze::User }
  let(:user2) { double FollowerMaze::User }
  let(:user3) { double FollowerMaze::User }

  subject { FollowerMaze::Event.new payload }

  its(:sequence_num)  { should eql 3 }
  its(:kind_key)      { should eql :f }
  its(:from_user_id)  { should eql 1 }
  its(:to_user_id)    { should eql 2 }
  its(:payload)       { should eql payload }

  context 'getters' do
    before do
      FollowerMaze::UserStore.stub(:find).with(1) { user1 }
      FollowerMaze::UserStore.stub(:find).with(2) { user2 }
    end

    its(:kind)      { should eql :follow }
    its(:from_user) { should eql user1 }
    its(:to_user)   { should eql user2 }
  end

  describe '#process' do
    context 'when processing fails due to a user not being found' do
      before { subject.should_receive(:to_user).and_raise FollowerMaze::UserStore::NotFoundError }
      it { expect { subject.process }.to raise_error FollowerMaze::Event::ProcessingError }
    end

    context 'when the message is a follow message' do
      before do
        subject.stub(:kind)       { :follow }
        subject.stub(:from_user)  { user1 }
        subject.stub(:to_user)    { user2 }
      end

      it 'notifies the to user and adds the from user to its followers' do
        user2.should_receive(:add_follower).with(user1)
        user2.should_receive(:notify).with(payload)
        subject.process
      end

      it 'does not notify the from user' do
        user2.should_receive(:add_follower).with(user1)
        user2.should_receive(:notify).with(payload)
        user1.should_not_receive(:notify).with(payload)
        subject.process
      end
    end

    context 'when the message is an unfollow message' do
      before do
        subject.stub(:kind)       { :unfollow }
        subject.stub(:from_user)  { user1 }
        subject.stub(:to_user)    { user2 }
      end

      it 'does not notify the to user and removes the from user from its followers' do
        user2.should_receive(:remove_follower).with(user1)
        user2.should_not_receive(:notify).with(payload)
        subject.process
      end

      it 'does not notify the from user' do
        user2.should_receive(:remove_follower).with(user1)
        user1.should_not_receive(:notify).with(payload)
        subject.process
      end
    end

    context 'when the message is a broadcast message' do
      before do
        subject.stub(:kind) { :broadcast }
        FollowerMaze::UserStore.should_receive(:all) { [user1, user2] }
      end

      it 'notifies all users' do
        user1.should_receive(:notify).with(payload)
        user2.should_receive(:notify).with(payload)
        subject.process
      end
    end

    context 'when the message is a private message' do
      before do
        subject.stub(:kind)       { :private_message }
        subject.stub(:from_user)  { user1 }
        subject.stub(:to_user)    { user2 }
      end

      it 'notifies the to user' do
        user2.should_receive(:notify).with(payload)
        subject.process
      end

      it 'does not notify the from user' do
        user2.should_receive(:notify).with(payload)
        user1.should_not_receive(:notify).with(payload)
        subject.process
      end
    end

    context 'when the message is a status update' do
      before do
        subject.stub(:kind)               { :status_update }
        subject.stub(:from_user)          { user1 }
        user1.should_receive(:followers)  { [user2, user3] }
      end

      it 'notifies all followers' do
        user2.should_receive(:notify).with(payload)
        user3.should_receive(:notify).with(payload)
        subject.process
      end

      it 'does not notify the from user' do
        user2.should_receive(:notify).with(payload)
        user3.should_receive(:notify).with(payload)
        user1.should_not_receive(:notify).with(payload)
        subject.process
      end
    end
  end

end
