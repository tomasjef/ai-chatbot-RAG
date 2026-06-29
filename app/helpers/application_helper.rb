module ApplicationHelper
  def assistant_profile(assistant = nil)
    profiles = Rails.configuration.x.assistant_profiles || {}
    default_profile = profiles.fetch("default", {})
    requested_key = ENV["ASSISTANT_PROFILE"].presence || assistant&.profile_key
    profile_key = profiles.key?(requested_key) ? requested_key : matching_profile_key(profiles, assistant)
    profile_key ||= "default"

    default_profile.deep_merge(profiles.fetch(profile_key, {})).merge("key" => profile_key).deep_symbolize_keys
  end

  def assistant_theme_style(profile)
    profile.fetch(:theme, {}).map do |token, value|
      "--#{token.to_s.dasherize}: #{value};"
    end.join(" ")
  end

  def assistant_font_stylesheet_url(profile)
    profile[:font_stylesheet_url].presence
  end

  def source_payload(entries)
    Array(entries).map do |entry|
      {
        title: entry.title,
        url: source_document_url(entry)
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
    return unless entry.document&.pdf&.attached?

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

  def matching_profile_key(profiles, assistant)
    return unless assistant&.name.present?

    profiles.find do |_key, profile|
      Array(profile["assistant_names"]).include?(assistant.name)
    end&.first
  end
end
