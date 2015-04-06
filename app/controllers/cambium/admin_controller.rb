module Cambium
  class AdminController < ActionController::Base

    before_filter :authenticate_admin!

    layout "admin"

    include CambiumHelper

    def index
      @collection = admin_model.send(admin_table.scope)
    end

    def show
      set_object
      redirect_to(admin_routes.edit)
    end

    def new
      @object = admin_model.new
    end

    def create
      set_object
      @object = admin_model.new(create_params)
      if @object.save
        redirect_to(admin_routes.index, :notice => "#{admin_model.to_s} created!")
      else
        render 'new'
      end
    end

    def edit
      set_object
    end

    def update
      set_object
      if @object.update(update_params)
        redirect_to(admin_routes.index, :notice => "#{admin_model.to_s} updated!")
      else
        render 'edit'
      end
    end

    private

      def set_object
        if @object.respond_to?(:slug) && params[:slug]
          @object = admin_model.find_by_slug(params[:slug])
        else
          @object = admin_model.find_by_id(params[:id])
        end
        @obj = @object
      end

      def authenticate_admin!
        authenticate_user!
        not_found unless current_user.is_admin?
      end

      def create_params
        params
          .require(admin_model.to_s.humanize.downcase.to_sym)
          .permit(admin_model.fields.to_h.keys)
      end

      def update_params
        create_params
      end

  end
end
