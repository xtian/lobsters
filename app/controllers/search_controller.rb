# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @title = 'Search'
    @cur_url = '/search'

    @search = Search.new

    if params[:q].to_s.present?
      @search.q = params[:q].to_s

      @search.what = params[:what] if params[:what].present?
      @search.order = params[:order] if params[:order].present?
      @search.page = params[:page].to_i if params[:page].present?

      @search.search_for_user!(@user) if @search.valid?
    end

    render :action => 'index'
  end
end
