#---
# Excerpted from "Enterprise Recipes for Ruby and Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/msenr for more book information.
#---
module Spec
  module Story
    class Step
      PARAM_PATTERN = /(\$\w*)/
      PARAM_OR_GROUP_PATTERN = /(\$\w*)|\(.*?\)/
      
      attr_reader :name
      def initialize(name, &block)
        @name = name
        assign_expression(name)
        init_module(name, &block)
      end

      def perform(instance, *args)
        instance.extend(@mod)
        instance.__send__(sanitize(@name), *args)
      end

      def init_module(name, &block)
        sanitized_name = sanitize(name)
        @mod = Module.new do
          define_method(sanitized_name, &block)
        end
      end
      
      def sanitize(a_string_or_regexp)
        return a_string_or_regexp.source if Regexp == a_string_or_regexp
        a_string_or_regexp.to_s
      end
      

      def matches?(name)
        !(matches = name.match(@expression)).nil?
      end
            
      def parse_args(name)
        name.match(@expression)[1..-1]
      end

      private
      
        def assign_expression(string_or_regexp)
          if String === string_or_regexp
            expression = string_or_regexp.dup
            expression.gsub! '(', '\('
            expression.gsub! ')', '\)'
          elsif Regexp === string_or_regexp
            expression = string_or_regexp.source
          end
          while expression =~ PARAM_PATTERN
            expression.gsub!($1, "(.*?)")
          end
          @expression = Regexp.new("^#{expression}$")
        end

    end
  end
end