# ⚽ Producing Soccer Insights for a Sports Media Agency

This SQL project analyzes match data from the UEFA Championship (2020–2022) to uncover team performance patterns and tactical insights. The goal is to generate actionable insights for a sports media agency using Snowflake SQL.

---
![image](https://github.com/user-attachments/assets/b0cb6897-518c-4b37-9e30-e6ba3c93abd6)

## 📌 Project Objectives

- Identify team performance trends based on possession, duels, and shots.
- Evaluate predictive model accuracy based on actual match outcomes.
- Develop reusable SQL views to optimize analytical workflows.
- Visualize data to support data storytelling for media/reporting use cases.

---

## 🧰 Tools & Tech

- **SQL** (Snowflake dialect)
- **Snowflake Cloud Data Warehouse**
- **Python** + **Jupyter Notebooks** for visualization of core insights

---

## 📊 Datasets

#### Schema name: `SOCCER`
#### Table Name(s): `TBL_UEFA_2020` | `TBL_UEFA_2021` | `TBL_UEFA_2022`
**Note** : All three tables have same column names and data types

| Column | Definition | Data type |
|--------|------------|-----------|
| `STAGE`| Stage of the March | `VARCHAR(50)` |
| `DATE` | When the match occurred. | `DATE` |
| `PENS` | Did the match end with penalty | `VARCHAR(50)` |
| `PENS_HOME_SCORE` | In case of penalty, score by home team | `VARCHAR(50)` |
| `PENS_AWAY_SCORE` | In case of penalty, score by away team | `VARCHAR(50)` |
| `TEAM_NAME_HOME` | Team home name | `VARCHAR(50)` |
| `TEAM_NAME_AWAY`| Team away  name | `VARCHAR(50)` |
| `TEAM_HOME_SCORE` | Team home score | `NUMBER` |
| `TEAM_AWAY_SCORE` | Team away score | `NUMBER` |
| `POSSESSION_HOME` | Ball possession for the home team | `FLOAT` |
| `POSSESSION_AWAY` | Ball possession for the away team | `FLOAT` |
| `TOTAL_SHOTS_HOME` | Number of shots by the home team | `NUMBER` |
| `TOTAL_SHOTS_AWAY` | Number of shots by the away team | `NUMBER`
| `SHOTS_ON_TARGET_HOME` | Total shot for home team | `FLOAT` |
| `SHOTS_ON_TARGET_AWAY` | Total shot for away team | `FLOAT` |
| `DUELS_WON_HOME` | duel win possession of ball - for home team | `NUMBER` |
| `DUELS_WON_AWAY` | duel win possession of ball - for away team | `NUMBER` 
| `PREDICTION_TEAM_HOME_WIN` | Probability of home team to win | `FLOAT` |
| `PREDICTION_DRAW` | Probability of draw | `FLOAT` |
| `PREDICTION_TEAM_AWAY_WIN` | Probability of away team to win | `FLOAT` |
| `LOCATION` | Stadium where the match was held | `VARCHAR(50)` | 

Each table contains match-level statistics, team names, scores, possession metrics, and prediction probabilities for each UEFA match played.

**Data Source:** This project uses UEFA match data provided in DataCamp's Data Sources repository for DataLab projects hosted on Snowflake.

- [Sample UEFA 2020 Data](data/TBL_UEFA_2020_Sample.csv)  
- [Sample UEFA 2021 Data](data/TBL_UEFA_2021_Sample.csv)  
- [Sample UEFA 2022 Data](data/TBL_UEFA_2022_Sample.csv)  

---

## 💡 Core Insights

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
- Analyzed whether having majority possession led to winning across UEFA tournaments (2020–2022).
- Assigned match outcomes and possession dominance, then compared them.
- Calculated how often possession-dominant teams won, drew, or lost — broken down by season.
- Provided a data-driven look at the common belief: "more possession = better results."

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
	POSSESSION_VS_RESULT,
	COUNT(*) AS MATCH_COUNT,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY SEASON), 2) AS PERCENTAGE
FROM possession_to_match_winner
GROUP BY SEASON, POSSESSION_VS_RESULT
ORDER BY SEASON;
```
👉 [View full query](analysis/possession_vs_result_corr.sql)

---

## 🔎 Views Created

**Note:** Views in this project are presented for demonstration purposes only. Due to environment restrictions in DataLab, actual CREATE VIEW execution was not permitted. Logic remains fully reusable in any Snowflake-compatible environment.

#### `VIEW_TEAM_POSSESSION_ANALYSIS`
- Identifies the team with majority possession in each match, across all UEFA seasons (2020-2022).
- Transforms raw possession data into a match-level insight: “Who dominated possession in this game?”
- Includes match stage, date, and team names for contextual analysis.
- Makes other SQL queries simpler and more readable by offloading the logic.
```sql
-- View: VIEW_TEAM_POSSESSION_ANALYSIS
-- Description: Identifies the team with majority possession in each match across all seasons.
-- Data Source: TBL_UEFA_2020, TBL_UEFA_2021, TBL_UEFA_2022
-- Dependencies: Requires possession fields and team names.
CREATE VIEW VIEW_TEAM_POSSESSION_ANALYSIS AS
WITH all_matches AS (
    SELECT '2020' AS SEASON, * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT '2021' AS SEASON, * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT '2022' AS SEASON, * FROM SOCCER.TBL_UEFA_2022
)
...
```
👉 [View full query](analysis/view_team_possession_analysis.sql)

#### `VIEW_DUEL_LOSSES_BY_STAGE`
- Identifies matches where a team won more duels but still lost the game, across all UEFA seasons (2020–2022).
- Highlights potential tactical inefficiencies — teams that dominate physical play but fail to convert it into results.
- Includes match stage, date, and team names for contextual analysis.
- Useful for stage-wise performance breakdowns and in-depth tactical reviews.
```sql
-- View: VIEW_DUEL_LOSSES_BY_STAGE
-- Description: Captures matches where a team won more duels but still lost the match, broken
-- down by stage.
-- Data Source: TBL_UEFA_2020, TBL_UEFA_2021, TBL_UEFA_2022
-- Dependencies: Requires duels fields and team names.
CREATE VIEW VIEW_DUEL_LOSSES_BY_STAGE AS
WITH all_matches AS (
    SELECT '2020' AS SEASON, * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT '2021' AS SEASON, * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT '2022' AS SEASON, * FROM SOCCER.TBL_UEFA_2022
)
...
```
👉 [View full query](analysis/view_duel_losses_by_stage.sql)

---

## 📈 Core Insights Visualization
### 1. Win Probability Accuracy (Per Stage / Per Team)
**Why it matters:**
- Helps stakeholders see where the prediction model works best — or fails.
- Makes performance patterns immediately visible.

**Created Visualizations**
- 📊 Bar charts: Accuracy by stage & Accuracy by team.

**Insight Summary**
- **Stage matters:** Predictive accuracy declines in later, more competitive rounds.
- **Team type matters:** The model performed best with teams that likely followed more consistent patterns — weaker clubs may have been easier to predict.
- **Opportunity:** Future improvements could involve retraining models specifically for knockout rounds or elite matchups.

👉 [View code/visuals](notebooks/UEFA_Insights_Win_Probability_Accuracy_Per_Stage_Per_Team.ipynb)

### 2. Possession vs. Result Correlation
**Why it matters:**
- Debunks or confirms the myth that "more possession = more wins".
- Visual impact strengthens the insight (e.g., surprising % of losses with high possession).

**Created Visualizations**
- 📊 Pie or donut chart: Win/loss/draw breakdown when a team had possession advantage.
- 📊 Stacked bar chart: Possession result types by season or stage.

**Insight Summary**

---

## 📝 Key Skills Demonstrated

- SQL aggregation, CASE logic, filtering
- Data modeling using Snowflake views
- Analyzing sports performance using structured data
- Optional: Data storytelling via visualizations

## 📬 Contact

_If you have questions about this project or want to collaborate, feel free to reach out!_
