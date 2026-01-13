import json
from nba_api.stats.static import players

def main():
    all_players = players.get_players()
    active = [p for p in all_players if p.get("is_active")]

    print(json.dumps(active))

if __name__ == "__main__":
    main()
