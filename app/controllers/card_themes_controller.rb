class CardThemesController < InheritedResources::Base
  before_filter :authenticate
  before_filter :find_venue
  before_filter :find_card_theme, except: [:index, :new, :create]

  def index
    authorize! :read, CardTheme

    @card_themes = @venue.card_themes.order('name ASC')
  end

  def show
    authorize! :read, @card_theme
  end

  def new
    authorize! :create, CardTheme
    @card_theme = @venue.card_themes.build
  end

  def create
    @card_theme = @venue.card_themes.build params_for_card_theme
    authorize! :create, @card_theme

    if @card_theme.save
      redirect_to venue_card_themes_path, notice: 'Theme successfully added.'
    else
      render :new
    end
  end

  def edit
    authorize! :update, @card_theme

  end

  def update
    authorize! :update, @card_theme

    if @card_theme.update_attributes params_for_card_theme
      redirect_to venue_card_themes_path, notice: 'Theme updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @card_theme

    if @card_theme.card_levels.count
      respond_to do |format|
        format.json { render :json => { :error => "unable to delete while still assigned to card_levels, please remove/reassign and retry" }, :status => 422 }
        format.html do
          redirect_to venue_card_levels_path, notice: "unable to delete.  Please assign all Card Levels from Theme \"" + @card_theme.name + "\""
        end
      end and return
    else 
      @card_theme.destroy
    end

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to venue_card_themes_path, notice: 'Theme deleted.' }
    end
  end

  private

  def find_card_theme
    @card_theme = CardTheme.find params[:id]
  end

  def find_venue
    @venue = current_user.venue
  end

  def params_for_card_theme
    params.require(:card_theme).permit(:name, :portrait_background, :portrait_background_cache, :landscape_background, :landscape_background_cache)
  end
end
