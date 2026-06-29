require "fileutils"

class DemoPdfBuilder
  PAGE_WIDTH = 612
  PAGE_HEIGHT = 792
  LEFT = 72
  TOP = 720
  LINE_HEIGHT = 15
  WRAP_AT = 82

  def self.call(title:, body:, path:)
    new.call(title: title, body: body, path: path)
  end

  def call(title:, body:, path:)
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, pdf(title, body))
    path
  end

  private

  def pdf(title, body)
    content = page_stream(title, body)
    objects = [
      "<< /Type /Catalog /Pages 2 0 R >>",
      "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
      "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 #{PAGE_WIDTH} #{PAGE_HEIGHT}] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>",
      "<< /Length #{content.bytesize} >>\nstream\n#{content}\nendstream",
      "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"
    ]

    output = +"%PDF-1.4\n"
    offsets = [ 0 ]

    objects.each_with_index do |object, index|
      offsets << output.bytesize
      output << "#{index + 1} 0 obj\n#{object}\nendobj\n"
    end

    xref_offset = output.bytesize
    output << "xref\n0 #{objects.size + 1}\n"
    output << "0000000000 65535 f \n"
    offsets.drop(1).each { |offset| output << format("%010d 00000 n \n", offset) }
    output << "trailer\n<< /Size #{objects.size + 1} /Root 1 0 R >>\n"
    output << "startxref\n#{xref_offset}\n%%EOF\n"
  end

  def page_stream(title, body)
    lines = wrapped_lines("#{title}\n\n#{body}")

    commands = [
      "BT",
      "/F1 11 Tf",
      "#{LEFT} #{TOP} Td",
      "#{LINE_HEIGHT} TL"
    ]

    lines.first(42).each do |line|
      commands << "(#{escape(line)}) Tj"
      commands << "T*"
    end

    commands << "ET"
    commands.join("\n")
  end

  def wrapped_lines(text)
    text.to_s.lines.flat_map do |line|
      line = line.strip
      next [ "" ] if line.blank?

      line.scan(/.{1,#{WRAP_AT}}(?:\s+|$)/).map(&:strip)
    end
  end

  def escape(text)
    text.to_s.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "")
      .gsub("\\", "\\\\\\")
      .gsub("(", "\\(")
      .gsub(")", "\\)")
  end
end
