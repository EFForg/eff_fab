class VisitorsController < ApplicationController
  # GET /v
  def version
    render text: "0.0.1"
  end

end
