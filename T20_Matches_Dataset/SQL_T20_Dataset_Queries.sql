 USE sql_case_studies;
--Q1 Identify matches played between two specific teams (e.g., India and South Africa) in 2024 and their results.
SELECT *
FROM   t20i
WHERE  (
              team1='India'
       AND    team2='South Africa')
OR     (
              team1='South Africa'
       AND    team2='India')


--Q2 Find the team with the highest number of wins in 2024 and the total matches it won.
SELECT TOP 1
                     winner,
         Count(*) AS Total_Wins
FROM     t20i
GROUP BY winner
ORDER BY Count(*) DESC


--Q3 Rank the teams based on the total number of wins in 2024.
SELECT   winner,
         Count(*)                                   AS Total_Wins,
         Dense_rank() OVER( ORDER BY Count(*) DESC) AS Rnk
FROM     t20i
WHERE    winner NOT IN ('tied',
                        'no result')
GROUP BY winner
--order by Count(*) desc


--Q4 Which team had the highest average winning margin (in runs), and what was the average margin?
SELECT   winner,
         Avg(Cast(Substring(margin,1,Charindex(' ',margin)-1) AS INT)) AS Average_margin
FROM     t20i
WHERE    margin LIKE '%runs'
GROUP BY winner
ORDER BY average_margin DESC


--Q5 List all matches where the winning margin was greater than the average margin across all matches.
SELECT *,
       Cast(Substring(margin,1,Charindex(' ',margin)-1) AS INT) AS margin_runs
FROM   t20i
WHERE  margin LIKE '%runs'
AND    Cast(Substring(margin,1,Charindex(' ',margin)-1) AS INT)>
       (
              SELECT Avg(Cast(Substring(margin,1,Charindex(' ',margin)-1) AS INT)) AS average_margin
              FROM   t20i
              WHERE  margin LIKE '%runs' )
 
 -- OR ---
 
 with cte_margin AS
       (
              SELECT *,
                     cast(substring(margin,1,charindex(' ',margin)-1) AS int) AS mrg
              FROM   t20i
              WHERE  margin LIKE '%runs' )SELECT *
FROM   cte_margin
WHERE  mrg>
       (
              SELECT Avg(mrg)
              FROM   cte_margin)


--Q6 Find the team with the most wins when chasing a target (wins by wickets)
       with rnk_table AS
       (
                SELECT   winner,
                         count(*)                             AS 'Won by chasing',
                         rank() OVER( ORDER BY count(*) DESC) AS rnk
                FROM     t20i
                WHERE    margin LIKE '%wickets'
                GROUP BY winner )SELECT winner,
       [won by chasing]
FROM   rnk_table
WHERE  rnk=1


--Q7 Head-to-head record between two selected teams (e.g., England vs Australia).
-- To list all matches played between two teams
SELECT *
FROM   t20i
WHERE  (
              team1='Australia'
       AND    team2='England')
OR     (
              team2='Australia'
       AND    team1='England')
-- To list wins by each team when played against each other
SELECT   winner,
         Count(*) AS 'Matches Won'
FROM     t20i
WHERE    (
                  team1='Australia'
         AND      team2='England')
OR       (
                  team2='Australia'
         AND      team1='England')
GROUP BY winner


--Q8 Identify the month in 2024 with the highest number of T20I matches played.
SELECT   Datename(mm,matchdate) AS month,
         Count(*)               AS 'Matches Played'
FROM     t20i
WHERE    Year(matchdate)=2024
GROUP BY Datename(mm,matchdate)
ORDER BY Count(*) DESC


--Q9 For each team, find how many matches they played in 2024 and their win percentage.
         with list AS
         (
                SELECT team1 AS team_name
                FROM   t20i
                WHERE  year(matchdate)=2024
                UNION ALL
                SELECT team2
                FROM   t20i
                WHERE  year(matchdate)=2024 ),
         team_list AS
         (
                  SELECT   team_name,
                           count(*) AS matches
                  FROM     list
                  GROUP BY team_name ),
         win_list AS
         (
                  SELECT   winner,
                           count(*) AS wins
                  FROM     t20i
                  WHERE    winner NOT IN ('tied',
                                          'no result')
                  GROUP BY winner )SELECT    t.team_name,
          t.matches,
          Isnull(w.wins,0)                                     AS wins,
          Cast((Isnull(wins,0)*100.0)/matches AS DECIMAL(5,2)) AS 'win_percentage'
FROM      team_list t
LEFT JOIN win_list w
ON        t.team_name=w.winner
ORDER BY  win_percentage DESC


--Q10 Identify the most successful team at each ground (team with most wins per ground).
          with cte_ranked AS
          (
                   SELECT   ground,
                            winner,
                            count(*)                                                 AS 'matches won',
                            rank() OVER( partition BY ground ORDER BY count(*) DESC) AS 'rnk'
                   FROM     t20i
                   WHERE    winner NOT IN ('tied',
                                           'no result')
                   GROUP BY ground,
                            winner )SELECT ground,
        winner,
        [matches won]
 FROM   cte_ranked
 WHERE  rnk=1 