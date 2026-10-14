# Light, dark or follow the system. A per-viewer preference, so it lives in
# a cookie rather than on the account: a fan who never signs in can still
# pick, and a creator's choice for Studio does not change what fans see.
class ThemesController < ApplicationController
  THEMES = %w[dark light system].freeze

  def update
    theme = params[:theme].presence_in(THEMES) || "dark"
    cookies.permanent[:wf_theme] = { value: theme, same_site: :lax }
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.json { head :no_content }
    end
  end
end
