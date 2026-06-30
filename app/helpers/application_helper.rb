module ApplicationHelper
  def source_payload(entries)
    Array(entries).filter_map do |entry|
      url = source_document_url(entry)
      next if url.blank?

      {
        title: entry.title,
        url: url
      }
    end
  end

  def source_button(source)
    label = source[:title] || source["title"]
    url = source[:url] || source["url"]
    classes = [ "source-button" ]
    classes << "source-button--disabled" if url.blank?

    content = safe_join([
      document_icon,
      tag.span(label, class: "source-button__label")
    ])

    if url.present?
      link_to(content, url, class: classes, target: "_blank", rel: "noopener", aria: { label: "Open source document: #{label}" })
    else
      tag.span(content, class: classes, aria: { label: "Source document unavailable: #{label}" })
    end
  end

  private

  def source_document_url(entry)
    return unless entry.document&.source_available?

    document_path(entry.document)
  end

  def document_icon
    tag.svg(
      tag.path(d: "M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z") +
        tag.path(d: "M14 2v6h6") +
        tag.path(d: "M8 13h8") +
        tag.path(d: "M8 17h6"),
      class: "source-button__icon",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: 2,
      stroke_linecap: "round",
      stroke_linejoin: "round",
      aria: { hidden: true }
    )
  end
end
