require 'rspec'
require './lib/follower_maze'


RSpec.configure do |config|

  config.before :all do
    Thread.abort_on_exception = true
  end

  config.after :each do
    FollowerMaze::UserStore.destroy_all
  end

end

