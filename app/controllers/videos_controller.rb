class VideosController < InheritedResources::Base

  respond_to :json

  layout false, except: :index

  skip_before_action :verify_authenticity_token, only: :autocomplete
  skip_before_action :authenticate_admin!, only: :autocomplete

  def create
    create! do |success, failure|
      success.html { redirect_to videos_url }
      failure.html { render json: @video.errors.as_json }
    end
  end


  def update
    update! { videos_url }
  end


  def autocomplete
    term = params[:term].upcase
    query = Video.where('UPPER(videos.metadata) LIKE ?', "%#{term}%").or(
        Video.where('UPPER(videos.path) LIKE ?', "%#{term}%")
    )

    if params[:video_type]
      query = query.where(video_type: params[:video_type])
    end

    if query.any?
      result = query.all.map { |video| {id: video.id, label: video.title}  }
      render json: result
    else
      render status: :not_found, json: []
    end

  end

  protected

  def collection
    type = params[:type].blank? ? nil : params[:type].pluralize(locale: :en).to_sym

    if [:adverts, :teasers, :films, :intros].include?(type)
      Video.send(type)
    else
      Video.default_scoped
    end
  end

  private

  def video_params
    # Remap enum keys to integer

    if params[:video]
      params[:video][:pegi_rating] = params[:video][:pegi_rating].to_i
      params[:video][:video_type] = params[:video][:video_type].to_i
    end

    logger.debug 'Params incoming: ' + params.to_json

    params.require(:video).permit(:path, :video_type, :title, :pegi_rating)
  end
end

