require 'json'

module Helpers
  # From https://gist.github.com/ascendbruce/7070951
  def valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue Exception => e
      return false
    end
  end

  def trim(text)
    %r/\A\s+#{text}\s+\Z/
  end
end
