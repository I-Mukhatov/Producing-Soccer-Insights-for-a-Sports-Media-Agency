WITH all_matches AS (
    SELECT * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2022
),
match_results AS (
  SELECT
    CASE
      WHEN PREDICTION_TEAM_HOME_WIN > PREDICTION_DRAW AND PREDICTION_TEAM_HOME_WIN > PREDICTION_TEAM_AWAY_WIN THEN 'HOME_WIN'
      WHEN PREDICTION_TEAM_AWAY_WIN > PREDICTION_TEAM_HOME_WIN AND PREDICTION_TEAM_AWAY_WIN > PREDICTION_DRAW THEN 'AWAY_WIN'
      ELSE 'DRAW'
    END AS PREDICTED_RESULT,

    CASE
      WHEN TEAM_HOME_SCORE > TEAM_AWAY_SCORE THEN 'HOME_WIN'
      WHEN TEAM_HOME_SCORE < TEAM_AWAY_SCORE THEN 'AWAY_WIN'
      ELSE 'DRAW'
    END AS ACTUAL_RESULT
  FROM all_matches
),
accuracy_check AS (
  SELECT *,
         CASE WHEN PREDICTED_RESULT = ACTUAL_RESULT THEN 1 ELSE 0 END AS IS_CORRECT
  FROM match_results
)
SELECT 
  COUNT(*) AS TOTAL_MATCHES,
  SUM(IS_CORRECT) AS CORRECT_PREDICTIONS,
  ROUND(SUM(IS_CORRECT) / COUNT(*), 3) AS ACCURACY
FROM accuracy_check;
