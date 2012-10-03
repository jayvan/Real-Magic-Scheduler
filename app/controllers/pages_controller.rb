class PagesController < ApplicationController
  before_filter :admin, :only => [:eot]
  
  def home
    redirect_to shifts_path if signed_in?
    @title = "Home"
  end

  def contact
  	@title = "Contact"
  end

	def about
		@title = "About"
	end
	
	def eot
	  @title = "End of Term"
	end
	
	def help
		@title = "Help"
	end
	
	def forgot_password
	  @title = "Password Reset"
	end
end
