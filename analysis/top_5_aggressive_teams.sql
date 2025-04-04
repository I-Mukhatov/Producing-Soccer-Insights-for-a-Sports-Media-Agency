WITH all_matches AS (
    SELECT * FROM SOCCER.TBL_UEFA_2020
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2021
    UNION ALL
    SELECT * FROM SOCCER.TBL_UEFA_2022
),
all_shots AS (
    SELECT 
        STAGE, 
        TEAM_NAME_HOME AS TEAM, 
        TOTAL_SHOTS_HOME AS SHOTS
    FROM all_matches

    UNION ALL

    SELECT 
        STAGE, 
        TEAM_NAME_AWAY AS TEAM, 
        TOTAL_SHOTS_AWAY AS SHOTS
    FROM all_matches
),
team_total_shots AS (
    SELECT 
        STAGE,
        TEAM,
        SUM(SHOTS) AS TOTAL_SHOTS
    FROM all_shots
    GROUP BY STAGE, TEAM
),
ranked_teams AS (
    SELECT 
        STAGE,
        TEAM,
        TOTAL_SHOTS,
        RANK() OVER (PARTITION BY STAGE ORDER BY TOTAL_SHOTS DESC) AS shot_rank
    FROM team_total_shots
)

SELECT 
    STAGE,
    TEAM,
    TOTAL_SHOTS,
    shot_rank
FROM ranked_teams
WHERE shot_rank <= 5
ORDER BY STAGE, shot_rank;
