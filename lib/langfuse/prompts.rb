# frozen_string_literal: true
require "cgi"

module Langfuse
  class Prompts
    def initialize(client: Client.new)
      @client = client
    end

    def fetch(name:, version: nil, label: nil)
      path  = "v2/prompts/#{CGI.escape(name)}"
      query = { version: version, label: label }.compact

      res = @client.get(path, query)
      raise "Langfuse #{res.status}: #{res.body}" unless res.success?

      res.body
    end
  end
end
