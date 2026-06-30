source_paths = Dir[Rails.root.join("db/source_pdfs/halo/*.pdf")].sort
raise "Missing source PDFs in db/source_pdfs/halo" if source_paths.empty?

halo = Assistant.find_or_initialize_by(name: Assistant::ACTIVE_NAME)
halo.system_prompt = Assistant::DEFAULT_SYSTEM_PROMPT
halo.save!
puts "Created assistant: #{halo.name}"

Document.find_each do |document|
  document.pdf.purge if document.pdf.attached?
  document.destroy!
end
KnowledgeEntry.delete_all
Assistant.where.not(id: halo.id).delete_all
ActiveStorage::Blob.unattached.find_each(&:purge)
puts "Cleared existing source documents and knowledge entries"

total_count = source_paths.sum do |source_path|
  path = Pathname.new(source_path)
  count = IngestionService.call(halo, path, source_name: path.basename.to_s)
  puts "Ingested #{count} passages from #{path.basename}"
  count
end

puts "Ingested #{total_count} passages from #{source_paths.size} source PDFs"
