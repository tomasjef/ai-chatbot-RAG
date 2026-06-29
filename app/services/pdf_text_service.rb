require "pdf/reader"

class PdfTextService
  def self.call(file_path)
    new.call(file_path)
  end

  def call(file_path)
    reader = PDF::Reader.new(file_path)
    reader.pages.map(&:text).join("\n\n")
  end
end
