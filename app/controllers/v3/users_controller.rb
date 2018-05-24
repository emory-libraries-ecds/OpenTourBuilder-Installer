# frozen_string_literal: true

# app/controllers/v3/users_controller.rb
module V3
  class UsersController < V3Controller
    before_action :set_user, only: [:show, :update, :destroy]
    before_action :authenticate!, only: :me
    authorize_resource

    # GET /users
    # def index
    #   @users = User.all

    #   render json: @users
    # end
    def index
      puts current_user.present?
      # if current_user.present? && params['me']
          render json: current_user
      # elsif !current_user.confirmed
      #     render json: { errors: "Check email for #{current_user.identifier} for confirmation email." }.to_json, status: 401
      # else
      #     render json: {}.to_json, status: 401
      # end
    end

    # GET /users/1
    def show
      render json: @user
    end

    # POST /users
    def create
      @user = User.new(user_params)

      if @user.save && user.create_login(login_params)
        render json: @user, status: :created, location: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /users/1
    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # DELETE /users/1
    def destroy
      @user.destroy
    end

    def me
      user = @current_login.user
      if user.nil?
        render json: 'Invalid api token', status: :foo
      else
        render json: user
      end
    end

      private

        # Use callbacks to share common setup or constraints between actions.
        def set_user
          @user = User.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def user_params
          ActiveModelSerializers::Deserialization
              .jsonapi_parse(
                params, only: [
                      :displayname, :identification, :password,
                      :password_confirmation, :uid
                  ]
              )
        end

        def login_params
          ActiveModelSerializers::Deserialization
              .jsonapi_parse(
                params, only: [
                      :identification, :password,
                      :password_confirmation, :uid
                  ]
              )
        end
  end
end
