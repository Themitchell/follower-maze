require 'spec_helper'

describe FollowerMaze::User do

  let(:connection) { double }
  subject { FollowerMaze::User.new 1, connection }

  its(:id)          { should eql 1 }
  its(:connection)  { should eql connection }
end
