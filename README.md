# ⚽ Producing Soccer Insights for a Sports Media Agency

This SQL project analyzes match data from the UEFA Championship (2020–2022) to uncover team performance patterns and tactical insights. The goal is to generate actionable insights for a sports media agency using Snowflake SQL.

---

## 📌 Project Objectives

- Identify team performance trends based on possession, duels, and shots.
- Evaluate predictive model accuracy based on actual match outcomes.
- Develop reusable SQL views to optimize analytical workflows.
- Visualize data to support data storytelling for media/reporting use cases.

---

## 🧰 Tools & Tech

- **SQL** (Snowflake dialect)
- **Snowflake Cloud Data Warehouse**
- (Optional) Python + Jupyter Notebooks for visualization

---

## 📊 Datasets

- `SOCCER.TBL_UEFA_2020`
- `SOCCER.TBL_UEFA_2021`
- `SOCCER.TBL_UEFA_2022`

Each table contains match-level statistics, team names, scores, possession metrics, and prediction probabilities for each UEFA match played.

---

## Core Insights

### 1. Teams With Most Games of Majority Possession (per Season)
- Identified which team dominated possession most frequently from 2020–2022.
- Used `CASE`, `RANK()`, and multi-table `UNION ALL` to compare team dominance across years.

```sql
WITH all_matches AS (
  SELECT '2020' AS SEASON, * FROM SOCCER.TBL_UEFA_2020
  UNION ALL
  SELECT '2021' AS SEASON, * FROM SOCCER.TBL_UEFA_2021
  UNION ALL
  SELECT '2022' AS SEASON, * FROM SOCCER.TBL_UEFA_2022
),
...
SELECT SEASON, TEAM_NAME, GAME_COUNT
FROM ranked
WHERE team_rank = 1;
```
👉 [See full query](analysis/team_possession_leaders.sql)

### 2. Duel Winners Who Still Lost the Match (2020-2022)
- Identified teams that won more duels than their opponent, yet still lost the game — a sign of inefficiency or poor finishing.
- Extended across all three UEFA seasons (2020–2022) for deeper trends.
- Used a `CASE` statement with a multi-season `UNION ALL` and match filtering.

```sql
WITH all_matches AS (
    SELECT '2020' AS SEASON, * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT '2021' AS SEASON, * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT '2022' AS SEASON, * FROM SOCCER.TBL_UEFA_2022
),
...
SELECT
    SEASON,
    STAGE,
    TEAM_LOST
FROM duel_lost_games
WHERE TEAM_LOST IS NOT NULL
ORDER BY SEASON, STAGE;
```
👉 [View full query](analysis/duel_winners_lost_match.sql)

### 3. Top 5 Most Aggressive Teams by Stage
- Identified teams that consistently played aggressively by taking the most total shots during UEFA matches.
- Combined data across 2020–2022 seasons to ensure a broader view of performance.
- Used `RANK()` and `PARTITION BY STAGE` to select the top 5 teams per stage.

```sql
WITH all_matches AS (
    SELECT * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2022
),
...
SELECT STAGE, TEAM, TOTAL_SHOTS
FROM ranked_teams
WHERE shot_rank <= 5;
```
👉 [See full query](analysis/top_5_aggressive_teams.sql)

### 4. Most Efficient Teams (Shots on Target per Shot Attempt)
- Calculated which teams were most efficient in turning shot attempts into shots on target across all UEFA seasons (2020–2022).
- Combined home and away stats using `UNION ALL`, then aggregated and ranked based on an efficiency ratio.
- Used `ROUND()` and `NULLIF()` for clean, safe calculation of ratios.

```sql
WITH all_matches AS (
    SELECT * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2022
),
...
SELECT
    TEAM,
    TOTAL_TARGETS,
    TOTAL_SHOTS,
    ROUND(TOTAL_TARGETS / NULLIF(TOTAL_SHOTS, 0), 3) AS EFFICIENCY
FROM team_total_shots
ORDER BY EFFICIENCY DESC;
```
👉 [View full query](analysis/most_efficient_teams.sql)

### 5. Win Probability Accuracy Tracker (2020-2022)
- Compared predicted outcomes with actual results.
- Evaluated prediction model overall reliability.

```sql
WITH all_matches AS (
    SELECT * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2022
),
...
SELECT 
  COUNT(*) AS TOTAL_MATCHES,
  SUM(IS_CORRECT) AS CORRECT_PREDICTIONS,
  ROUND(SUM(IS_CORRECT) / COUNT(*), 3) AS ACCURACY
FROM accuracy_check;
```
👉 [View full query](analysis/win_probability_accuracy_overall.sql)

### 6. Win Probability Accuracy Tracker (By Stage)
- Evaluated how accurately the prediction model performed across different tournament stages (2020–2022).
- Assigned the most likely predicted result based on highest probability field.
- Compared with actual result using final scores.
- Accuracy is calculated per stage to understand where the model performs better.

```sql
WITH all_matches AS (
    SELECT * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2022
),
...
SELECT 
  'ALL' AS STAGE,
  COUNT(*) AS TOTAL_MATCHES,
  SUM(IS_CORRECT) AS CORRECT_PREDICTIONS,
  ROUND(SUM(IS_CORRECT) / COUNT(*), 3) AS ACCURACY
FROM accuracy_check

ORDER BY 
  CASE WHEN STAGE = 'ALL' THEN 1 ELSE 0 END,
  STAGE;
```
👉 [View full query](analysis/win_probability_accuracy_by_stage.sql)

### 7. Win Probability Accuracy Tracker (By Team)
- Evaluated how accurately the prediction model performed across all teams during UEFA tournaments (2020–2022).
- Assigned the most likely predicted result for each match based on the highest probability field.
- Compared with actual match results to determine whether the prediction was correct for each team.
- Accuracy is calculated per team to identify which teams consistently outperformed or underperformed model expectations.

```sql
WITH all_matches AS (
    SELECT * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2022
),
...
SELECT 
	TEAM_NAME,
	COUNT(*) AS TOTAL_MATCHES,
	SUM(IS_CORRECT) AS CORRECT_PREDICTIONS,
	ROUND(SUM(IS_CORRECT) / COUNT(*), 3) AS ACCURACY
FROM accuracy_check
GROUP BY TEAM_NAME
ORDER BY ACCURACY DESC;
```
👉 [View full query](analysis/win_probability_accuracy_by_teams.sql)

### 8. Possession vs. Result Correlation
- Investigates the myth: “More possession = more wins.”
- Shows whether tactical dominance leads to real results.

## Views Created

Reusable SQL views created to improve modularity and performance:
- `VIEW_TEAM_POSSESSION_ANALYSIS`
- `VIEW_DUEL_LOSSES_BY_STAGE`

## Key Skills Demonstrated

- SQL aggregation, CASE logic, filtering
- Data modeling using Snowflake views
- Analyzing sports performance using structured data
- Optional: Data storytelling via visualizations

## 📬 Contact

_If you have questions about this project or want to collaborate, feel free to reach out!_
