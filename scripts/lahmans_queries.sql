-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT MAX(year) - MIN (year) AS range
FROM homegames

-- 145 years

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

-- Find the shortest player

SELECT playerid, namefirst, namelast, namegiven, height
FROM people
WHERE height IS NOT NULL
ORDER BY height ASC
LIMIT 1;

-- Games played in and team name (team ID)

SELECT teamid, g_all
FROM appearances
WHERE playerid = 'gaedeed01'

-- team name

SELECT DISTINCT name, teamid
FROM teams
WHERE teamid = 'SLA'

----- combined

SELECT p.playerid, p.namefirst, p.namelast, p.namegiven, p.height, a.teamid, a.g_all, t.name
FROM people AS p
JOIN appearances AS a
USING (playerid)
JOIN teams as t
USING (teamid)
WHERE height IS NOT NULL
ORDER BY height ASC
LIMIT 1;

-- Eddie Gaedel, Edward Carl, 43", 1 game, SLA or St. Louis Browns

-- 3. Find all players in the database who played at Vanderbilt University. 
-- Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	
-- school info

SELECT *
FROM schools
WHERE schoolid LIKE '%vand%'

-- bridging data table (schools --> collegeplaying --> people --> salaries)

SELECT DISTINCT playerID, schoolid
FROM collegeplaying
WHERE schoolid LIKE '%vand%'

-- (24 players)

-- salary

SELECT *
FROM salaries

---- combining the queries

SELECT p.playerid, p.namefirst, p.namelast, p.namegiven, SUM(salary* 1::money) AS total_salary
FROM people AS p
JOIN salaries AS sa
USING (playerid)
JOIN collegeplaying AS c
USING (playerid)
JOIN schools AS sc
ON sc.schoolid = c.schoolid
WHERE sc.schoolid LIKE '%vand%'
GROUP by playerid
ORDER by total_salary DESC;

-- highest salary

SELECT p.playerid, p.namefirst, p.namelast, p.namegiven, SUM(salary* 1::money) AS total_salary
FROM people AS p
JOIN salaries AS sa
USING (playerid)
JOIN collegeplaying AS c
USING (playerid)
JOIN schools AS sc
ON sc.schoolid = c.schoolid
WHERE sc.schoolid LIKE '%vand%'
GROUP by playerid
ORDER by total_salary DESC
LIMIT 1;

-- David Price, David Taylor, $245,553,888.00

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- positions in fielding table
SELECT DISTINCT pos AS position,
	CASE
	WHEN pos LIKE 'OF' THEN 'Outfield'
	WHEN pos IN ('1B', '2B', '3B', 'SS') THEN 'Infield'
	ELSE 'Battery'
    END AS position_category
FROM fielding
GROUP BY position, position_category;

-- "1B"	"Infield"
-- "2B"	"Infield"
-- "3B"	"Infield"
-- "C"	"Battery"
-- "OF"	"Outfield"
-- "P"	"Battery"
-- "SS"	"Infield"

---- # of players per position
SELECT
	CASE
	WHEN pos LIKE 'OF' THEN 'Outfield'
	WHEN pos IN ('1B', '2B', '3B', 'SS') THEN 'Infield'
	ELSE 'Battery'
    END AS position_category,
COUNT(*) AS player_count
FROM fielding
GROUP BY position_category;

-- "Battery"	56195
-- "Infield"	52186
-- "Outfield"	28434

--- in 2016
SELECT
	CASE
	WHEN pos LIKE 'OF' THEN 'Outfield'
	WHEN pos IN ('1B', '2B', '3B', 'SS') THEN 'Infield'
	ELSE 'Battery'
    END AS position_category,
SUM(po) AS total_putouts
FROM fielding
WHERE yearID = 2016
GROUP BY position_category;

-- "Battery"	41424
-- "Infield"	58934
-- "Outfield"	29560

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   
SELECT 
	(yearID/10)*10 AS decade, --  really confused on the math but it works
	ROUND(AVG(so/g), 2) AS avg_strikeouts,  -- rounding to 2 decimal places
	ROUND(AVG(hr/g), 2) AS avg_homeruns -- rounding to 2 decimal places
FROM teams
WHERE yearID >= 1920
GROUP by decade
ORDER BY decade ASC;

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


FROM batting
WHERE yearID = 2016



-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?



-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.




-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.




-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


WITH cte AS 
	(SELECT p.playerid, p.namefirst, p.namelast, p.namegiven
FROM people AS p)
SELECT MAX(hr)
FROM teams
WHERE yearID = 2016
WHERE 

-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
