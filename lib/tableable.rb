module Tableable
  def self.with(*attrs)
    not_provided = Object.new

    table_settings_class = Class.new do
      attrs.each do |attr|
        define_method attr do |value = not_provided|
          if value === not_provided
            instance_variable_get("@#{attr}")
          else
            instance_variable_set("@#{attr}", value)
          end
        end
      end

      attr_writer *attrs
    end

    class_methods = Module.new do
      define_method :table_settings do
        @table_settings ||= table_settings_class.new
      end

      def build_table(&block)
        table_settings.instance_eval(&block) if block_given?
        Tableable::Builder.build(table_settings).tap do
          table_settings.instance_variables.each{ |v| table_settings.instance_variable_set(v, nil) }
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
    def self.build(table_settings)
      new(table_settings).build_table
    end

    def initialize(table_settings)
      @table_settings = table_settings
      @columns_number = table_settings.columns_number || 1
      @rows_number = table_settings.rows_number || 1
    end

    def build_table
      "<table class='#{table_settings.table_class}' #{table_style}>#{thead}#{tbody}</table>"
    end

    private

    attr_reader :table_settings, :columns_number, :rows_number

    def thead
      "<thead><tr>#{th("header")}</tr></thead>"
    end

    def th(header)
      return "<th class='#{table_settings.header_class}'></th>" unless table_settings.headers

      table_settings.headers.inject(''){ |memo, value| memo << "<th class='#{table_settings.header_class}'>#{value}</th>" }
    end

    def tbody
      "<tbody>#{tr}</tbody>"
    end

    def tr
      collection = table_settings.data ? table_settings.data : Array.new(columns_number * rows_number)
      collection.each_slice(columns_number).to_a.inject('') do |memo, rows|
        memo << "<tr>#{td(rows)}</tr>"
      end
    end

    def td(rows)
      rows.inject(''){ |memo, value| memo << "<td class='#{table_settings.data_cell_class}' style='padding: #{table_settings.cellpadding}px'>#{value}</td>" }
    end

    def table_style
      "style='width:#{table_settings.width}px; height:#{table_settings.height}px; border:#{table_settings.border} border-collapse: collapse;'"
    end
  end
end
