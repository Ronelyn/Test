module ApplicationHelper

  def count_current_client_store_visits
    session[:counter, 1] if session[:counter].nil?
    session[:counter]
  end

end
