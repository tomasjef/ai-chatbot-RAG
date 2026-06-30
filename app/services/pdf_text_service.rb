require "pdf/reader"

class PdfTextService
  def self.call(file_path)
    new.call(file_path)
  end

  def call(file_path)
    PDF::Reader.new(file_path).pages.map(&:text).join("\n\n")
  end
end
