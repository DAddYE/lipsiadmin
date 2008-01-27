module LipsiaSoft
  module BetterErrors
    def show_errors
      return "- " + self.errors.full_messages.join("<br />- ")
    end
  end
end