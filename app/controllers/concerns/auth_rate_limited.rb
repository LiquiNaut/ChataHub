# Renders the form again with HTTP 429
module AuthRateLimited
  MESSAGE = "Príliš veľa pokusov. Skús to znova o pár minút.".freeze

  private

  def render_rate_limited
    self.resource = resource_class.new
    flash.now[:alert] = MESSAGE
    render :new, status: :too_many_requests
  end
end
