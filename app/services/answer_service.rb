class AnswerService
  MODEL = "gpt-4.1-mini"

  def self.call(question, entries)
    new.call(question, entries)
  end

  def call(question, entries)
    response = client.chat(
      parameters: {
        model: MODEL,
        temperature: 0.2,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt(question, entries) }
        ]
      }
    )

    raw    = response.dig("choices", 0, "message", "content")
    parsed = JSON.parse(raw)

    used_numbers = Array(parsed["sources"]).map(&:to_i)
    used_entries = used_numbers.map { |n| entries[n - 1] }.compact

    { answer: parsed["answer"], used_entries: used_entries }
  rescue JSON::ParserError
    { answer: raw, used_entries: [] }
  end

  private

  def user_prompt(question, entries)
    numbered = entries.each_with_index.map do |e, i|
      "Source #{i + 1}: #{e.title}\n#{e.content}"
    end.join("\n\n")

    "Context:\n#{numbered}\n\nQuestion: #{question}"
  end

  def system_prompt
    <<~PROMPT
      You are a helpful customer support assistant for an online electronics store.
      Answer the customer's question using ONLY the information in the provided sources.
      If the answer is not in the sources, say you don't have that information and
      suggest contacting support. Never invent policies, prices, or details.

      Respond with a JSON object containing exactly two keys:
      - "answer": your reply to the customer, as a string.
      - "sources": an array of the source numbers you actually used to write the
        answer (for example [1, 3]). If you used none, return an empty array [].
    PROMPT
  end

  def client
    @client ||= OpenAI::Client.new
  end
end
