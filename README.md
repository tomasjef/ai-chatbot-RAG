# HALO — RAG-Powered Banking Support Assistant

A retrieval-augmented generation (RAG) chatbot built in Ruby on Rails. Upload PDF documents, ask questions in plain English, and get answers grounded in the actual text — with the source passages shown alongside every response.

Built as a portfolio piece to demonstrate how RAG works end-to-end in a conventional web stack, without reaching for a Python framework or a managed vector-search service.

---

## What it does

- **Admin**: upload PDFs, which are parsed, chunked, embedded, and stored
- **Customer**: ask a question in natural language, get an answer generated from the most relevant document passages, with citations showing exactly which parts of the knowledge base were used

---

## Architecture

```text
PDF upload
    │
    ▼
PdfTextService        — extracts raw text page by page (pdf-reader gem)
    │
    ▼
ChunkingService       — sliding window: 150-word chunks, 30-word overlap
    │
    ▼
EmbeddingService      — OpenAI text-embedding-3-small → 1536-dim vector
    │
    ▼
PostgreSQL/pgvector   — stores vectors in knowledge_entries table
```

```text
User question
    │
    ▼
EmbeddingService      — embeds the question with the same model
    │
    ▼
RetrievalService      — cosine similarity search via pgvector, top 5 entries
    │
    ▼
AnswerService         — GPT-4.1-mini, temperature 0.2, JSON mode
    │
    ▼
Answer + source chips — structured response: answer string + used source numbers
```

### Data model

```text
Assistant
  ├── has_many :documents
  └── has_many :knowledge_entries

Document          — tracks the uploaded file (filename, assistant)
KnowledgeEntry    — one chunk: title, content, embedding vector, document ref
```

`Assistant` holds the system prompt, making it straightforward to run multiple assistants (e.g. one per product area) from the same codebase.

### Assistant profiles

Visual identity and customer-facing copy live in `config/assistant_profiles.yml`.
Each profile can set the app name, logo asset, badge, hero copy, form labels,
font stylesheet, font CSS variables, brand colors, shadows, and background
treatment. The layout structure stays shared in the Rails views; profile values
are exposed as CSS custom properties on `<body>`.

To adapt the app for a new assistant, add a profile block, add any logo asset to
`app/assets/images`, and either name the assistant to match the profile key or
list the assistant name under `assistant_names`. `ASSISTANT_PROFILE=legal` can
also force a profile for local preview.

---

## Key decisions

### pgvector over a dedicated vector database

Keeping embeddings in Postgres means the entire application — relational data, vectors, and foreign keys between them — lives in one place. There's no Pinecone account to manage, no eventual consistency between what Postgres knows and what the vector store knows, and cascading deletes (`document.destroy` removes its `knowledge_entries`) work exactly as they do everywhere else in Rails.

The tradeoff: Postgres does exact nearest-neighbour search by default (no index), which scales linearly with the number of rows. For a knowledge base of a few thousand entries this is fine; at tens of thousands an IVFFlat or HNSW index would be needed (see "Production hardening" below).

### Overlapping chunks

`ChunkingService` uses a 30-word overlap between adjacent 150-word chunks. This means a sentence that falls near a chunk boundary appears in two chunks, so a query matching that sentence has a chance of retrieving the surrounding context from either side. Without overlap, boundary sentences can be retrieved without enough context to be useful.

The numbers (150/30) are a reasonable starting point, not a measured optimum. The right values depend on document structure — dense legal text wants smaller chunks than structured FAQ content.

### JSON-mode responses with source attribution

`AnswerService` forces a structured response:

```json
{ "answer": "Your overdraft limit is £500.", "sources": [2, 4] }
```

The model is instructed to list only the source numbers it actually used. The controller maps those back to the retrieved `KnowledgeEntry` records and passes them to the view as `@used_entries`. This is the traceability mechanism: every answer is tied to specific passages in specific documents, not to the knowledge base in aggregate. If an answer is wrong, you can see exactly which chunks the model was working from.

Temperature 0.2 reduces hallucination tendency on factual retrieval tasks. The model is still completing, not just extracting — it synthesises across sources — but lower temperature keeps it close to what the documents say.

### Synchronous ingestion

PDF parsing and embedding happen in the controller request. For a demo this is fine; for any real load it's the first thing to fix (see below). The architectural slot is already correct — `IngestionService` is a plain service object, so wrapping it in an `ApplicationJob` is a one-line change at the call site.

---

## Running locally

**Prerequisites:** Ruby 3.3, PostgreSQL with the `vector` extension, an OpenAI API key.

```bash
# Install dependencies
bundle install

# Set up the database
bin/rails db:create db:migrate db:seed

# Set your OpenAI key
export OPENAI_API_KEY=sk-...

# Optional: protect the public demo with a shared password
export DEMO_USERNAME=demo
export DEMO_PASSWORD=choose-a-real-password

# Optional: override admin credentials
export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=choose-a-different-real-password

# Start the server and SCSS watcher
bin/dev
```

The admin panel is at `/admin/assistants` and uses HTTP Basic Auth. Set
`ADMIN_PASSWORD` before deploying; production refuses admin access when it is
missing. `ADMIN_USERNAME` defaults to `admin`.

The demo knowledge base is generated from the text files in
`db/demo_documents/halo`. Running `bin/rails db:seed` turns those files into
dummy PDF documents, ingests them, and attaches the PDFs so source links open
real documents.

---

## Demo protection

The OpenAI API key stays server-side in `OPENAI_API_KEY`; it is never sent to
the browser. A public visitor still triggers OpenAI calls through `/ask`, though,
so a public portfolio deployment should set `DEMO_PASSWORD`.

When `DEMO_PASSWORD` is present, the public assistant pages use HTTP Basic Auth.
`DEMO_USERNAME` defaults to `demo`. When `DEMO_PASSWORD` is absent, the public
demo remains open for local development.

The `/ask` endpoint is also rate-limited with Rails' built-in controller rate
limiter. Defaults are 20 questions per IP per hour:

```bash
export ASK_RATE_LIMIT_MAX=20
export ASK_RATE_LIMIT_WINDOW_SECONDS=3600
```

For a live portfolio demo, also set a small OpenAI project budget as the final
spend backstop.

---

## Production hardening

These are the gaps knowingly left open for a portfolio demo.

### Background jobs for ingestion

The current flow blocks the web process while parsing PDFs and making N+1 OpenAI embedding calls (one per chunk). A 50-page document generates ~150 chunks, meaning ~150 sequential API calls in a single request. The fix is straightforward — `IngestionService` becomes an `ActiveJob`, Solid Queue (already in the Gemfile) handles the queue, and the upload response becomes immediate with a status page or webhook when ingestion completes.

### Real authentication

`http_basic_authenticate_with` with hardcoded credentials is demo scaffolding. Production needs proper session-based auth (Devise or Rails' own `has_secure_password`) with role separation — at minimum an `admin` flag on a `User` model. The admin namespace is already isolated, so dropping in an authentication layer is additive.

### Document deduplication

Uploading the same PDF twice silently creates a second set of chunks and embeddings. The retrieval results then include duplicates, which wastes context window space and can make the model repeat itself. The fix: hash the file content on upload and reject (or offer to re-ingest) documents whose hash already exists for that assistant.

### Vector index for scale

Without an index, `nearest_neighbors` performs an exact scan — every query compares against every row. Postgres/pgvector supports IVFFlat and HNSW indexes. HNSW is generally preferred for query speed at the cost of higher memory and slower inserts. The right time to add it is when the knowledge base exceeds ~10,000 entries per assistant.

### Context window management

`AnswerService` passes all retrieved chunks into the prompt without checking their combined token count. For 5 chunks at 150 words each this is well within GPT-4.1-mini's window, but it's an assumption. The robust version counts tokens before sending (using `tiktoken`) and trims or re-ranks chunks if the total approaches the model's limit.

### Rate limiting

The `/ask` endpoint makes two OpenAI calls (embedding + completion) per request. No rate limiting currently exists, so a burst of traffic translates directly into a burst of API spend. Rack::Attack or a request-level throttle on the assistant's `ask` action is the standard fix.

### Streaming responses

The answer currently appears all at once when the full completion returns — typically 1–3 seconds. Streaming the completion via the OpenAI streaming API and Turbo Streams would make the UI feel substantially faster, particularly for longer answers.

### Conversation history

Each question is answered independently. For a real support product, maintaining a session-scoped conversation history (appended to the system prompt or kept as a separate message array) would allow follow-up questions to refer back to earlier answers.

---

## Stack

| Layer | Choice |
| --- | --- |
| Framework | Rails 8.1 |
| Database | PostgreSQL + pgvector |
| Vector search | neighbor gem (pgvector wrapper) |
| LLM | OpenAI GPT-4.1-mini |
| Embeddings | OpenAI text-embedding-3-small (1536d) |
| PDF parsing | pdf-reader |
| Asset pipeline | Propshaft + Dart Sass |
| Frontend | Hotwire (Turbo + Stimulus), no JS framework |
| Background jobs | Solid Queue (configured, not yet used for ingestion) |
