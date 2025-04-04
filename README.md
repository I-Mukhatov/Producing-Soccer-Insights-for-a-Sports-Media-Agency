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
- Uses `CASE`, `RANK()`, and multi-table `UNION ALL` to compare team dominance across years.

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

### 2. Duel Winners Who Still Lost the Match (2022)
- Lists teams that won more duels but still lost — broken down by match stage.
- Conditional CASE logic, filtering, tactical analysis.

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

### 4. Most Efficient Teams (Shots on Target per Goal)
- Measures finishing quality.
- Highlights teams that convert chances effectively.

### 5. Win Probability Accuracy Tracker
- Compares predicted outcomes with actual results.
- Evaluates prediction model reliability.

### 6. Possession vs. Result Correlation
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
