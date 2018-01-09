class MoviesController < ApplicationController
   def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:release_date => :asc}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    
    if params[:ratings]
      @selected_ratings = params[:ratings].permit!
    elsif session[:ratings]
      @selected_ratings = session[:ratings]
    else
      @selected_ratings = {}  
    end

    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
     
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)
  end
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.html.haml by default
  end
  
  def new
    @movie = Movie.new
    # default: render 'new' template
  end
  
  def create
    params.require(:movie)
    permitted = params[:movie].permit(:title, :rating, :description, :release_date, :director)
    @movie = Movie.new(permitted)
    if @movie.save
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    else
      render 'new' # note, 'new' template can access @movie's field values!
    end
  end
  
  def search_similar_movies
    @movie = Movie.find(params[:id])
    if @movie.director.nil? || @movie.director.empty?
      flash[:warning]= "'#{@movie.title}' has no director info"
      redirect_to movies_path
    else
      @movies = Movie.similar_movies(@movie)
    end
  end

  def edit
    @movie = Movie.find params[:id]
  end
 
  def update
    @movie = Movie.find params[:id]
    params.require(:movie)
    permitted = params[:movie].permit(:title, :rating, :description, :release_date, :director)
    if @movie.update_attributes(permitted)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    else
      render 'edit' # note, 'edit' template can access @movie's field values!
    end
  end
  
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end