class ChunkingService
  CHUNK_SIZE = 150
  OVERLAP = 30

  def self.call(text)
    new.call(text)
  end

  def call(text)
    words = text.to_s.split
    chunks = []
    start = 0

    while start < words.length
      chunks << words[start, CHUNK_SIZE].join(" ")
      start += CHUNK_SIZE - OVERLAP
    end

    chunks
  end
end
