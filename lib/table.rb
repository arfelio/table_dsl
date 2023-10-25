require 'tableable'

class Table
  include Tableable.with(
    :rows_number,
    :columns_number,
    :width,
    :height,
    :border,
    :cellpadding,
    :headers,
    :data,
    :table_class,
    :header_class,
    :data_cell_class)
end
