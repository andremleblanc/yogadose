require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let(:user) {create(:user)}

  context 'GET edit' do
    context 'when unauthenticated' do
      before do
        get :edit
      end

      it {expect(response).to redirect_to(new_user_session_path)}
    end

    context 'when authenticated' do
      before do
        sign_in(user)
        get :edit
      end

      it {expect(response).to render_template(:edit)}
      it {expect(assigns(:presenter)).to be_a(SubscriptionsPresenter)}
    end
  end

  context 'POST create' do
    let(:user) {create(:user)}

    context 'when unauthenticated' do
      it 'redirects to login' do
        post :create
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      let(:params) {{stripeToken: Stripe::Token.create(card: {number: '4242424242424242', exp_month: 10, exp_year: 2017, cvc: 222}).id}}

      context 'and user is inactive' do
        before do
          sign_in(user)
        end

        context 'and stripe_token is present' do
          it 'create the subscription' do
            VCR.use_cassette('controllers/subscriptions/create') do
              expect(user.active?).to be false
              post :create, params: params
              user.reload
              expect(user.active?).to be true
            end
          end

          it 'redirects to dashboard' do
            VCR.use_cassette('controllers/subscriptions/create') do
              post :create, params: params
              expect(response).to redirect_to(dashboard_path)
            end
          end

          it 'has the correct flash message' do
            VCR.use_cassette('controllers/subscriptions/create') do
              post :create, params: params
              expect(flash[:success]).to match I18n.t('flash.subscription_success')
            end
          end
        end
      end

      context 'and subscription' do
        before do
          sign_in(user)
        end

        let(:user) {create(:user, stripe_id: 'cus_APubYfmbfmE06U')}

        it 'does not allow a second subscription' do
          VCR.use_cassette('controllers/subscriptions/create_existing') do
            post :create, params: params
            expect(response).to redirect_to(subscription_path)
          end
        end

        it 'has the correct flash message' do
          VCR.use_cassette('controllers/subscriptions/create_existing') do
            post :create, params: params
            expect(flash[:notice]).to match I18n.t('flash.subscription_already_exists')
          end
        end
      end
    end
  end

  context 'PATCH update' do
    let(:user) {create(:user)}

    context 'when unauthenticated' do
      it 'redirects to login' do
        patch :update, params: {id: 1}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      before do
        sign_in(user)
      end

      let(:user) {create(:user, stripe_id: 'cus_APAdfK1YEMXFiX')}

      context 'with stripe token' do
        let(:params) {{stripeToken: Stripe::Token.create(card: {number: '4242424242424242', exp_month: 10, exp_year: 2017, cvc: 222}).id}}

        it 'updates the source on the subscription' do
          VCR.use_cassette('controllers/subscriptions/update') do
            original = user.source
            patch :update, params: params
            user.reload
            expect(user.source).not_to eq (original)
            expect(flash[:success]).to match I18n.t('flash.subscription_updated')
          end
        end
      end
    end
  end

  context 'POST reactivate' do
    let(:user) {create(:user)}

    context 'when unauthenticated' do
      it 'redirects to login' do
        post :reactivate
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      before do
        sign_in(user)
      end

      context 'and cancelling' do
        let(:user) {create(:user, stripe_id: 'cus_AV8QGNjX4RE1j0')}

        it 'reactivates the subscription' do
          VCR.use_cassette('controllers/subscriptions/reactivate_success') do
            expect(user.cancelling?).to be true
            post :reactivate
            user.reload
            expect(user.active?).to be true
            expect(flash[:success]).to match I18n.t('subscriptions.reactivate.success')
          end
        end
      end

      context 'and active' do
        let(:user) {create(:user, stripe_id: 'cus_APuk2Rg1xJKvU8')}

        it 'renders error message' do
          VCR.use_cassette('controllers/subscriptions/reactivate_failure') do
            expect(user.active?).to be true
            post :reactivate
            expect(flash[:error]).to match I18n.t('subscriptions.reactivate.already_active')
          end
        end
      end
    end
  end

  context 'DELETE destroy' do
    let(:user) {create(:user)}

    context 'when unauthenticated' do
      it 'redirects to login' do
        delete :destroy
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      before do
        sign_in(user)
      end

      let(:user) {create(:user, stripe_id: 'cus_AV8QGNjX4RE1j0')}

      context 'with stripe token' do
        it 'updates the source on the subscription' do
          VCR.use_cassette('controllers/subscriptions/destroy') do
            expect(user.active?).to be true
            delete :destroy
            user.reload
            expect(user.cancelling?).to be true
          end
        end
      end
    end
  end
end
