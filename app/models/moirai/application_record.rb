# frozen_string_literal: true

module Moirai
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
