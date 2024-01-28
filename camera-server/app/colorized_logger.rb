# frozen_string_literal: true

require 'colorize'
require 'logger'

class ColorizedLogger
  def initialize
    @logger = ::Logger.new($stdout)
  end

  def info(text)
    logger.info text
  end

  def success(text)
    logger.info text.bold.green
  end

  def error(text)
    logger.error text.bold.red
  end

  private

  attr_reader :logger
end
