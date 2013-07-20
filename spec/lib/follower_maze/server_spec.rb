require 'spec_helper'

describe FollowerMaze::Server do

  before do
    Thread.new { subject.start }
    client = TCPSocket.new 'localhost', 9099
  end

  context 'Follow: Only the To User Id should be notified'
  context 'Unfollow: No clients should be notified'
  context 'Broadcast: All connected user clients should be notified'
  context 'Private Message: Only the To User Id should be notified'
  context 'Status Update: All current followers of the From User ID should be notified'
end
