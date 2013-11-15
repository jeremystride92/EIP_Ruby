module ApplicationHelper
  def body_tag_id
    format "%s-%s", controller.controller_path.parameterize, controller.action_name
  end

  def body_tag_class
    format "controller-%s action-%s", controller.controller_path.parameterize, controller.action_name
  end

  def nav_link(*args, &block)
    options = args.extract_options!
    if block
      path = args.first
    else
      content, path = *args
    end

    css_class = current_page?(path) ? 'active' : nil
    content_tag :li, class: css_class do
      if block
        link_to path, options do
          yield block
        end
      else
        link_to content, path, options
      end
    end
  end

  # SimpleForm does not provide a helper to display base errors - those that are not associated with a specific form field.
  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def last_promoted_date (card_level)
    "(Last Promoted: #{card_level.promotional_messages.last.send_date_time.strftime('%m/%d/%Y')})" if card_level.promotional_messages.count > 0
  end

  def promotion_name (card_level)
    [[name, last_promoted_date(card_level), aggregate_promotion_clicks].join(" "), id]
  end

  def present_for_promotion(card_levels)
    card_levels.map do |card_level|
      promotion_name(card_level)
    end
  end
end
