module BlockPartialHelper
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    render(:partial => partial_name, :locals => options)
  end

  # Create as many of these as you like, each should call a different partial
  def bootstrap_default_modal(title, options = {}, &block)
    block_to_partial('modal', options.merge(:title => title), &block)
  end
end