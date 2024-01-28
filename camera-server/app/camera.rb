# frozen_string_literal: true

require 'open3'
require 'singleton'

class Camera
  include Singleton

  PID_LOCATION = "#{APP_ROOT}/pids/server.pid".freeze

  def initialize(logger: nil)
    @logger = logger || ::ColorizedLogger.new
    @run_cmd = ENV.fetch('UDP_MODE', 'false') == 'true' ? run_http : run_udp
  end

  def run
    return false if already_running?

    execute(run_cmd, pid_handler: ->(pid) { File.write(PID_LOCATION, pid) })
    true
  end

  def stop
    return false if no_pid?

    logger.info('Exiting process')
    Process.kill('INT', File.read(PID_LOCATION))
    File.delete(PID_LOCATION)
    true
  end

  private

  attr_reader :logger, :run_cmd

  def execute(cmd, pid_handler: nil)
    logger.info("Executing '#{cmd}'")

    Dir.chdir(APP_ROOT) do
      Open3.popen2(cmd) do |_stdin, _stdout, wait_thread|
        pid_handler&.call(wait_thread.pid)
      end
    end

    logger.success('Done')
  end

  def already_running?
    File.exist?(PID_LOCATION)
  end

  def no_pid?
    !File.exist?(PID_LOCATION)
  end

  def run_http
    'libcamera-vid -t 0 --width 1920 --height 1080 --inline --listen -o tcp://0.0.0.0:8080'
  end

  def run_udp
    'libcamera-vid -t 0 --width 1920 --height 1080 --inline -o udp://0.0.0.0:8080'
  end
end
