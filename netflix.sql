SELECT * 
FROM netflix;


--1.Genre Distribution (%)--
SELECT genre,
       COUNT(*) AS total_content,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),1) AS percentage
FROM netflix
GROUP BY genre;


--2.Recent Content Trends: Last 10 Years--
SELECT release_year, COUNT(*) AS count 
FROM netflix
GROUP BY release_year 
ORDER BY release_year desc
limit 10;


--3.Top 10 Years: International_TV_Show--
SELECT release_year, COUNT(*) International_TV_Show
FROM netflix 
WHERE listed_in like '%International%'
GROUP BY release_year 
ORDER BY COUNT(*) desc
LIMIT 10;


--4.Content Distribution by Maturity Rating--
SELECT rating, COUNT(*) AS rating_count 
FROM netflix 
GROUP BY rating 
ORDER BY rating_count DESC;


--5.Top 10 Longest Movies (Duration Analysis)--
SELECT title, genre, duration_1 
FROM netflix
WHERE genre = 'Movie' 
ORDER BY duration_1 DESC 
LIMIT 10;


--6.Top 10 Longest TV Show (Duration Analysis)--
SELECT title, genre, duration_1 season
FROM netflix
WHERE genre = 'TV Show' 
ORDER BY duration_1 DESC 
LIMIT 10;


--7.Top 10 Content-Producing Countries--
WITH RECURSIVE clean_split AS (
  SELECT 
    TRIM(SUBSTR(country || ',', 1, INSTR(country || ',', ',') - 1)) AS single_country,
    SUBSTR(country || ',', INSTR(country || ',', ',') + 1) AS rest
  FROM netflix 
  WHERE country IS NOT NULL 
    AND country <> '' 
    AND LOWER(country) <> 'unknown'

  UNION ALL

  SELECT 
    TRIM(SUBSTR(rest, 1, INSTR(rest, ',') - 1)),
    SUBSTR(rest, INSTR(rest, ',') + 1)
  FROM clean_split
  WHERE rest <> ''
)
SELECT 
    single_country AS country,
    COUNT(*) AS total_content
FROM clean_split
WHERE country <> '' 
  AND country IS NOT NULL 
  AND LOWER(country) <> 'unknown'
GROUP BY country
ORDER BY total_content DESC
LIMIT 10;


--8.Top 10 Genres by Director Representation--
WITH RECURSIVE genre_split(show_id, director, genre_name, rest) AS (
    SELECT
        show_id,
        director,
        TRIM(
            CASE 
                WHEN instr(listed_in, ',') > 0 
                THEN substr(listed_in, 1, instr(listed_in, ',') - 1)
                ELSE listed_in
            END
        ) AS genre_name,
        CASE 
            WHEN instr(listed_in, ',') > 0 
            THEN substr(listed_in, instr(listed_in, ',') + 1)
            ELSE NULL
        END AS rest
    FROM netflix
    WHERE not director = 'unknown'

    UNION ALL

    SELECT
        show_id,
        director,
        TRIM(
            CASE 
                WHEN instr(rest, ',') > 0 
                THEN substr(rest, 1, instr(rest, ',') - 1)
                ELSE rest
            END
        ),
        CASE 
            WHEN instr(rest, ',') > 0 
            THEN substr(rest, instr(rest, ',') + 1)
            ELSE NULL
        END
    FROM genre_split
    WHERE rest IS NOT NULL
)
SELECT
    genre_name,
    COUNT(DISTINCT director) AS director_count
FROM genre_split
WHERE genre_name <> ''
GROUP BY genre_name
ORDER BY director_count DESC
limit 10;


--9.Top 10 Most Produced Categories--
WITH RECURSIVE genre_counts AS (
    SELECT
        TRIM(SUBSTR(listed_in || ',', 1, INSTR(listed_in || ',', ',') - 1)) AS single_genre,
        SUBSTR(listed_in || ',', INSTR(listed_in || ',', ',') + 1) AS rest
    FROM netflix
    WHERE listed_in IS NOT NULL AND listed_in <> ''

    UNION ALL

    SELECT
        TRIM(SUBSTR(rest, 1, INSTR(rest, ',') - 1)),
        SUBSTR(rest, INSTR(rest, ',') + 1)
    FROM genre_counts
    WHERE rest <> ''
)
SELECT
    single_genre AS genre,
    COUNT(*) AS total_content
FROM genre_counts
WHERE genre <> ''
GROUP BY genre
ORDER BY total_content DESC
LIMIT 15;

