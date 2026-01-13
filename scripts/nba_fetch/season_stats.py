import json
import sys
import time
from nba_api.stats.endpoints import playercareerstats

def normalize_season_id(x: str) -> str:
    return x.strip()

def row_matches_season(row, wanted: str) -> bool:
    sid = str(row.get("SEASON_ID", "")).strip()
    if sid == wanted:
        return True

    if len(wanted) == 7 and wanted[4] == "-":
        start_year = wanted[:4]
        alt = "2" + start_year 
        return sid == alt
    return False

def main():
    if len(sys.argv) != 4:
        print("Usage: season_stats_for_players.py SEASON_ID player_ids.json output.json", file=sys.stderr)
        sys.exit(1)

    season_id = normalize_season_id(sys.argv[1])
    player_ids_path = sys.argv[2]
    out_path = sys.argv[3]

    with open(player_ids_path, "r", encoding="utf-8") as f:
        player_ids = json.load(f)

    out_rows = []

    for i, pid in enumerate(player_ids, start=1):
        try:
            career = playercareerstats.PlayerCareerStats(player_id=str(pid))
            season_totals = career.get_data_frames()[0]  # SeasonTotalsRegularSeason
            records = season_totals.to_dict(orient="records")

            # Find the row for the requested season
            match = None
            for r in records:
                if row_matches_season(r, season_id):
                    match = r
                    break

            if match:
                out_rows.append({
                    "nba_player_id": int(pid),
                    "season_id": season_id,
                    "games_played": match.get("GP"),
                    "minutes_per_game": match.get("MIN"),
                    "pts": match.get("PTS"),
                    "reb": match.get("REB"),
                    "ast": match.get("AST"),
                    "stl": match.get("STL"),
                    "blk": match.get("BLK"),
                    "tov": match.get("TOV") if "TOV" in match else match.get("TO"),
                    "fg_pct": match.get("FG_PCT"),
                    "fg3_pct": match.get("FG3_PCT"),
                    "ft_pct": match.get("FT_PCT"),
                })

            # gentle pacing (nba stats endpoints can rate-limit)
            time.sleep(0.4)
        except Exception as e:
            print(f"Error for player {pid}: {e}", file=sys.stderr)
            time.sleep(1.5)

        if i % 50 == 0:
            print(f"Processed {i}/{len(player_ids)} players...", file=sys.stderr)

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(out_rows, f)

    print(f"Wrote {len(out_rows)} rows to {out_path}", file=sys.stderr)

if __name__ == "__main__":
    main()
