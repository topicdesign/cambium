module Cambium
  module CambiumHelper

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    def avatar(user, size = 100, klass = nil)
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      content_tag(:div, :class => "avatar-container #{klass}") do
        image_tag "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=mm",
          :class => 'avatar'
      end
    end

    def admin
      @admin ||= Cambium::AdminPresenter.new(self)
    end

    def admin_view
      @admin_view ||= admin.view(controller_name)
    end

    def admin_table
      @admin_table ||= admin_view.nil? ? nil : admin_view.table
    end

    def admin_form
      @admin_form ||= begin
        if action_name == 'new' || action_name == 'create'
          admin_view.form.new
        else
          admin_view.form.edit
        end
      end
    end

    def admin_routes
      @admin_routes ||= admin.routes(@object)
    end

    def admin_model
      @admin_model ||= admin_view.model.constantize
    end

    def cambium_page_title(title)
      content_tag(:div, :id => 'title-bar') do
        o  = content_tag(:h2, title, :class => 'page-title')
        if is_index? && has_new_form?
          o += link_to(
            admin_view.form.new.title,
            admin_routes.new,
            :class => 'button new'
          )
        end
        if is_index? && admin_view.export.present?
          o += link_to(
            admin_view.export.button || "Export #{admin_table.title}",
            "#{admin_routes.index}.csv",
            :class => 'button export'
          )
        end
        o.html_safe
      end
    end

    def cambium_table(collection, columns)
      obj_methods = []
      content_tag(:section, :class => 'data-table') do
        p = content_tag(:table) do
          o = content_tag(:thead) do
            content_tag(:tr) do
              o2 = ''
              columns.to_h.each do |col|
                obj_methods << col.first.to_s
                o2 += content_tag(:th, col.last.heading)
              end
              o2 += content_tag(:th, nil)
              o2.html_safe
            end
          end
          o += content_tag(:tbody) do
            o2 = ''
            collection.each do |obj|
              o2 += content_tag(:tr) do
                o3 = ''
                obj_methods.each do |method|
                  o3 += content_tag(:td, obj.send(method))
                end
                path = "edit_admin_#{controller_name.singularize}_path"
                begin
                  route = cambium.send(path, obj)
                rescue
                  route = main_app.send(path, obj)
                end
                o3 += content_tag(:td, link_to('', route), :class => 'actions')
                o3.html_safe
              end
            end
            o2.html_safe
          end
          o.html_safe
        end
        p += paginate(collection)
      end
    end

    def cambium_form(obj, fields)
      content_tag(:section, :class => 'form') do
        case action_name
        when 'edit', 'update'
          url = cambium_route(:show, obj)
        else
          url = cambium_route(:index, obj)
        end
        simple_form_for obj, :url => url do |f|
          cambium_form_fields(f, obj, fields)
        end
      end
    end

    def cambium_form_fields(f, obj, fields)
      o = ''
      fields.to_h.each do |data|
        attr = data.first.to_s
        options = data.last
        readonly = options.readonly.present? && options.readonly == true ?
          true : false
        if ['select','check_boxes','radio_buttons'].include?(options.type)
          o += f.input(
            attr.to_sym,
            :as => options.type,
            :collection => options.options,
            :readonly => readonly
          )
        elsif ['date','time'].include?(options.type)
          if obj.send(attr).present?
            val = (options.type == 'date') ?
              obj.send(attr).strftime("%d %B, %Y") :
              obj.send(attr).strftime("%l:%M %p")
          end
          o += f.input(
            attr.to_sym,
            :as => :string,
            :input_html => {
              :class => "picka#{options.type}",
              :value => val.nil? ? nil : val
            },
            :readonly => readonly
          )
        elsif options.type == 'datetime'
          o += content_tag(:div, :class => 'input string pickadatetime') do
            o2 = content_tag(:label, attr.to_s.humanize.titleize)
            o2 += content_tag(
              :input,
              '',
              :placeholder => 'Date',
              :type => 'text',
              :class => 'pickadatetime-date',
              :value => obj.send(attr).present? ?
                obj.send(attr).strftime("%d %B, %Y") : '',
              :readonly => readonly
            )
            o2 += content_tag(
              :input,
              '',
              :placeholder => 'Time',
              :type => 'text',
              :class => 'pickadatetime-time',
              :value => obj.send(attr).present? ?
                obj.send(attr).strftime("%l:%M %p") : '',
              :readonly => readonly
            )
            o2 += f.input(
              attr.to_sym,
              :as => :hidden,
              :wrapper => false,
              :label => false,
              :input_html => { :class => 'pickadatetime' }
            )
          end
        elsif options.type == 'markdown'
          o += content_tag(:div, :class => "input text optional #{attr}") do
            o2  = content_tag(:label, attr.titleize, :for => attr)
            o2 += content_tag(
              :div,
              f.markdown(attr.to_sym),
              :class => 'markdown'
            )
          end
        else
          o += f.input(
            attr.to_sym,
            :as => options.type,
            :readonly => readonly
          )
        end
      end
      o += f.submit
      o.html_safe
    end

    def cambium_route(action, obj = nil)
      case action
      when :index
        begin
          main_app
            .polymorphic_path [:admin, obj.class.to_s.downcase.pluralize.to_sym]
        rescue
          polymorphic_path [:admin, obj.class.to_s.downcase.pluralize.to_sym]
        end
      when :edit
        begin
          main_app.polymorphic_path [:edit, :admin, obj]
        rescue
          polymorphic_path [:edit, :admin, obj]
        end
      else
        begin
          main_app.polymorphic_path [:admin, obj]
        rescue
          polymorphic_path [:admin, obj]
        end
      end
    end

    def is_index?
      action_name == 'index'
    end

    def has_new_form?
      admin_view.form.present? && admin_view.form.new.present?
    end

  end
end