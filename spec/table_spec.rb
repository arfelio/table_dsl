require 'spec_helper'
require_relative '../lib/table'

RSpec.describe Table do
  context 'with given parametres' do
    let(:expected_table) do
      "<table class='default' style='width:100px; height:200px; border:solid border-collapse: collapse;'>" \
        "<thead>" \
          "<tr>" \
            "<th class=''>Header</th>" \
          "</tr>" \
        "</thead>" \
        "<tbody>" \
          "<tr>" \
            "<td class='' style='padding: px'>1</td>" \
            "<td class='' style='padding: px'>2</td>" \
          "</tr>" \
          "<tr>" \
            "<td class='' style='padding: px'>3</td>" \
            "<td class='' style='padding: px'>4</td>" \
          "</tr>" \
          "<tr>" \
            "<td class='' style='padding: px'>5</td>" \
            "<td class='' style='padding: px'>6</td>" \
          "</tr>" \
          "<tr>" \
            "<td class='' style='padding: px'>7</td>" \
          "</tr>" \
        "</tbody>" \
      "</table>"
    end

    it 'returns table with values' do
      html = Table.build_table do
        rows_number 2
        columns_number 2
        data ["1","2","3","4","5","6","7"]
        width 100
        height 200
        border "solid"
        headers ["Header"]
        table_class "default"
      end
      expect(html).to eq(expected_table)
    end
  end

  context 'when parametres absent' do
    let(:expected_table) do
      "<table class='' style='width:px; height:px; border: border-collapse: collapse;'>" \
        "<thead>" \
          "<tr>" \
            "<th class=''></th>" \
          "</tr>" \
        "</thead>" \
        "<tbody>" \
          "<tr>" \
            "<td class='' style='padding: px'></td>" \
          "</tr>" \
        "</tbody>" \
      "</table>"
    end

    it 'returns empty table' do
      html = Table.build_table
      expect(html).to eq(expected_table)
    end
  end
end
