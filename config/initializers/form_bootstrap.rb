# # skip 'form-control' options to each forms.
# # https://stackoverflow.com/posts/20131250/revisions

# require 'action_view/helpers/tags/base'
# # Most input types need the form-control class on them.  This is the easiest way to get that into every form input
# module BootstrapTag
#   FORM_CONTROL_CLASS = 'form-control'
#   def tag(name, options, *)
#     options = add_bootstrap_class_to_options options, true if name.to_s == 'input'
#     super
#   end

#   private

#   def content_tag_string(name, content, options, *)
#     options = add_bootstrap_class_to_options options if name.to_s.in? %w(select textarea)
#     super
#   end

#   def add_bootstrap_class_to_options(options, check_type = false)
#     options = {} if options.nil?
#     options.stringify_keys!
#     if !check_type || options['type'].to_s.in?(%w(text password number email tel search))
#       options['class'] = [] unless options.has_key? 'class'
#       options['class'] << FORM_CONTROL_CLASS if options['class'].is_a?(Array) && !options['class'].include?(FORM_CONTROL_CLASS)
#       options['class'] << " #{FORM_CONTROL_CLASS}" if options['class'].is_a?(String) && options['class'] !~ /\b#{FORM_CONTROL_CLASS}\b/
#     end
#     options
#   end
# end

# ActionView::Helpers::Tags::Base.send :include, BootstrapTag
# ActionView::Base.send :include, BootstrapTag