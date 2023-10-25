module Tableable
  def self.with(*attrs)
    not_provided = Object.new

    config_class = Class.new do
      attrs.each do |attr|
        define_method attr do |value = not_provided, &block|
          if value === not_provided && block.nil?
            result = instance_variable_get("@#{attr}")
            result.is_a?(Proc) ? instance_eval(&result) : result
          else
            instance_variable_set("@#{attr}", block || value)
          end
        end
      end

      attr_writer *attrs
    end

    class_methods = Module.new do
      define_method :config do
        @config ||= config_class.new
      end

      def build_table(&block)
        config.instance_eval(&block) if block_given?
        Tableable::Builder.build(config).tap do
          config.instance_variables.each{ |v| config.instance_variable_set(v, nil) }
        end
      end
    end

    Module.new do
      singleton_class.send :define_method, :included do |host_class|
        host_class.extend class_methods
      end
    end
  end

  class Builder
    def self.build(config)
      new(config).build_table
    end

    def initialize(config)
      @config = config
      @columns_number = config.columns_number || 1
      @rows_number = config.rows_number || 1
    end

    def build_table
      "<table class='#{config.table_class}' #{table_style}>#{thead}#{tbody}</table>"
    end

    private

    attr_reader :config, :columns_number, :rows_number

    def thead
      "<thead><tr>#{th("header")}</tr></thead>"
    end

    def th(header)
      return "<th class='#{config.header_class}'></th>" unless config.headers

      config.headers.inject(''){ |memo, value| memo << "<th class='#{config.header_class}'>#{value}</th>" }
    end

    def tbody
      "<tbody>#{tr}</tbody>"
    end

    def tr
      collection = config.data ? config.data : Array.new(columns_number * rows_number)
      collection.each_slice(columns_number).to_a.inject('') do |memo, rows|
        memo << "<tr>#{td(rows)}</tr>"
      end
    end

    def td(rows)
      rows.inject(''){ |memo, value| memo << "<td class='#{config.data_cell_class}' style='padding: #{config.cellpadding}px'>#{value}</td>" }
    end

    def table_style
      "style='width:#{config.width}px; height:#{config.height}px; border:#{config.border} border-collapse: collapse;'"
    end
  end
end
