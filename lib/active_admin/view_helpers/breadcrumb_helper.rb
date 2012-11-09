module ActiveAdmin
  module ViewHelpers
    module BreadcrumbHelper

      # Returns an array of links to use in a breadcrumb
      def breadcrumb_links(path = nil)
        path ||= request.fullpath
        parts = path.gsub(/^\//, '').split('/')
        parts.pop unless %w{ create update}.include?(params[:action]) || %w{edit}.include?(parts.last)
        crumbs = []
        parts.each_with_index do |part, index|
          name = nil
          if part =~ /^\d|^[a-f0-9]{24}$/ && (parent = parts[index - 1])
            begin
              parent_class = parent.singularize.camelcase.constantize
              obj = parent_class.find(part[/^[a-f0-9]{24}$/] ? part : part.to_i)
              name = display_name(obj)
            rescue
              # ignored
            end
          end
          
          name ||= I18n.t("activerecord.models.#{part.singularize}", :count => 1.1, :default => part.titlecase)

          url =  "/" + parts[0..index].join('/')
          
          found = false
          Rails.application.routes.routes.named_routes.values.each do |r|
            if r.path.spec
              route_path = r.path.spec.to_s
              route_path.sub!("(.:format)","")
              route_path.sub!(":id", params[:id]) if params[:id].present?
              found = route_path == url && r.verb==/^GET$/
              break if found
            end
          end
          
          crumbs << ( found ? link_to(name, url) : name )
        end
        crumbs
      end

    end
  end
end
