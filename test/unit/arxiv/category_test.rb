require 'test_helper'
require 'scirate/arxiv/category'


class ArxivCategoriesTest < ActiveSupport::TestCase

  test "subarea names exists" do
    Arxiv::AREA.each do |k,v|
      v[:subs].each do |n|
        assert Arxiv::SUBAREA.include? n
      end
    end
  end

  test "category names exist" do
    Arxiv::SUBAREA.each do |k,v|
      v[:cats].each do |n|
        assert Arxiv::CATEGORY.include? n
      end
    end
  end
end
