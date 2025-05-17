# frozen_string_literal: true
require_relative "langfuse/version"
require_relative "langfuse/client"
require_relative "langfuse/logger"
require_relative "langfuse/prompts"

module Langfuse
  class << self
    def client
      @client ||= Client.new
    end

    def logger
      @logger ||= Logger.new(client: client)
    end

    def prompts
      @prompts ||= Prompts.new(client: client)
    end
  end
end
