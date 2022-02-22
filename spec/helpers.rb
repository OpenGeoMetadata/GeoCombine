# frozen_string_literal: true

require 'json'

module Helpers
  # From https://gist.github.com/ascendbruce/7070951
  def valid_json?(json)
    JSON.parse(json)
    true
  rescue Exception => e
    false
  end

  def trim(text)
    /\A\s+#{text}\s+\Z/
  end
end
