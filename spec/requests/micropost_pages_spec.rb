require 'spec_helper'

describe "MicropostPages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do
      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information", :js => true do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction", :js => true do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:micropost, user: user)
      other_user.follow!(user)
    end

    describe "as correct user" do
      before { visit root_path }


      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end

    describe "as incorrect user" do
      before do
        sign_in other_user
        visit root_path
      end

      it { should_not have_selector('ol.microposts li a', text: 'delete') }
    end
  end

  describe "micropost count" do
    describe "as new user" do
      before { visit root_path }
      it { should have_content('0 microposts') }
    end
    describe "with one micropost" do
      before do
        FactoryGirl.create(:micropost, user: user)
        visit root_path
      end
      it { should have_content(/1 micropost[^s]/) }
    end
    describe "with two microposts" do
      before do
        FactoryGirl.create(:micropost, user: user)
        FactoryGirl.create(:micropost, user: user)
        visit root_path
      end
      it { should have_content('2 microposts') }
    end
  end

  describe "micropost pagination" do
    let (:user    ) { FactoryGirl.create(:user)                }
    let (:selector) { 'ol.microposts li#'                      }
    let (:first   ) { selector + user.microposts.last.id.to_s  }
    let (:last    ) { selector + user.microposts.first.id.to_s }

    before do
      31.times { FactoryGirl.create(:micropost, user: user) }
      sign_in user
    end

    describe "when on home page" do
      before { visit root_path }
      describe "micropost feed page 1" do
        it { should_not have_selector(first) }
        it { should     have_selector(last ) }
      end

      describe "micropost feed page 2" do
        before { click_link "Next" }
        it { should     have_selector(first) }
        it { should_not have_selector(last ) }
      end
    end

    describe "when on profile page" do
      before { visit user_path(user) }
      describe "micropost feed page 1" do
        it { should_not have_selector(first) }
        it { should     have_selector(last ) }
      end

      describe "micropost feed page 2" do
        before { click_link "Next" }
        it { should     have_selector(first) }
        it { should_not have_selector(last ) }
      end
    end
  end

  describe "micropost character count", :js => true do
    before { visit root_path }
    describe "when on home page" do
      it "should show remaining characters" do
        # save_and_open_page show the current page, handy!
        expect(page).to have_content("Micropost Feed")
      end
    end

  end
end
