import json
import sys
from datetime import datetime, timedelta

from nba_api.stats.endpoints import playergamelogs


def parse_game_date(s: str):
    s = (s or "").strip()
    for fmt in (
        "%Y-%m-%dT%H:%M:%S",  # 2025-11-24T00:00:00
        "%Y-%m-%d",           # 2025-11-24
        "%m/%d/%Y",           # 11/24/2025
        "%b %d, %Y",          # Nov 24, 2025
        "%B %d, %Y",          # November 24, 2025
    ):
        try:
            return datetime.strptime(s, fmt).date()
        except Exception:
            pass
    return None


def main():
    if len(sys.argv) != 5:
        sys.exit(1)

    season_id = sys.argv[1].strip()
    days_back = int(sys.argv[2])
    ids_path = sys.argv[3]
    out_path = sys.argv[4]

    with open(ids_path, "r", encoding="utf-8") as f:
        active_ids = set(int(x) for x in json.load(f) if x is not None)

    date_to = datetime.utcnow().date()
    date_from = date_to - timedelta(days=days_back)

    resp = playergamelogs.PlayerGameLogs(
        season_nullable=season_id,
        season_type_nullable="Regular Season",
        date_from_nullable=date_from.strftime("%m/%d/%Y"),
        date_to_nullable=date_to.strftime("%m/%d/%Y"),
        timeout=90,
    )

    df = resp.get_data_frames()[0]
    rows = df.to_dict(orient="records")
    
    per_player = {}
    for r in rows:
        pid = r.get("PLAYER_ID")
        if pid is None:
            continue

        pid = int(pid)
        if pid not in active_ids:
            continue
        
        gd = parse_game_date(str(r.get("GAME_DATE", "")))
        if gd is None:
            continue
        
        per_player.setdefault(pid, []).append((gd, r))

    out = []
    for pid, games in per_player.items():
        games.sort(key=lambda x: x[0], reverse=True)
        for gd, r in games[:10]:
            out.append({
                "game_id": str(r.get("GAME_ID")),
                "nba_player_id": pid,
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

    out.sort(key=lambda r: r["game_date"], reverse=True)

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(out, f)

    print(f"Wrote {len(out)} rows to {out_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
