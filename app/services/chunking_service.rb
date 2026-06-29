class ChunkingService
  CHUNK_SIZE = 150  # approximate words per chunk
  OVERLAP    = 30   # words shared between neighbouring chunks

  def self.call(text)
    new.call(text)
  end

  def call(text)
    words  = text.split
    chunks = []
    start  = 0

    while start < words.length
      chunks << words[start, CHUNK_SIZE].join(" ")
      start  += CHUNK_SIZE - OVERLAP
    end

    chunks
  end
end
