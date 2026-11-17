require "test_helper"

class EmbeddingServiceTest < ActiveSupport::TestCase
  test "embeds passages in batches and keeps them in order" do
    requests = []
    fake_client = Object.new
    fake_client.define_singleton_method(:embeddings) do |parameters:|
      requests << parameters[:input]
      # OpenAI may return the items in any order; each carries its index
      { "data" => parameters[:input].each_with_index.map { |text, index| { "index" => index, "embedding" => [ text ] } }.reverse }
    end

    service = EmbeddingService.new
    service.instance_variable_set(:@client, fake_client)
    texts = Array.new(EmbeddingService::BATCH_SIZE + 1) { |index| "passage #{index}" }

    embeddings = service.batch(texts)

    assert_equal [ EmbeddingService::BATCH_SIZE, 1 ], requests.map(&:size)
    assert_equal texts.map { |text| [ text ] }, embeddings
  end

  test "an empty PDF makes no request" do
    assert_equal [], EmbeddingService.new.batch([])
  end
end
