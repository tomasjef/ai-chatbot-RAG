# HALO - AI Banking Support Assistant

HALO is an MVP AI support assistant for a fictional UK digital bank. Customers can ask questions about account terms, cards, disputes, and general support, and receive short answers grounded in the bank's uploaded PDF documents.

The app includes a simple admin flow for adding source PDFs. Uploaded documents are parsed into a searchable knowledge base, and each answer includes source links so the original PDF can be opened for context.

## What It Does

- Customer-facing chat for banking support questions.
- Admin PDF upload for the assistant knowledge base.
- Answers constrained to uploaded document content.
- Clickable PDF source references.
- Lightweight per-tab context for follow-up questions.
- Basic demo protection and request rate limiting.

## Stack

- Ruby on Rails
- PostgreSQL with pgvector
- OpenAI embeddings and responses
- Hotwire, Stimulus, SCSS
- Propshaft and Dart Sass

## Demo Sources

The included demo uses the PDFs in `db/source_pdfs/halo`. In other deployments, the assistant answers from whichever PDFs are uploaded through the admin knowledge-base flow.
