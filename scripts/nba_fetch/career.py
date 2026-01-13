import json
from nba_api.stats.endpoints import playercareerstats

def main():
    # Nikola Jokic NBA.com player ID
    career = playercareerstats.PlayerCareerStats(player_id='203999')

    # This returns multiple tables; we want regular season totals
    data = career.get_data_frames()

    season_totals = data[0]


    # specific points from season
    # rows = season_totals[season_totals["SEASON_ID"] == "2022-23"].iloc[0]
    # print(rows["PTS"])

    rows = season_totals.to_dict(orient="records")
    print(json.dumps(rows))

if __name__ == "__main__":
    main()
