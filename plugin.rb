# frozen_string_literal: true
# name: discourse-wechat-home-logger
# about: Log homepage page loads to /var/www/discourse/log/wechat.log with timestamp (controller after_action version)
# version: 0.1.1
# authors: GleeBuild + ChatGPT
# required_version: 3.0.0

after_initialize do
  require 'fileutils'

  module ::DiscourseWechatHomeLogger
    LOG_DIR = "/var/www/discourse/public"
    LOG_FILE = File.join(LOG_DIR, "wechat.txt")
    HOMEPATHS = ['/', '/latest', '/categories', '/top', '/new', '/hot'].freeze

    def self.log!(message)
      begin
        FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
        timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
        File.open(LOG_FILE, "a") { |f| f.puts("#{timestamp} | #{message}") }
      rescue => e
        Rails.logger.warn("[wechat-home-logger] write error: #{e.class}: #{e.message}")
      end
    end
  end

  require_dependency 'application_controller'
  class ::ApplicationController
    after_action :wechat_home_logger_track

    private

    def wechat_home_logger_track
      # Only GET + HTML full page responses and only for homepage-like paths
      return unless request.get?

      html = false
      begin
        html ||= request.format&.html?
      rescue
        # ignore
      end
      begin
        html ||= response&.content_type.to_s.include?('text/html')
      rescue
        # ignore
      end
      return unless html

      path = request.path
      return unless ::DiscourseWechatHomeLogger::HOMEPATHS.include?(path)

      ::DiscourseWechatHomeLogger.log!("page load")
    rescue => e
      Rails.logger.warn("[wechat-home-logger] filter error: #{e.class}: #{e.message}")
    end
  end
end
