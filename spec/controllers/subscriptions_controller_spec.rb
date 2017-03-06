require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  context 'GET new' do
    context 'when unauthenticated' do
      before do
        get :new
      end

      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'when authenticated' do
      context 'and no subscription' do
        before do
          user = create(:user)
          sign_in(user)
          get :new
        end

        it { expect(response).to render_template(:new) }
        it { expect(assigns(:presenter)).to be_a(SubscriptionsPresenter) }
      end

      context 'and subscription' do
        before do
          subscriber = create(:subscriber)
          sign_in(subscriber)
          get :new
        end

        it { expect(response).to render_template(:edit) }
        it { expect(assigns(:presenter)).to be_a(SubscriptionsPresenter) }
      end
    end
  end

  context 'POST create' do
    let(:user) { create(:user) }

    context 'when unauthenticated' do
      it 'redirects to login' do
        post :create
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      context 'and no subscription' do
        before do
          sign_in(user)
        end

        let(:params) {{ subscription: subscription_params, stripeToken: Faker::Lorem.characters(20) }}
        let(:subscription_params) {{ }}

        context 'and subscription is valid' do
          it 'create the subscription' do
            expect(user.subscription).to be nil
            expect { post :create, params: params }.to change { Subscription.count }.by(1)
            user.reload
            expect(user.subscription).to be_a Subscription
          end

          it 'redirects to account path' do
            post :create, params: params
            expect(response).to redirect_to(account_path)
          end

          it 'has the correct flash message' do
            post :create, params: params
            expect(flash[:success]).to match I18n.t('flash.subscription_success')
          end

          it 'schedules a job' do
            expect { post :create, params: params }.to change{ SubscriptionWorker.jobs.size }.by(1)
          end
        end

        context 'and subscription is not valid' do
          before do
            expect(subject).to receive(:create_subscription).and_return(false)
          end

          it 'does not create the subscription' do
            expect(user.subscription).to be nil
            expect { post :create, params: params }.not_to change { Subscription.count }
            user.reload
            expect(user.subscription).to be nil
          end

          it 'redirects to new' do
            post :create, params: params
            expect(response).to redirect_to(new_subscription_path)
          end

          it 'has the correct flash message' do
            post :create, params: params
            expect(flash[:error]).to match I18n.t('flash.subscription_error')
          end
        end
      end

      context 'and subscription' do
        before do
          sign_in(user)
        end

        let(:user) { create(:subscriber) }
        let(:params) {{ subscription: subscription_params }}
        let(:subscription_params) {{ stripeToken: Faker::Lorem.characters(20) }}

        it 'does not allow a second subscription' do
          post :create, params: params
          expect(response).to redirect_to(edit_subscription_path)
        end

        it 'has the correct flash message' do
          post :create, params: params
          expect(flash[:notice]).to match I18n.t('flash.subscription_already_exists')
        end
      end
    end
  end

  context 'GET edit' do
    let(:subscription) { create(:subscription) }

    context 'with id' do
      context 'when unauthenticated' do
        it 'redirects to login' do
          get :edit, params: { id: subscription.id }
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'when authenticated' do
        let(:user) { create(:subscriber) }

        before do
          sign_in(user)
          get :edit, params: { id: subscription.id }
        end

        context 'and unauthorized' do
          let(:different_user) { create(:subscriber) }
          let(:subscription) { different_user.subscription }
          it { expect(response).to redirect_to(dashboard_path) }
        end

        context 'and authorized' do
          let(:subscription) { user.subscription }
          it { expect(response).to render_template(:edit) }
          it { expect(assigns(:presenter)).to be_a(SubscriptionsPresenter) }
        end
      end
    end

    context 'with no id' do
      context 'when unauthenticated' do
        it 'redirects to login' do
          get :edit
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'when authenticated' do
        let(:user) { create(:subscriber) }
        let(:subscription) { user.subscription }

        before do
          sign_in(user)
          get :edit
        end

        it { expect(response).to render_template(:edit) }
        it { expect(assigns(:presenter)).to be_a(SubscriptionsPresenter) }
      end
    end
  end

  context 'PATCH update' do
    let(:user) { create(:user) }

    context 'when unauthenticated' do
      it 'redirects to login' do
        patch :update, params: { id: 1 }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      before do
        sign_in(user)
      end

      let(:user) { create(:subscriber) }

      context 'without stripe token' do
        it 'redirects to edit subscription path' do
          patch :update, params: { id: 1 }
          expect(response).to redirect_to(edit_subscription_path)
          expect(flash[:error]).to match I18n.t('flash.subscription_not_updated')
        end
      end

      context 'with stripe token' do
        let(:token) { Faker::Lorem.characters(20) }

        it 'calls SubscriptionWorker' do
          expect(SubscriptionWorker).to receive(:perform_async).with(user.id, token)
          patch :update, params: { id: user.subscription.id, stripeToken: token }
          expect(response).to redirect_to(account_path)
          expect(flash[:success]).to match I18n.t('flash.subscription_updated')
        end
      end
    end
  end

  context 'DELETE destroy' do
    let(:subscriber) { create(:subscriber) }
    let(:subscription) { subscriber.subscription }
    let(:result) { delete :destroy, params: { id: subscription.id } }

    context 'unauthenticated' do
      it 'redirects to login' do
        result
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'authenticated' do
      before do
        sign_in subscriber
      end

      it 'cancels a Stripe subscription' do
        expect(subject).to receive(:cancel_subscription)
        result
      end
    end
  end
end
