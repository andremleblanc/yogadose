require 'rails_helper'

RSpec.describe RoutinesController, type: :controller do
  let!(:routine) { create(:routine) }

  describe 'GET index' do
    context 'when unauthenticated' do
      it 'renders index' do
        get :index
        expect(response).to render(:index)
      end
    end

    context 'when authenticated' do
      context 'and unauthorized' do
        pending
      end

      context 'and authorized' do
        pending
      end
    end
  end

  describe 'GET new' do
    context 'when unauthenticated' do
      it 'redirects to login' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      context 'and unauthorized' do
        pending
      end

      context 'and authorized' do
        pending
      end
    end
  end

  describe 'POST create' do
    context 'when unauthenticated' do
      it 'redirects to login' do
        post :create
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      context 'and unauthorized' do
        pending
      end

      context 'and authorized' do
        pending
      end
    end
  end

  describe 'GET show' do
    context 'when unauthenticated' do
      it 'redirects to login' do
        get :show, params: { id: routine.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      context 'and unauthorized' do
        pending
      end

      context 'and authorized' do
        pending
      end
    end
  end

  describe 'GET edit' do
    context 'when unauthenticated' do
      it 'redirects to login' do
        get :edit, params: { id: routine.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      context 'and unauthorized' do
        pending
      end

      context 'and authorized' do
        pending
      end
    end
  end

  describe 'PATCH update' do
    context 'when unauthenticated' do
      it 'redirects to login' do
        patch :update, params: { id: routine.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      context 'and unauthorized' do
        pending
      end

      context 'and authorized' do
        pending
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when unauthenticated' do
      it 'redirects to login' do
        delete :destroy, params: { id: routine.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      context 'and unauthorized' do
        pending
      end

      context 'and authorized' do
        pending
      end
    end
  end
end
