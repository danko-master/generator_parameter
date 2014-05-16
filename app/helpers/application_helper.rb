module ApplicationHelper
  def nav_link(link_text, link_path)
    recognized = Rails.application.routes.recognize_path(link_path)
    class_name = current_page?(:controller => recognized[:controller], :action => recognized[:action]) ? 'active' : ''
    
    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end  
end
