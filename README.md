# Langfuse Client (Unofficial)

**Unofficial Ruby client for [Langfuse](https://langfuse.com)** — designed to support:
- Prompt management
- LLM span and trace logging
- Session-aware workflows

> ✅ Built for use in Rails apps, but works in any Ruby project.

## ⚠️  Disclaimer

This is an **unofficial gem**, not affiliated with the Langfuse team.

If Langfuse releases an official Ruby SDK, consider migrating when stable.

This gem is for my own usage, maintenance will be minimal.

## Installation

```ruby
gem "langfuse_client"
```

## Configuration

Set these environment variables in your Rails app or .env file:

```ruby
LANGFUSE_DOMAIN=http://localhost:3001        # or https://cloud.langfuse.com
LANGFUSE_API_PATH=/api/public
LANGFUSE_PUBLIC_KEY=your_public_key
LANGFUSE_SECRET_KEY=your_secret_key
```

---

## Usage

### Log span

```ruby
Langfuse.logger.log_span(
  trace_id:   SecureRandom.uuid,
  name:       "ai_response",
  input:      "What can I do about stress?",
  output:     "Try breathing exercises…",
  user_id:    current_user.id,
  session_id: current_session.id,
  metadata:   { intent: "stress_help" }
)
```

### Fetch Prompts


Fetch the prompt by name and label (optional) :

```ruby
prompt = Langfuse.prompts.fetch(name: "stress_coach", label: "production")
template = prompt[:prompt] # => "Hello {{name}}, let's talk about {{topic}}."
```


If using variables in prompt, you will need to replace them with your own data. You can use a Prompt compiler for that.

Prompt compiler example :

```ruby
module PromptCompiler
  # Replaces {{var}} tokens with supplied values.
  def self.compile(template, vars = {})
    template.gsub(/{{\s*(\w+)\s*}}/) do
      key = Regexp.last_match(1).to_sym
      vars.fetch(key) { "{{#{key}}}" }  # leave token if missing
    end
  end
end
```

Then :

```ruby
filled = PromptCompiler.compile(template, name: "Alex", topic: "stress")
```

### End-to-End example


```ruby
class AiCompanionService
  def initialize(user:)
    @user = user
    @client = LangfusePromptClient.new(
      public_key: ENV["LANGFUSE_PUBLIC_KEY"],
      secret_key: ENV["LANGFUSE_SECRET_KEY"]
    )
  end

  def reply(prompt_vars:)
    # 1. Pull the latest “stress_coach” prompt from Langfuse
    prompt_json = @client.fetch(name: "stress_coach", label: "production")
    template    = prompt_json[:prompt]          # raw text with {{variables}}
    config      = prompt_json[:config] || {}    # model/temperature/etc.

    # 2. Interpolate variables coming from your Rails app
    system_prompt = PromptCompiler.compile(template, prompt_vars)

    # 3. Hand off to RubyLLM
    response = RubyLLM.chat(
      prompt: system_prompt,
      model:  config["model"] || "gpt-4o-mini",
      temperature: config["temperature"] || 0.7
    )

    # 4. (Optional) include prompt reference in your trace/span
    LangfuseLogger.log_span(
      trace_id:   SecureRandom.uuid,
      name:       "ai_companion_generation",
      input:      system_prompt,
      output:     response.text,
      user_id:    @user.id,
      metadata:   { langfuse_prompt: prompt_json.slice(:name, :version) },
      langfuse_public_key: ENV["LANGFUSE_PUBLIC_KEY"],
      langfuse_secret_key: ENV["LANGFUSE_SECRET_KEY"]
    )

    response.text
  end
end
```
