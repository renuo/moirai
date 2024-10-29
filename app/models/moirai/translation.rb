# frozen_string_literal: true

module Moirai
  class Translation < Moirai::ApplicationRecord
    validates_presence_of :key, :locale
  end
end
