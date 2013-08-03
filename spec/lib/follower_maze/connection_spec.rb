require 'spec_helper'

describe FollowerMaze::Connection do

  let(:socket) { double fileno: '10' }

  subject { FollowerMaze::Connection.new socket }

  its(:socket) { should eql socket }
  its(:fileno) { should eql socket.fileno }

  describe '#read' do
    let(:message) { 'message' }

    context 'when the socket returns something' do
      before { socket.should_receive(:gets) { message } }

      its(:read) { should eql message }
    end

    context 'when the socket times out' do
      before { socket.should_receive(:gets).and_raise Timeout::Error.new }

      its(:read) { should be_nil }
    end
  end
end
