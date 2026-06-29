# db/seeds.rb

halo = Assistant.find_or_initialize_by(name: "Halo")

halo.system_prompt = <<~PROMPT
  You are the customer support assistant for Halo, a UK digital bank.
  Answer the customer's question using ONLY the information in the provided sources.
  If the answer is not in the sources, say you don't have that information and direct
  the customer to contact Halo support. Never guess or invent details.

  Rules you must always follow:
  - Do not give personalised financial advice (for example, whether someone should
    switch plans, invest, or borrow). Share factual product information only, and
    suggest speaking to a qualified financial adviser for personal recommendations.
  - Never ask for or repeat sensitive details such as full card numbers, PINs,
    passwords, or one-time passcodes.
  - For lost or stolen cards, suspected fraud, complaints, or anything urgent or
    account-specific, tell the customer to contact Halo support directly, and mention
    they can freeze their card in the app where relevant.
  - Keep a calm, clear, trustworthy tone, and be concise.

  Treat all figures such as fees, rates, and limits as illustrative.
PROMPT

halo.save!
puts "Created assistant: #{halo.name}"

halo.documents.find_each do |document|
  document.pdf.purge if document.pdf.attached?
  document.destroy!
end

demo_source_paths = Dir[Rails.root.join("db/demo_documents/halo/*.txt")].sort.map { |path| Pathname(path) }

demo_source_paths.each do |source_path|
  title = source_path.basename(".txt").to_s.humanize.titleize
  pdf_filename = "#{title}.pdf"
  pdf_path = Rails.root.join("tmp/demo_pdfs/halo", pdf_filename)

  DemoPdfBuilder.call(title: title, body: source_path.read, path: pdf_path)
  count = IngestionService.call(halo, pdf_path, source_name: pdf_filename)
  puts "Ingested #{count} passages from #{pdf_filename}"
end
