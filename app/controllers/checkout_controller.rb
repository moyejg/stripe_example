class CheckoutController < ApplicationController

  def create

    if user_signed_in? != true
      redirect_to root_path
    end

    @customer = Stripe::Customer.create({
      email: current_user.email
    })

    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      mode: 'setup',
      customer: @customer,
      success_url: checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: checkout_cancel_url
    )

    respond_to do |format|
      format.js # render create.js.erb
    end

  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @setup_intent = Stripe::SetupIntent.retrieve(@session.setup_intent)
    # get customer_id from session/setupintent and attach to user in rails
    current_user.update(stripe_customer_id: @setup_intent.customer)
  end

  def cancel

  end

end
