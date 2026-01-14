import json
from nba_api.stats.static import players
from nba_api.stats.endpoints import commonplayerinfo
import time

def main():
    all_players = players.get_players()
    active_players = [p for p in all_players if p.get("is_active")]

    result = []

    for p in active_players:
        player_id = p["id"]

        try:
            info = commonplayerinfo.CommonPlayerInfo(player_id=player_id)
            data = info.get_data_frames()[0]

            team_id = int(data.at[0, "TEAM_ID"]) if data.at[0, "TEAM_ID"] else None
            team_abbr = data.at[0, "TEAM_ABBREVIATION"]

        except Exception:
            team_id = None
            team_abbr = None

        result.append({
            "id": player_id,
            "first_name": p["first_name"],
            "last_name": p["last_name"],
            "full_name": p["full_name"],
            "is_active": True,
            "team_id": team_id,
            "team_abbreviation": team_abbr
        })

        time.sleep(0.6)  # avoid NBA rate limiting

    print(json.dumps(result))

if __name__ == "__main__":
    main()
