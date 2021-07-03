# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    authorize :session

    @session = Session.create(create_params)
    if @session.valid?
      session[:user_id] = @session.user_id

      redirect_to mentors_path
    else
      render :new, status: :bad_request # Maybe change this to Unauthorized instead?
    end
  end

  def new
    authorize :session

    @session = Session.new
  end

  def destroy
    authorize :session

    session.clear

    redirect_to '/'
  end

  private

  def create_params
    params.require(:session).permit(:email, :password)
  end
end
