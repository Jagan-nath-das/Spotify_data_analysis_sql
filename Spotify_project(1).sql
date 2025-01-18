CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed varchar(20),
    official_video varchar(20),
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
select * from spotify;


-- -----------------------
-- Easy level questions --
-- -----------------------
-- 1.Retrieve the names of all tracks that have more than 1 billion streams.
select * from spotify
where stream > 1000000000;

-- 2.List all albums along with their respective artists.
select distinct album, artist
from spotify;

-- 3.Get the total number of comments for tracks where licensed = TRUE.
select sum(COMMENTS) as total_comments from spotify
where licensed = 'TRUE';

-- 4.Find all tracks that belong to the album type single.
select * FROM spotify
where album_type ilike 'single';

-- 5.Count the total number of tracks by each artist.
select distinct artist, count(*) from spotify
group by 1
order by 2 desc;

-- 6.Calculate the average danceability of tracks in each album.
select album, avg(danceability) from spotify
group by 1 
order by 2 desc;


-- 7.Find the top 5 tracks with the highest energy values.
select track, max(energy) from spotify
group by 1
order by 2 desc
limit 5;


-- 8.List all tracks along with their views and likes where official_video = TRUE.
select 
	track, sum(views), sum(likes) 
from spotify
	where official_video = 'TRUE'
	group by 1
	order by 2 desc;

-- 9.For each album, calculate the total views of all associated tracks.
select 
	album, track, sum(views)
from spotify
	group by 1,2
	order by 3 desc;
	

-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from	
	(select 
		track,
		-- most_played_on, 
		COALESCE(sum(case when most_played_on = 'Spotify' then stream end),0) as Spotify_stream, -- coalesce function is used to return 0 to null values
		coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as youtube_stream 
	from spotify
		group by 1
	) as s1
	where spotify_stream > youtube_stream
	and youtube_stream <> 0
	order by spotify_stream desc;


-- 11.Find the top 3 most-viewed tracks for each artist using window functions.
 with ranking_artist
 as
	 (select 
	 	artist,
		track,
		sum(views) as total_views,
		dense_rank()over(partition by artist order by sum(views) desc) as rank
	 from spotify
	 	group by 1,2
		order by 1,3 desc
	) 
select * from ranking_artist
where rank <=3;


-- 12.Write a query to find tracks where the liveness score is above the average.
select 
	track,
	liveness,
	(select avg(liveness) from spotify) as avg
from spotify
	where liveness >= (select avg(liveness) from spotify)
	group by 1,2
	order by 3 desc;



-- 13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with cte as
	(
	select 
		album,
		max(energy) as highest_energy,
		min(energy) as lowest_energy
	from spotify
	 group by 1
	)	
select
	album,
	highest_energy - lowest_energy as energy_dif
from cte;


-- 14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
with cte as
	(
	select 
		track,
		energy / nullif(liveness,0) as ratio
	from spotify
	)
select * from
cte where ratio > 1.2;

-- 15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select 
	track,
	likes as total_likes,
	sum(likes) over (order by views desc) as cumulative_sum
from spotify
	-- group by 1,2
	order by views desc;


-- Query Optimization
explain analyze --pt: 1.3 ms, et: 13.1 ms (before indexing)
			    --pt: 1.3 ms, et: 0.19 ms (after indexing)
select 
	artist,
	track,
	views
from spotify
where artist = 'Gorillaz'
	and 
	most_played_on = 'Youtube'
	order by stream desc limit 25;

 create index artist_index on spotify(artist);
