# frozen_string_literal: true

module Langfuse
  class Logger
    def initialize(client: Client.new)
      @client = client
    end

    def log_span(trace_id:, name:, input:, output:, user_id:, session_id: nil, metadata: {})
      body = {
        traceId:   trace_id.to_s,
        name:      name,
        input:     input,
        output:    output,
        userId:    user_id.to_s,
        sessionId: session_id&.to_s,
        metadata:  metadata
      }.compact

      res = @client.post("spans", body)
      warn "[Langfuse::Logger] #{res.status} – #{res.body}" unless res.success?
      res.success?
    end
  end
end
