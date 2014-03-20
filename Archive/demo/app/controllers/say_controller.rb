class SayController < ApplicationController
  def hello
    @time = Time.now.to_formatted_s(:long)
    @current_directory_files = Dir.glob('*')
  end
  
  def list_current_directory_files()
    @current_directory_files = Dir.glob('*')
  end
  
  def goodbye
  end
end
