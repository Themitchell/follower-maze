require 'spec_helper'

describe FollowerMaze::User do

  let(:connection)  { double }
  subject { FollowerMaze::User.new 1, connection }
  let(:user) { FollowerMaze::User.new 2, connection }

  its(:id)          { should eql 1 }
  its(:connection)  { should eql connection }
  its(:followers)   { should eql [] }

  describe '#add_follower' do
    before do
      FollowerMaze::UserStore.should_receive(:find).with(2).once { user }
      subject.add_follower user
    end

    it 'adds a user to the list of followers_id' do
      subject.followers.should include user
    end
  end

  describe '#remove_follower' do
    before do
      subject.follower_ids << 2
      subject.remove_follower user
    end

    it 'adds a user to the list of followers_id' do
      subject.followers.should_not include user
    end
  end

  describe '#notify' do
    let(:message) { 'message' }

    it 'calls write on the connection' do
      connection.should_receive(:write).with(message)
      subject.notify message
    end

    context 'when it raises an error' do
      it 'should raise an NotificationError if it times out' do
        connection.should_receive(:write).with(message).and_raise Timeout::Error
        expect { subject.notify message }.to raise_error FollowerMaze::User::NotificationError
      end

      it 'should raise an NotificationError if it times out' do
        connection.should_receive(:write).with(message).and_raise Errno::EPIPE
        expect { subject.notify message }.to raise_error FollowerMaze::User::NotificationError
      end
    end
  end

end
