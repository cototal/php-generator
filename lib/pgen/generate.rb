# frozen_string_literal: true

require "yaml"
require "fileutils"
require_relative "generators/class_generator"

module Pgen
  # Master class for generating PHP project
  class Generate
    attr_reader :yaml_dir, :files, :warnings, :data, :out_dir

    def initialize(yaml_dir, out_dir)
      @warnings = []
      @data = {}
      @yaml_dir = yaml_dir
      @out_dir = out_dir
      validate_yaml_dir
      @files = glob_files
    end

    def collect
      files.each do |file|
        unless File.readable?(file)
          @warnings << "File is not readable: #{file}"
          next
        end

        data[file] = YAML.load_file(file)
      end
    end

    def output
      collect
      result = {}
      data.each do |file, content|
        case content["type"]
        when "class"
          gen = Generators::ClassGenerator.new(content)
          result[file] = gen.output
        else
          @warnings << "#{file}: #{content['type']} is not a valid type."
        end
      end
      result
    end

    def run
      result = output
      result.each do |file, content|
        next unless file.end_with?("yaml")

        file_name = new_file(file)
        File.open(file_name, "w+") { |f| f.write(content) }
      end
    end

    def new_file(file)
      file_parts = file.split("/")
      local_name = file_parts[-1]
      dir_name = File.join(out_dir, file_parts[0..-2])
      FileUtils.mkdir_p(dir_name) unless File.exist?(dir_name)
      File.join(dir_name, local_name.gsub(/yaml$/, "php"))
    end

    private

      def glob_files
        Dir.glob(File.join(yaml_dir, "**", "*"))
      end

      def validate_yaml_dir
        raise Pgen::Error, "Directory (#{yaml_dir}) does not exist." unless File.exist?(yaml_dir)
        raise Pgen::Error, "#{yaml_dir} is not a directory" unless File.directory?(yaml_dir)
        raise Pgen::Error, "#{yaml_dir} is not readable" unless File.readable?(yaml_dir)
        raise Pgen::Error, "#{yaml_dir} is empty" if glob_files.empty?
      end
  end
end
