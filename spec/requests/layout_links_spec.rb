require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have an About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end

  it "should have a Help page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end

   it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Contact"
    response.should have_selector('title', :content => "Contact")
    click_link "Home"
    response.should have_selector('title', :content => "Home")
  end

  describe "when not signed it" do

    it "should have a sign in link" do
      visit root_path
      response.should have_selector('a', :href => signin_path, :content => "Sign in")
    end
  end

  describe "when signed in" do

    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)
    end

    it "should have a sign out link" do
      visit root_path
      response.should have_selector('a', :href => signout_path, :content => "Sign out")
    end

    describe "as an administrator" do
      before(:each) do
        @user.toggle!(:admin)
      end

      it "should have a shift types link" do
        visit root_path
        response.should have_selector('a', :content => "Shift Types")
      end
    end
  end
end
