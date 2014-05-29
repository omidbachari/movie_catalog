-- Actors sorted alphabetically
SELECT actors.name FROM actors ORDER BY actors.name;

-- Visiting /actors/:id will show the details for a given actor.
-- This page should contain a list of movies that the actor has starred
-- in and what their role was. Each movie should link to the details
-- page for that movie.
SELECT movies.title, cast_members.character FROM movies
  JOIN cast_members ON movies.id = cast_members.movie_id
  WHERE cast_members.actor_id = 60;

-- Visiting /movies will show a table of movies, sorted alphabetically by title.
-- The table includes the movie title, the year it was released, the rating,
-- the genre, and the studio that produced it. Each movie title is a
-- link to the details page for that movie.
SELECT movies.title AS title, movies.year AS year, movies.rating AS rating, genres.name AS genre, studios.name AS studio FROM movies
  JOIN genres ON movies.genre_id = genres.id
  JOIN studios ON movies.studio_id = studios.id;

-- Visiting /movies/:id will show the details for the movie.
-- This page should contain information about the movie
-- (including genre and studio) as well as a list
-- of all of the actors and their roles. Each actor name
-- is a link to the details page for that actor.
SELECT genres.name, studios.name, actors.name, cast_members.character FROM movies
  JOIN genres ON movies.genre_id = genres.id
  JOIN studios ON movies.studio_id = studios.id
  JOIN cast_members ON movies.id = cast_members.movie_id
  JOIN actors ON actors.id = cast_members.actor_id
  WHERE movies.id = 'POTATO';
