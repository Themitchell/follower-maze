require 'debugger'
require 'logger'

require './lib/follower_maze/server'

module FollowerMaze

  TIMEOUT = 3
  log_file      = File.join 'log', 'follower_maze.log'
  logger 				= Logger.new log_file
  logger.level 	= Logger::DEBUG
  Logger 				= logger

end
