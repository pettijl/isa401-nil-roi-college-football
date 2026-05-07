# Data Dictionary

## Final Dataset

File: `data/final/nil_roi_team_season_final.csv`

| Variable | Description |
|---|---|
| `season` | College football season year |
| `school` | School/team name |
| `school_key` | Standardized school key used for joins |
| `conference` | Team conference |
| `classification` | CFBD classification, usually FBS |
| `total_games` | Total games played |
| `wins` | Total wins |
| `losses` | Total losses |
| `expected_wins_cfbd` | CFBD expected wins based on post-game win probability |
| `win_pct` | Wins divided by total games |
| `team_talent_score` | 247Sports roster talent score through CFBD |
| `recruiting_rank` | Team recruiting class rank |
| `recruiting_points` | Team recruiting points |
| `srs_rating` | Simple Rating System rating |
| `srs_ranking` | SRS ranking |
| `pass_ypa` | Passing yards per attempt |
| `rush_ypc` | Rushing yards per carry |
| `total_yds` | Total offensive yards |
| `turnovers` | Total turnovers |
| `turnovers_pg` | Turnovers per game |
| `third_conv_rate` | Third down conversion rate |
| `penalties_pg` | Penalties per game |
| `total_public_nil_value` | Sum of public NIL valuations connected to the team |
| `avg_public_nil_value` | Average public NIL valuation among listed players |
| `median_public_nil_value` | Median public NIL valuation among listed players |
| `top_player_nil_value` | Highest public NIL valuation on the team |
| `top3_nil_value` | Sum of top three listed NIL valuations on the team |
| `qb_nil_value` | Total NIL valuation tied to listed quarterbacks |
| `skill_position_nil_value` | Total NIL valuation tied to QB/RB/WR/TE |
| `nil_players_counted` | Number of listed On3 players counted for team |
| `qb_nil_share` | QB NIL value divided by total team NIL value |
| `skill_position_nil_share` | Skill-position NIL value divided by total team NIL value |
| `nil_concentration` | Top 3 NIL value divided by total team NIL value |
| `total_athletic_revenue` | Athletic department revenue proxy from finance source |
| `total_athletic_expenses` | Athletic department expense proxy from finance source |
| `football_spending` | Football operating spending proxy |
| `football_coaching_salaries` | Football coaching salary proxy |
| `donor_contributions` | Donor contribution proxy, if available |
| `nil_value_millions` | Total public NIL value divided by 1,000,000 |
| `wins_per_million_nil` | Wins divided by NIL value in millions |
| `talent_percentile` | Percentile rank of team talent score |
| `nil_percentile` | Percentile rank of public NIL value |
| `spending_percentile` | Percentile rank of football spending |
| `power_conference` | Power Conference or Other FBS |
| `expected_win_pct` | Model-predicted win percentage |
| `nil_roi_score` | Actual win percentage minus expected win percentage |
| `roi_group` | High ROI / Overperformer, Expected Range, or Low ROI / Underperformer |
