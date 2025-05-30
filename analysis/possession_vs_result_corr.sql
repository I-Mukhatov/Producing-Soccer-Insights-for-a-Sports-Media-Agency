WITH all_matches AS (
    SELECT '2020' AS SEASON, * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT '2021' AS SEASON, * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT '2022' AS SEASON, * FROM SOCCER.TBL_UEFA_2022
),
majority_possession AS (
SELECT
	SEASON,
	CASE
		WHEN POSSESSION_HOME > POSSESSION_AWAY THEN 'HOME'
		WHEN POSSESSION_AWAY > POSSESSION_HOME THEN 'AWAY'
	ELSE 'EQUAL'
	END AS POSSESSION_WINNER,

	CASE
		WHEN TEAM_HOME_SCORE > TEAM_AWAY_SCORE THEN 'HOME'
		WHEN TEAM_AWAY_SCORE > TEAM_HOME_SCORE THEN 'AWAY'
		ELSE 'DRAW'
		END AS MATCH_WINNER
FROM all_matches
),
possession_to_match_winner AS (
SELECT
	*,
	CASE
		WHEN POSSESSION_WINNER = MATCH_WINNER THEN 'POSSESSION_WIN_AND_MATCH_WIN'
		WHEN MATCH_WINNER = 'DRAW' THEN 'POSSESSION_WIN_DRAW'
		ELSE 'POSSESSION_WIN_BUT_LOST'
		END AS POSSESSION_VS_RESULT
FROM majority_possession
)

SELECT 
	SEASON,
	POSSESSION_VS_RESULT,
	COUNT(*) AS MATCH_COUNT,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY SEASON), 2) AS PERCENTAGE
FROM possession_to_match_winner
GROUP BY SEASON, POSSESSION_VS_RESULT
ORDER BY SEASON;
