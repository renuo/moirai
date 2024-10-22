# frozen_string_literal: true

module ApplicationHelper
  def moirai_edit_enabled?
    params[:moirai] == 'true'
  end
end
