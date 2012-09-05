require 'test_helper'


# Timestamp used in the first article of the fixtures database.
RECORD_ONE_TS = DateTime.new(2009, 11, 30, 12, 0, 0)

# Record describing the first article in the fixtures database.
RECORD_ONE = {
  :arxiv_id => '0911.5596',
  :title => 'Spin Systems and Computational Complexity',
  :abstract => 'I give a very brief non-technical introduction to ...',
  :comments => '3 pages, prepared for a special issue of Physics in Canada',
  :journal_ref => 'Physics in Canada, vol. 66, no. 2, pp. 87-79, 2010',
  :authors_attributes => [
      {:name => 'Daniel Gottesman', :institution => 'Perimeter Institute'}],
  :categories_attributes => [{:name => 'quant-ph'}],
  :primary_category => 'quant-ph',
  :versions_attributes => [
      {:name => 'v1', :size => '100kb', :timestamp => RECORD_ONE_TS}
  ],
  :published => RECORD_ONE_TS,
  :last_updated => RECORD_ONE_TS
}


class ArticleTest < ActiveSupport::TestCase

  def setup
    @article = Article.find_by_arxiv_id('0911.5596')
  end

  test "is_identical detects no differences" do
    assert @article.is_identical?(RECORD_ONE)
  end

  test "is_identical detects simple differences" do record = RECORD_ONE.clone
    record[:title] = 'new title'
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:abstract] = 'new abstract'
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:comments] = 'new comments'
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:report_no] = 'new report no'
    assert !@article.is_identical?(record)
  end

  test "is_identical detects authors differences" do
    record = RECORD_ONE.clone
    record[:authors_attributes] = []
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:authors_attributes] = [{:name => 'Sly Stallone'}]
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:authors_attributes] = [{:name => 'Daniel Gottesman'}]
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:authors_attributes] = [
        {:name => 'Daniel Gottesman', :institution => 'Perimeter Institute'}]
    assert @article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:authors_attributes] = [
        {:name => 'Daniel Gottesman', :institution => 'Perimeter Institute'},
        {:name => 'Sly Stallone'}]
    assert !@article.is_identical?(record)
  end

  test "is_identical detects categories differences" do
    record = RECORD_ONE.clone
    record[:categories_attributes] = []
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:categories_attributes] = [{:name => 'cond-mat'}]
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:categories_attributes] = [
        {:name => 'quant-ph'}, {:name => 'cond-mat'}]
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:categories_attributes] = [{:name => 'quant-ph'}]
    assert @article.is_identical?(record)
  end

  test "is_identical detects versions differences" do
    record = RECORD_ONE.clone
    record[:versions_attributes] = []
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:versions_attributes] = [
        { :name => 'v2', :size => '100kb', :timestamp => RECORD_ONE_TS }]
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:versions_attributes] = [
        { :name => 'v1', :size => '101kb', :timestamp => RECORD_ONE_TS }]
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:versions_attributes] = [
        { :name => 'v1', :size => '100kb', :timestamp => RECORD_ONE_TS },
        { :name => 'v2', :size => '110kb', :timestamp => RECORD_ONE_TS }]
    assert !@article.is_identical?(record)

    record = RECORD_ONE.clone
    record[:versions_attributes] = [
        { :name => 'v1', :size => '100kb', :timestamp => RECORD_ONE_TS }]
    assert @article.is_identical?(record)
  end
end
