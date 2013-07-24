require 'spec_helper'

describe FollowerMaze::Event do

  let(:payload) { '3|F|1|2' }

  subject { FollowerMaze::Event.new payload }

  its(:sequence_num)  { should eql 3 }
  its(:kind_key)      { should eql :f }
  its(:from_user_id)  { should eql 1 }
  its(:to_user_id)    { should eql 2 }
  its(:payload)       { should eql payload }

  context 'getters' do
    let(:user1) { double FollowerMaze::User }
    let(:user2) { double FollowerMaze::User }

    before do
      FollowerMaze::UserStore.stub(:find).with(1) { user1 }
      FollowerMaze::UserStore.stub(:find).with(2) { user2 }
    end

    its(:kind)      { should eql :follow }
    its(:from_user) { should eql user1 }
    its(:to_user)   { should eql user2 }
  end

end
