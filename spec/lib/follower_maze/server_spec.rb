require 'spec_helper'
require 'timeout'

describe FollowerMaze::Server do

  let(:timeout)       { 3 }
  let(:event_client)  { TCPSocket.new 'localhost', 9090 }
  let(:client_1)      { TCPSocket.new 'localhost', 9099 }
  let(:client_2)      { TCPSocket.new 'localhost', 9099 }

  before do
    Thread.new { subject.start }
    client_1.write "1\r\n"
    client_2.write "2\r\n"
    sleep 2
  end

  after do
    client_1.close
    client_2.close
    event_client.close
  end

  context 'Follow: Only the To User Id should be notified' do
    let(:message) { "666|F|1|2\r\n" }

    before { event_client.write message }

    it 'receives a message at client 2' do
      Timeout.timeout(timeout) { client_2.readpartial(1024) }.should eql message
    end

    it 'does not receive message at client 1' do
      expect { Timeout.timeout(timeout) { client_1.readpartial(1024) } }.to raise_error Timeout::Error
    end
  end

  context 'Unfollow: No clients should be notified' do
    let(:message) { "1|U|1|2\r\n" }

    before { event_client.write message }

    it 'does not receive message at client 1' do
      expect { Timeout.timeout(timeout) { client_1.readpartial(1024) } }.to raise_error Timeout::Error
    end

    it 'does not receive message at client 2' do
      expect { Timeout.timeout(timeout) { client_2.readpartial(1024) } }.to raise_error Timeout::Error
    end
  end

  context 'Broadcast: All connected user clients should be notified'
  context 'Private Message: Only the To User Id should be notified'
  context 'Status Update: All current followers of the From User ID should be notified'
end
