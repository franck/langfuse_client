# frozen_string_literal: true
require "faraday"
require "json"
require "base64"
require "logger"

module Langfuse
  class Client
    DOMAIN = ENV.fetch("LANGFUSE_DOMAIN", "http://localhost:3001")
    PREFIX = ENV.fetch("LANGFUSE_API_PATH", "/api/public")
    ROOT   = "#{DOMAIN}#{PREFIX}".gsub(%r{//+}, "/")

    def initialize(public_key: ENV["LANGFUSE_PUBLIC_KEY"],
                   secret_key: ENV["LANGFUSE_SECRET_KEY"],
                   logger: default_logger)
      raise ArgumentError, "Missing Langfuse keys" unless public_key && secret_key

      token = Base64.strict_encode64("#{public_key}:#{secret_key}")

      @conn = Faraday.new(url: ROOT) do |f|
        f.request :json
        f.response :json
        f.response :logger, logger, bodies: true, log_level: :info if logger
        f.headers["Authorization"] = "Basic #{token}"
        f.headers["Content-Type"]  = "application/json"
        f.options.open_timeout = 5
        f.options.timeout      = 10
      end
    end

    def post(path, body)
      @conn.post(normalize(path)) { |r| r.body = body }
    end

    def get(path, params = nil)
      @conn.get(normalize(path), params)
    end

    private

    def normalize(path)
      path.to_s.sub(%r{\A/}, "")
    end

    def default_logger
      defined?(Rails) ? Rails.logger : ::Logger.new($stdout)
    end
  end
end

