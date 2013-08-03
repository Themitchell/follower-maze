require 'spec_helper'

describe FollowerMaze::UserStore do

  let(:connection) { double 'Connection'}
  let(:user) { FollowerMaze::User.new 1, connection }

  describe '#add' do
    before { FollowerMaze::UserStore.add user }

    it { FollowerMaze::UserStore.all.should include user }
  end

  describe '#find' do
    before { FollowerMaze::UserStore.add user }

    it { FollowerMaze::UserStore.find(user.id).should eql user }
  end

  describe '#find_by_connection' do
    before { FollowerMaze::UserStore.add user }

    it { FollowerMaze::UserStore.find_by_connection(connection).should eql user }
  end

  describe '#all' do
    before { FollowerMaze::UserStore.add user }

    it { FollowerMaze::UserStore.all.should include user }
  end

  describe '#destroy' do
    before do
      FollowerMaze::UserStore.add user
      FollowerMaze::UserStore.destroy user
    end

    it { FollowerMaze::UserStore.all.should_not include user }
  end

  describe '#destroy_all' do
    before do
      FollowerMaze::UserStore.add user
      FollowerMaze::UserStore.destroy_all
    end

    it { FollowerMaze::UserStore.all.should be_empty }
  end
end
