module ApplicationHelper
  def neon_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:p, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      count: resource.errors.count,
                      resource: resource.class.model_name.human.downcase)

    html = <<-HTML
    <div class="form-login-error">
      <h3>#{sentence}</h2>
      #{messages}
    </div>
    HTML

    html.html_safe
  end
end
