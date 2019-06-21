# frozen_string_literal: true

module Pgen
  module Generators
    # Generate a PHP class
    class ClassGenerator
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def output
        class_wrapper(data["name"]) do
          construct(data["construct"]) unless data["construct"].nil?
        end
      end

      def class_wrapper(name)
        "class #{name} {\n#{yield}\n}"
      end

      def construct(params)
        arg_string = params["args"].map { |a| "#{a['type']} $#{a['name']}" }.join(", ")
        "\tpublic function __construct(#{arg_string}) {\n\t}"
      end
    end
  end
end
