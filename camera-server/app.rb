# frozen_string_literal: true

require 'roda'
require 'dotenv/load'
require 'json'

APP_ROOT = __dir__.freeze

require_relative 'app/colorized_logger'
require_relative 'app/camera'

class App < ::Roda
  plugin :default_headers,
         'content-type' => 'application/json',
         'X-Content-Type-Options' => 'nosniff',
         'X-Frame-Options' => 'deny'
  plugin :all_verbs

  route do |r|
    r.on 'camera' do
      r.get do
        JSON.dump({ running: Camera.instance.run? })
      end

      r.post do
        if Camera.instance.run
          response.status = 200
          '{}'
        else
          response.status = 422
          '{ "message": "Already in progress" }'
        end
      end

      r.delete do
        if Camera.instance.stop
          response.status = 200
          '{}'
        else
          response.status = 422
          '{ "message": "Not running" }'
        end
      end
    end
  end
end
