class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    @all_ratings = Movie.ratings
  end

  def index
    @all_ratings = Movie.all_ratings
    sort = params[:sort]
    hash = Hash.new
    use_ratings_session = !params[:ratings].present? && session[:ratings].present? 
    use_sort_session = !params[:sort].present? && session[:sort].present?
    
    if use_ratings_session || use_sort_session
      if use_ratings_session && use_sort_session
        hash = {:ratings=>session[:ratings], :sort=>session[:sort]}
      elsif use_ratings_session
        hash = {:ratings=>session[:ratings]}
      else 
        hash = {:sort=>session[:sort]}
      end
      flash.keep
      redirect_to movies_path(params.merge(hash))
    end
    
      
    if params[:ratings].present?
      @selected_ratings =  params[:ratings].keys
      @movies = Movie.where(rating: params[:ratings].keys)
    else
      @selected_ratings = @all_ratings
      @movies = Movie.all
    end

    
    if sort == "title"
      @movies = @movies.order(:title)
      @css_title = "hilite"
    elsif sort == "release_date"
      @movies = @movies.order(:release_date)
      @css_release_date = "hilite"
    end
    
    session[:ratings] = params[:ratings]
    session[:sort] = params[:sort]
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
    

end
