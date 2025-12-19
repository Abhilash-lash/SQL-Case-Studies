--Q1 Find the total spending on players for each team:
select 
  Team, 
  sum(Price_in_cr) as 'Total Spending in Cr' 
from 
  iplplayers 
group by 
  Team 
order by 
  'Total Spending in Cr' desc 

--Q2 Find the top 3 highest-paid 'All-rounders' across all teams: 
Select 
  top 3 Player, 
  Price_in_cr, 
  Role, 
  Team 
from 
  iplplayers 
where 
  Role = 'All-rounder' 
order by 
  Price_in_cr desc 

--Q3 Find the highest-priced player in each team:
select 
  Player, 
  Price_in_cr, 
  Team 
from 
  (
    select 
      player, 
      price_in_cr, 
      team, 
      row_number() over (
        partition by team 
        order by 
          price_in_cr desc
      ) as rnk 
    from 
      iplplayers
  ) temp 
where 
  rnk = 1 
order by 
  Price_in_cr desc 

--Q4 Rank players by their price within each team and list the top 2 for every team:
  with ranked_players as (
    select 
      player, 
      team, 
      price_in_cr, 
      row_number() over (
        partition by team 
        order by 
          price_in_cr desc
      ) as rnk 
    from 
      iplplayers
  ) 
select 
  Player, 
  Team, 
  Price_in_cr as 'Price(Cr)' 
from 
  ranked_players 
where 
  rnk <= 2 
  
--Q5 Find the most expensive player from each team, along with the second-most expensive player's name and price:
  with ranked_players as (
    select 
      player, 
      team, 
      price_in_cr, 
      row_number() over (
        partition by team 
        order by 
          price_in_cr desc
      ) as rnk 
    from 
      iplplayers
  ) 
select 
  team, 
  max(case when rnk = 1 then player end) as first_priced, 
  max(
    case when rnk = 1 then Price_in_cr end
  ) as first_price_inCr, 
  max(case when rnk = 2 then player end) as second_priced, 
  max(
    case when rnk = 2 then Price_in_cr end
  ) as second_price_inCr 
from 
  ranked_players 
group by 
  team 
  
--Q6 Calculate the percentage contribution of each player's price to their team's total spending
select 
  player, 
  Price_in_cr, 
  Team, 
  sum(price_in_cr) over(partition by team) as total_team_expenditure, 
  cast(
    (
      Price_in_cr * 100.0 / sum(price_in_cr) over(partition by team)
    ) as decimal(5, 2)
  ) as percentage_of_total 
from 
  IPLPlayers 
order by 
  percentage_of_total desc 
  
--Q7 Classify players as 'High', 'Medium', or 'Low' priced based on the following rules:
  --High: Price > ₹15 crore
  --Medium: Price between ₹5 crore and ₹15 crore
  --Low: Price < ₹5 crore
  --and find out the number of players in each bracket
  with cat_players as(
    select 
      Player, 
      Price_in_cr, 
      Team, 
      case when Price_in_cr > 15.00 then 'High' when Price_in_cr between 5 
      and 15 then 'Medium' else 'Low' end as 'Category' 
    from 
      IPLPlayers
  ) 
select 
  Team, 
  Category, 
  count(*) as 'Count_of_Category' 
from 
  cat_players 
group by 
  Team, 
  Category 
order by 
  Team 
  
--Q8 Find the average price of Indian players and compare it with overseas players using a subquery:
  (
    select 
      'Indian' as Player_Type, 
      avg(price_in_cr) as Average_Price 
    from 
      IPLPlayers 
    where 
      type like 'India%'
  ) 
union 
  (
    select 
      'Overseas' as Player_Type, 
      avg(price_in_cr) as Average_Price 
    from 
      IPLPlayers 
    where 
      type like 'Overseas%'
  ) 
  
--Q9 Identify players who earn more than the average price of their team:
select 
  * 
from 
  (
    select 
      player, 
      Price_in_cr, 
      team, 
      cast(
        AVG(price_in_cr) over(partition by team) AS decimal(5, 2)
      ) as 'AverageTeamPrice' 
    from 
      IPLPlayers
  ) t 
where 
  price_in_cr > AverageTeamPrice 
order by 
  Team, 
  Price_in_cr desc 
  
--Q10 For each role, find the most expensive player and their price using a correlated subquery
  
  /*Query to show Max Price under each Role*/
select 
  distinct role, 
  max(price_in_cr) over(partition by role) as 'maxPriceforPlayer' 
from 
  IPLPlayers 

-- Derived Table Method
select 
  * 
from 
  (
    select 
      player, 
      role, 
      team, 
      price_in_cr, 
      max(price_in_cr) over(partition by role) as 'maxPriceforPlayer' 
    from 
      IPLPlayers
  ) temp 
where 
  Price_in_cr = maxPriceforPlayer 
  
-- Correlated Subquery Method
select 
  player, 
  role, 
  price_in_cr, 
  team 
from 
  IPLPlayers i 
where 
  price_in_cr =(
    select 
      max(price_in_cr) 
    from 
      IPLPlayers 
    where 
      role = i.role
  ) 
order by 
  role
