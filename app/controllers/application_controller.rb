require "digest"

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def authenticate_with_basic_auth(realm:, username:, password:)
    authenticate_or_request_with_http_basic(realm) do |given_username, given_password|
      secure_compare(given_username, username) && secure_compare(given_password, password)
    end
  end

  def authenticate_admin_access
    password = ENV["ADMIN_PASSWORD"].presence
    return render plain: "Admin password is not configured.", status: :service_unavailable if password.blank? && Rails.env.production?

    authenticate_with_basic_auth(
      realm: "Admin",
      username: ENV.fetch("ADMIN_USERNAME", "admin"),
      password: password || "halo-demo"
    )
  end

  def authenticate_demo_access
    return if demo_password.blank?

    authenticate_with_basic_auth(realm: "Demo", username: demo_username, password: demo_password)
  end

  def secure_compare(value, expected)
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(value.to_s),
      Digest::SHA256.hexdigest(expected.to_s)
    )
  end

  def demo_username
    ENV.fetch("DEMO_USERNAME", "demo")
  end

  def demo_password
    ENV["DEMO_PASSWORD"].presence
  end
end
