# frozen_string_literal: true
# name: discourse-wechat-home-logger
# about: Log homepage page loads to /var/www/discourse/log/wechat.log with timestamp
# version: 0.1.0
# authors: GleeBuild + ChatGPT
# required_version: 3.0.0

after_initialize do
  require 'fileutils'

  class ::WeChatPageLoadLogger
    HOMEPATHS = ['/', '/latest', '/categories', '/top', '/new', '/hot'].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      begin
        req = Rack::Request.new(env)
        # Only log full page HTML GETs to "homepage-like" paths
        if req.get? && html_response?(headers) && homepage_path?(req.path)
          log_line("page load")
        end
      rescue => e
        Rails.logger.warn("[wechat-home-logger] error: #{e.class}: #{e.message}")
      end

      [status, headers, response]
    end

    private

    def html_response?(headers)
      ct = headers['Content-Type'] || ''
      ct.include?('text/html')
    end

    def homepage_path?(path)
      HOMEPATHS.include?(path)
    end

    def log_line(message)
      log_dir = "/var/www/discourse/log"
      FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
      file = File.join(log_dir, "wechat.log")
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      File.open(file, "a") { |f| f.write("#{timestamp} | #{message}\n") }
    end
  end

  # Insert near the end so it runs after routing/controller and we can read response headers
  Discourse::Application.config.middleware.use ::WeChatPageLoadLogger
end
