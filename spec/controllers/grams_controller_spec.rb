require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do
      gram = FactoryGirl.create(:gram)

      get :show, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found" do
      get :show, params: { id: 'TACOCAT' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path

    end

    it "should successfully show the new form" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require users to be logged in" do
      post :create, params: { gram: { message: "Hello" } }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in our database" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, params: { 
	gram: { 
	  message: 'Hello!',
	  image: fixture_file_upload("/image.png", "image/png")
	} 
      }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly deal with validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      gram_count = Gram.count
      post :create, params: { gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(gram_count).to eq Gram.count
    end
  end

  describe "grams#edit action" do
    it "should successfully show the edit form if the gram is found" do
      gram = FactoryGirl.create(:gram)

      get :edit, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error message if the gram is not found" do
      get :edit, params: { id: 'GASDF' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do
    it "shouldn't allow unauthorized users to update grams" do
      gram = FactoryGirl.create(:gram)

      patch :update, params: { id: gram.id }
      expect(response).to redirect_to new_user_session_path
    end
    it "should allow users to successfully update their own grams" do
      user = FactoryGirl.create(:user)
      gram = FactoryGirl.create(:gram, user_id: user.id)
      sign_in user

      patch :update, params: { id: gram.id, gram: { message: 'Updated gram' } }
      expect(response).to redirect_to root_path
      
      gram.reload
      expect(gram.message).to eq 'Updated gram'  
    end

    it "should have http 404 error if the gram cannot be found" do
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, params: { id: 'WOW' }
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status of unprocessable" do
      user = FactoryGirl.create(:user)
      gram = FactoryGirl.create(:gram, user_id: user.id)
      sign_in user
      patch :update, params: { id: gram.id, gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)

      gram.reload
      expect(gram.message).to eq "hello"
    end

    it "should not allow a user who did not create the gram to edit the gram" do
      user = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      gram = FactoryGirl.create(:gram, user_id: user2.id, message: "Initial Message")
      sign_in user

      patch :update, params: { id: gram.id, gram: { message: "I updated the gram!" } }
      expect(response).to have_http_status(:unauthorized)

      gram.reload
      expect(gram.message).to eq "Initial Message"

    end
  end

  describe "grams#destroy action" do
    it "should allow the user who created the gram to destroy the gram" do
      user = FactoryGirl.create(:user)
      gram = FactoryGirl.create(:gram, user_id: user.id)
      sign_in user

      delete :destroy, params: { id: gram.id }
      expect(response).to redirect_to root_path

      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil

    end

    it "should return a 404 message if we cannot find a gram with the id that is specified" do
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, params: { id: 'RANDOM' }
      expect(response).to have_http_status(:not_found)
    end

    it "shouldn't let unauthenticated users destroy a gram" do
      gram = FactoryGirl.create(:gram)
      delete :destroy, params: { id: gram.id }
      expect(response).to redirect_to new_user_session_path
    end

    it "shouldn't let a user who didn't create the gram destroy the gram" do
      user = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      gram = FactoryGirl.create(:gram, user_id: user2.id )
      sign_in user

      delete :destroy, params: { id: gram.id, user_id: user.id }
      expect(response).to have_http_status(:unauthorized)

      deleted_gram = gram.reload
      expect(gram).to eq deleted_gram
    end
  end
end

