# Langfuse Client (Unofficial)

**Unofficial Ruby client for [Langfuse](https://langfuse.com)** — designed to support:
- Prompt management
- LLM span and trace logging
- Session-aware workflows

> ✅ Built for use in Rails apps, but works in any Ruby project.

---

## ⚠️  Disclaimer

This is an **unofficial gem**, not affiliated with the Langfuse team.

If Langfuse releases an official Ruby SDK, consider migrating when stable.

This gem is for my own usage, maintenance will be minimal.

---

## Installation

gem "langfuse_client"


---

## Configuration

Set these environment variables in your Rails app or .env file:

```
LANGFUSE_DOMAIN=http://localhost:3001        # or https://cloud.langfuse.com
LANGFUSE_API_PATH=/api/public
LANGFUSE_PUBLIC_KEY=your_public_key
LANGFUSE_SECRET_KEY=your_secret_key
```

---

## Usage

### Log span

```
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

```
prompt = Langfuse.prompts.fetch(name: "stress_coach", label: "production")
template = prompt[:prompt] # => "Hello {{name}}, let's talk about {{topic}}."
```


If using variables in prompt, you will need to replace them with your own data. You can use a Prompt compiler for that.

Prompt compiler example :

```
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

```
filled = PromptCompiler.compile(template, name: "Alex", topic: "stress")
```
