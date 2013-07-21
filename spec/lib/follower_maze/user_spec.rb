require 'spec_helper'

describe FollowerMaze::User do

  let(:connection) { double }
  subject { FollowerMaze::User.new 1, connection }

  its(:id)          { should eql 1 }
  its(:connection)  { should eql connection }
  its(:followers)   { should eql [] }

  describe '#add_follower' do
    let(:user) { FollowerMaze::User.new 2, connection }
    before do
      FollowerMaze::UserStore.should_receive(:find).with(2).once { user }
      subject.add_follower user
    end

    it 'adds a user to the list of followers_id' do
      subject.followers.should include user
    end
  end

end
