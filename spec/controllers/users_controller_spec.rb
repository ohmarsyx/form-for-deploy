require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # index
  describe 'GET #index' do
    it 'assigns @users and @user' do
      user = User.create!(first_name: 'John', last_name: 'Doe', email: 'john@example.com', birthday: '2000-01-01', gender: "male", phone: '0987654321', subject: "CSS")
      get :index

      expect(assigns(:users)).to match_array([user])
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'responds successfully' do
      get :index
      expect(response).to be_successful
    end
  end

  # show
  describe 'GET #show' do
    it 'responds successfully' do
      user = User.create!(first_name: 'John', last_name: 'Doe', email: 'john@example.com', birthday: '2000-01-01', gender: "male", phone: '0987654321', subject: "CSS")
      get :show, params: { id: user.id }
      expect(response).to be_successful
    end
  end

  # modal
  describe 'GET #modal' do
    let!(:user) { User.create!(first_name: 'John', last_name: 'Doe', email: 'john@example.com', birthday: '2000-01-01', gender: "male", phone: '0987654321', subject: "CSS") }

    context 'with turbo_stream format' do
      it 'renders the modal turbo_stream' do
        get :modal, params: { id: user.id, format: :turbo_stream }
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        expect(response.body).to include('modal') # Assuming the partial contains modal HTML
      end
    end

    context 'with html format' do
      it 'responds successfully' do
        get :modal, params: { id: user.id, format: :turbo_stream }
        expect(response).to be_successful
      end
    end
  end

  # create
  describe 'POST #create' do
  context 'with valid params' do
    it 'creates a new user' do
      expect {
        post :create, params: { user: { first_name: 'John', last_name: 'Doe', email: 'john@example.com', birthday: '2000-01-01', gender: "male", phone: '0987654321', subject: "CSS" } }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(users_path)
    end
  end
  context 'with invalid attributes' do
    let(:invalid_attributes) do
      {
        first_name: '',   
        last_name: '',    
        email: 'invalid', 
        birthday: ''      
      }
    end

    it 're-renders the new template with unprocessable entity status' do
      post :create, params: { user: invalid_attributes }

      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

  # destroy
  describe 'DELETE #destroy' do
    let!(:user) { User.create!(first_name: 'John', last_name: 'Doe', email: 'john@example.com', birthday: '2000-01-01', gender: "male", phone: '0987654321', subject: "CSS") }

    context 'with turbo_stream format' do
      it 'deletes the user and renders a reload script' do
        expect {
          delete :destroy, params: { id: user.id }, format: :turbo_stream
        }.to change(User, :count).by(-1)

        expect(response.body).to include('window.location.reload()')
      end
    end

    context 'with html format' do
      it 'deletes the user and redirects to index' do
        expect {
          delete :destroy, params: { id: user.id }, format: :html
        }.to change(User, :count).by(-1)
        expect(response).to redirect_to(users_path)
      end
    end
  end

  # new
  describe 'GET #new' do
    before do
      get :new
    end

    it 'assigns a new User to @user' do
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'responds with a successful status' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end
end
