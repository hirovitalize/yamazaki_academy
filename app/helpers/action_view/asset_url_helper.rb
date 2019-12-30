# frozen_string_literal: true

module ActionView
  module AssetUrlHelper
    def controller_js_exists?
      js_path
    end

    def action_js_exists?
      js_path action_name
    end

    def controller_css_exists?
      css_path
    end

    def action_css_exists?
      css_path action_name
    end

    def css_path(action = 'controller')
      path = target_path(action, 'stylesheets')
      return nil unless file_path_exists?(path, ['.css', '.css.scss', '.scss'])

      "app/#{namespace_path}#{controller_name}/#{action}"
    end

    def js_path(action = 'controller')
      path = target_path(action, 'javascripts')
      return nil unless file_path_exists?(path, ['.js'])

      "app/#{namespace_path}#{controller_name}/#{action}"
    end

    def target_path(action, type)
      "#{Rails.root}/app/assets/#{type}/app/#{namespace_path}#{controller_name}/#{action}"
    end

    def file_path_exists?(path, filetypes)
      filetypes.select { |ext| File.exist?("#{path}#{ext}") }.present?
    end

    def namespace_path
      path = controller.controller_path.split('/')[-2]
      path.present? ? "#{path}/" : ''
    end
  end
end
