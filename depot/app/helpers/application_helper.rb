module ApplicationHelper

  def count_current_client_store_visits
    session[:counter, 1] if session[:counter].nil?
    session[:counter]
  end
  
  def generate_hidden_div_if(condition, attributes = {}, &block)
    if condition
      attributes["style"] = "display: none"
    end
    content_tag("div", attributes, &block)
  end

end
