class InformationsController < ApplicationController
  def index
  end

  def search
    date_start = nil
    date_end = nil

    date_start = Date.parse(params["date_start"]) if params["date_start"].present?
    date_end = Date.parse(params["date_end"]) if params["date_end"].present?

    @records = ParamVal.search(params[:parameter].to_i, params[:subject].to_i, date_start, date_end)
  end
end