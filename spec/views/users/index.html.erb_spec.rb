require 'rails_helper'

RSpec.describe "users/index.html.erb", type: :view do
  before do
    @users = assign(:users, [
      User.create!(first_name: 'John', last_name: 'Doe', email: 'john@example.com', birthday: '2000-01-01', gender: 'Male', phone: '123-456-7890', subject: 'Math')
    ])
    render
  end

  it 'renders the users list with correct content' do
    expect(rendered).to have_selector('h1', text: 'Users')
    expect(rendered).to have_button('Add user')

    expect(rendered).to have_content('Name: John Doe')
    expect(rendered).to have_content('BOD: 2000-01-01')
    expect(rendered).to have_content('Gender: male')
    expect(rendered).to have_content('Email: john@example.com')
    expect(rendered).to have_content('Phone: 123-456-7890')
    expect(rendered).to have_content('Subject: Math')
  end

  it 'includes the Turbo frame for the modal' do
    expect(rendered).to have_selector("turbo-frame#modal")
  end

  it 'renders the registration_modal partial' do
    expect(rendered).to have_content('Name: John Doe')
  end
end
