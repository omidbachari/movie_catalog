require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield (connection)

  ensure
    connection.close
  end
end

#==============================================================================

def find_actor_name(id)
  query = %Q{
    SELECT actors.id, actors.name FROM actors WHERE actors.id = $1
  }

  actor_names = db_connection do |conn|
    conn.exec_params(query, [id])
  end
  actor_names.to_a.first["name"]
end

def find_actor_movies(id)
  query = %Q{
    SELECT movies.title, cast_members.character FROM movies
    JOIN cast_members ON movies.id = cast_members.movie_id
    WHERE cast_members.actor_id = #{id}
  }

  actor_id = db_connection do |conn|
    conn.exec(query)
  end
  # TODO make this an array?
  actor_id
end

def find_actor_mov(id)
  actor_id = db_connection do |conn|
    conn.exec("SELECT movies.title, cast_members.character, cast_members.movie_id FROM movies
              JOIN cast_members ON movies.id = cast_members.movie_id
              WHERE cast_members.actor_id = #{id}")
  end
  # TODO make this an array?
  actor_id
end

# this method replaces find_actor_name & find_actor_movies
def get_actor_info(id)
  query = %Q{
    SELECT actors.id, actors.name, movies.title, movies.id AS movie_id, cast_members.character FROM actors
    JOIN cast_members ON cast_members.actor_id = actors.id
    JOIN movies ON movies.id = cast_members.movie_id
    WHERE actors.id = $1
  }

  actor_info = db_connection do |conn|
    conn.exec_params(query, [id])
  end

  actor_info.to_a
end


def get_movie_titles(actor_info)
  titles = []

  actor_info.each do |movie|
    titles << movie["title"]
  end
  titles
end
#==============================================================================

def find_movie_data
movie_data = db_connection do |conn|
    conn.exec("SELECT movies.title AS title, movies.year AS year, movies.rating AS rating, genres.name AS genre, studios.name AS studio FROM movies
              JOIN genres ON movies.genre_id = genres.id
              JOIN studios ON movies.studio_id = studios.id")
  end
movie_data
end

def find_movie_det
  movie_det =
    db_connection do |conn|
      conn.exec("SELECT movies.title AS title, movies.year AS year, movies.rating AS rating, genres.name AS genre, studios.name AS studio, movies.id AS id FROM movies
                  JOIN genres ON movies.genre_id = genres.id
                  JOIN studios ON movies.studio_id = studios.id")
    end
    movie_det.to_a
end

def find_movie_details(id)
  movie_details =
    db_connection do |conn|
      conn.exec("SELECT movies.title AS title, genres.name AS genre, actors.id AS id,
                studios.name AS studio, actors.name AS actor,
                cast_members.character AS character FROM movies
                JOIN genres ON movies.genre_id = genres.id
                JOIN studios ON movies.studio_id = studios.id
                JOIN cast_members ON movies.id = cast_members.movie_id
                JOIN actors ON actors.id = cast_members.actor_id
                WHERE movies.id = #{id}")
    end
    movie_details.to_a
end


#==============================================================================

get '/' do
  @page_title = "WELCOME TO THE  FD H  LAUNCH ACADEMYY MOVIE LIST!1!11!ONE!"
  erb :index
end

get '/actors' do
  @title = "Launch Academy Movies"
  @page_title = "All Actors"
  @actors = db_connection do |conn|
              conn.exec('SELECT actors.name, actors.id FROM actors ORDER BY actors.name')
            end
  erb :'actors/actors'
end

get '/actors/:id' do
  actor_info = get_actor_info(params[:id])

  @page_title = actor_info[0]["name"]
  @title = @page_title

  @actor_movies = get_actor_info(params[:id])

  # @actor_movies = get_movie_titles(actor_info)

  erb :'actors/show.html'
end

get '/movies' do
  @title = "Movies"
  @page_title = "Movies"
  @movie_data = find_movie_det
  erb :'movies/index.html'
end

get '/movies/:id' do
  @movie_details = find_movie_details(params[:id])
  @page_title = @movie_details.first["title"]
  @title = @page_title
  erb :'movies/show.html'
end

