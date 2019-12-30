# monkey patch for simple_form: html5 pattern

module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups.
    module Pattern
      def pattern(wrapper_options = nil)
        input_html_options[:pattern] ||= normalize(pattern_source)
        nil
      end

      private

      def normalize(pattern)
        return if pattern.nil?
        pattern.to_s.gsub(/^\\A/, '^').gsub(/\\z$/, '$')
      end
    end
  end
end
