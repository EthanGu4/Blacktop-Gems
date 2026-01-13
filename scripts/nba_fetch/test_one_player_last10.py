import json
from datetime import datetime

from nba_api.stats.endpoints import playergamelog


def parse_api_game_date(game_date_str: str):
    return datetime.strptime(game_date_str, "%b %d, %Y").date()
    # nba_api PlayerGameLog uses strings like "Jan 15, 2025"


def main():
    player_id = 203999   # Jokic
    season_id = "2024-25"

    resp = playergamelog.PlayerGameLog(
        player_id=player_id,
        season=season_id,
        season_type_all_star="Regular Season",
        timeout=120,
    )

    df = resp.get_data_frames()[0]
    rows = df.to_dict(orient="records")

    # sort by most recent games
    rows.sort(key=lambda r: parse_api_game_date(r["GAME_DATE"]), reverse=True)

    out = []
    for r in rows[:10]:
        gd = parse_api_game_date(r["GAME_DATE"])
        out.append({
            "game_id": str(r.get("GAME_ID")),
            "nba_player_id": player_id,
            "game_date": gd.isoformat(),

            "minutes": r.get("MIN"),
            "pts": r.get("PTS"),
            "reb": r.get("REB"),
            "ast": r.get("AST"),
            "stl": r.get("STL"),
            "blk": r.get("BLK"),
            "tov": r.get("TOV") if "TOV" in r else r.get("TO"),

            "fg_made": r.get("FGM"),
            "fg_attempted": r.get("FGA"),
            "fg3_made": r.get("FG3M"),
            "fg3_attempted": r.get("FG3A"),
            "ft_made": r.get("FTM"),
            "ft_attempted": r.get("FTA"),

            "plus_minus": r.get("PLUS_MINUS"),
        })

    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
