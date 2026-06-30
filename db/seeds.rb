source_paths = Dir[Rails.root.join("db/source_pdfs/halo/*.pdf")].sort
raise "Missing source PDFs in db/source_pdfs/halo" if source_paths.empty?

halo = Assistant.find_or_initialize_by(name: Assistant::ACTIVE_NAME)
halo.system_prompt = Assistant::DEFAULT_SYSTEM_PROMPT
halo.save!
puts "Created assistant: #{halo.name}"

total_count = 0
document_count = 0

source_paths.each do |source_path|
  path = Pathname.new(source_path)
  filename = path.basename.to_s

  if halo.documents.exists?(filename: filename)
    puts "Skipped #{filename}; already ingested"
    next
  end

  count = IngestionService.call(halo, path, source_name: filename)
  total_count += count
  document_count += 1
  puts "Ingested #{count} passages from #{filename}"
end

puts "Ingested #{total_count} passages from #{document_count} new source PDFs"
