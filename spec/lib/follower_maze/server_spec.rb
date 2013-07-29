require 'spec_helper'
require 'timeout'

describe FollowerMaze::Server do

  let(:timeout)       { 15 }
  let(:event_client)  { TCPSocket.new 'localhost', 9090 }
  let(:client_1)      { TCPSocket.new 'localhost', 9099 }
  let(:client_2)      { TCPSocket.new 'localhost', 9099 }
  let(:client_3)      { TCPSocket.new 'localhost', 9099 }

  before do
    @thread = Thread.new { subject.start }
    client_1.write "1\r\n"
    client_2.write "2\r\n"
    sleep 1
  end

  after do
    client_1.close
    client_2.close
    event_client.close
    @thread.kill
    sleep 1
  end

  context 'Follow: Only the To User Id should be notified' do
    let(:message) { "1|F|1|2\r\n" }

    before { event_client.write message }

    it 'does not receive message at client 1' do
      expect { Timeout.timeout(timeout) { client_1.readpartial(1024) } }.to raise_error Timeout::Error
    end

    it 'receives a message at client 2' do
      Timeout.timeout(timeout) { client_2.readpartial(1024) }.should eql message
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

  context 'Broadcast: All connected user clients should be notified' do
    let(:message) { "1|B\r\n" }

    before { event_client.write message }

    it 'receives a message at client 1' do
      Timeout.timeout(timeout) { client_1.readpartial(1024) }.should eql message
    end

    it 'receives a message at client 2' do
      Timeout.timeout(timeout) { client_2.readpartial(1024) }.should eql message
    end
  end

  context 'Private Message: Only the To User Id should be notified' do
    let(:message) { "1|P|1|2\r\n" }

    before { event_client.write message }

    it 'does not receive message at client 1' do
      expect { Timeout.timeout(timeout) { client_1.readpartial(1024) } }.to raise_error Timeout::Error
    end

    it 'receives a message at client 2' do
      Timeout.timeout(timeout) { client_2.readpartial(1024) }.should eql message
    end
  end

  context 'Status Update: All current followers of the From User ID should be notified' do
    let(:message)   { "4|S|1\r\n" }

    before do
      client_3.write "3\r\n"
      event_client.write "1|F|2|1\r\n" # make user 2 follow user 1
      event_client.write "2|F|3|1\r\n" # make user 3 follow user 1
      event_client.write "3|U|3|1\r\n" # make user 3 unfollow user 1
      event_client.write message
    end
    after do
      client_3.close
    end

    it 'does not receive message at client 1' do
      # Check the first message is a follow from user 2
      Timeout.timeout(timeout) { client_1.readpartial(1024) }.should eql "1|F|2|1\r\n"
      # Check the second message is a follow from user 2
      Timeout.timeout(timeout) { client_1.readpartial(1024) }.should eql "2|F|3|1\r\n"
      # Then test no more messages are received
      expect { Timeout.timeout(timeout) { client_1.readpartial(1024) } }.to raise_error Timeout::Error
    end

    it 'receives a message at client 2' do
      Timeout.timeout(timeout) { client_2.readpartial(1024) }.should eql message
    end

    it 'does not receive a message if the user has unfollowed user 1' do
      expect { Timeout.timeout(timeout) { client_3.readpartial(1024) } }.to raise_error Timeout::Error
    end
  end
end
