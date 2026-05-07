# Tableau Storyboard Layout

## Story Point 1: Title Page

Title:

**NIL ROI in College Football: Are Programs Converting Player Investment Into Wins?**

Include:

- team number
- team member names
- research question

## Story Point 2: Business Problem

Text:

> NIL has changed college football by making roster construction more financially driven. Donors, collectives, and athletic departments now need to know whether player investment is translating into wins.

## Story Point 3: Data Sources and Methods

Visual:

Source table showing On3, CollegeFootballData, and Knight-Newhouse/EADA.

## Story Point 4: NIL Market Landscape

Chart:

Horizontal bar chart of `total_public_nil_value` by school.

Filters:

- season
- conference

## Story Point 5: NIL Value vs. Winning

Chart:

Scatterplot.

- X-axis: `total_public_nil_value`
- Y-axis: `win_pct`
- Color: `conference`
- Size: `team_talent_score`
- Tooltip: school, wins, losses, NIL value, talent score, NIL ROI score

## Story Point 6: Best NIL ROI Programs

Chart:

Horizontal bar chart of top schools by `nil_roi_score`.

## Story Point 7: Lowest NIL ROI Programs

Chart:

Horizontal bar chart of bottom schools by `nil_roi_score`.

## Story Point 8: Star Spending vs. Balanced Spending

Chart options:

- `nil_concentration` vs. `win_pct`
- `qb_nil_share` vs. `win_pct`
- `skill_position_nil_share` vs. `win_pct`

Main question:

> Is NIL value better concentrated in a few stars, focused on quarterback, or spread across the roster?

## Story Point 9: Conference Comparison

Chart:

Heat map or grouped bar chart.

Metrics:

- average NIL value
- average team talent
- average win percentage
- average NIL ROI score

## Story Point 10: Final Takeaways

Takeaways:

1. NIL/player-market value is related to winning, but it does not guarantee success.
2. The highest-value programs are not always the most efficient programs.
3. Star-player value and QB value are useful, but balanced roster value may matter more.
4. Donors should think about targeted roster construction, not just chasing expensive names.
