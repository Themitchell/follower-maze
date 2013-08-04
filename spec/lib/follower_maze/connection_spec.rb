require 'spec_helper'

describe FollowerMaze::Connection do

  let(:socket) { double fileno: '10' }

  subject { FollowerMaze::Connection.new socket }

  its(:socket) { should eql socket }
  its(:fileno) { should eql socket.fileno }
  let(:message) { 'message\r\n' }


  describe '#read' do
    context 'when the socket returns something' do
      before { socket.should_receive(:gets).with("\n") { message } }

      its(:read) { should eql message }
    end

    context 'when the socket times out' do
      before { socket.should_receive(:gets).and_raise Timeout::Error.new }

      it { expect { subject.read }.to raise_error FollowerMaze::Connection::ReadError }
    end

    context 'when the socket is not connected' do
      before { socket.should_receive(:gets).and_raise Errno::EPIPE.new }

      it { expect { subject.read }.to raise_error FollowerMaze::Connection::ReadError }
    end

    context 'when the socket connectionis reset' do
      before { socket.should_receive(:gets).and_raise Errno::ECONNRESET.new }

      it { expect { subject.read }.to raise_error FollowerMaze::Connection::ReadError }
    end
  end

  describe '#write' do
    context 'when the socket returns something' do
      before { socket.should_receive(:write).with(message) { message } }

      it { subject.write(message).should eql message }
    end

    context 'when the socket times out' do
      before { socket.should_receive(:write).with(message).and_raise Timeout::Error.new }

      it { expect { subject.write message }.to raise_error FollowerMaze::Connection::WriteError }
    end

    context 'when the socket is not connected' do
      before { socket.should_receive(:write).with(message).and_raise Errno::EPIPE.new }

      it { expect { subject.write message }.to raise_error FollowerMaze::Connection::WriteError }
    end

    context 'when the socket connectionis reset' do
      before { socket.should_receive(:write).with(message).and_raise Errno::ECONNRESET.new }

      it { expect { subject.write message }.to raise_error FollowerMaze::Connection::WriteError }
    end
  end
end
