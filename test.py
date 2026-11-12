import math

K = 32
D = 400
MMR_SCALE = 3
MIN_TEAM_GAIN = 6

# 0 = on ne regarde que le niveau de l'équipe
# 1 = on ne regarde que le niveau individuel du joueur
BETA = 0.6


def expected(rating_a, rating_b):
    return 1 / (1 + 10 ** ((rating_b - rating_a) / D))


def margin_multiplier(margin, rating_advantage):
    advantage = max(0, rating_advantage)
    return math.log(margin + 1) * (2.2 / (0.001 * advantage + 2.2))


def simulate_match(team_a, team_b, winner, score_a, score_b):
    if winner not in ("A", "B"):
        raise ValueError("winner doit valoir 'A' ou 'B'")
    if max(score_a, score_b) != 5 or score_a == score_b or min(score_a, score_b) < 0:
        raise ValueError("Un match en 5 buts doit finir 5-0, 5-1, 5-2, 5-3 ou 5-4")

    rating_a = sum(team_a) / len(team_a)
    rating_b = sum(team_b) / len(team_b)
    margin = abs(score_a - score_b)

    advantage = (rating_a - rating_b) if winner == "A" else (rating_b - rating_a)
    multiplier = margin_multiplier(margin, advantage)

    result_a = 1.0 if winner == "A" else 0.0
    result_b = 1.0 - result_a

    def team_changes(team, own_avg, opp_avg, result):
        team_expected = expected(own_avg, opp_avg)
        changes = []
        for r in team:
            individual_expected = expected(r, opp_avg)
            effective = BETA * individual_expected + (1 - BETA) * team_expected
            changes.append(K * multiplier * (result - effective) * MMR_SCALE)
        return changes

    changes_a = team_changes(team_a, rating_a, rating_b, result_a)
    changes_b = team_changes(team_b, rating_b, rating_a, result_b)

    # Plancher sur le gain total de l'équipe gagnante
    winner_total = sum(changes_a) if winner == "A" else sum(changes_b)
    if 0 < winner_total < MIN_TEAM_GAIN:
        correction = MIN_TEAM_GAIN / winner_total
        changes_a = [c * correction for c in changes_a]
        changes_b = [c * correction for c in changes_b]

    print("=== RÉSULTAT DU MATCH ===")
    print(f"Équipe A : {team_a} (moy. {rating_a:.1f})")
    print(f"Équipe B : {team_b} (moy. {rating_b:.1f})")
    print(f"Score : {score_a}-{score_b} | Gagnant : {winner}")
    print(f"Multiplicateur d'écart : {multiplier:.3f}\n")

    for name, team, changes in (("A", team_a, changes_a), ("B", team_b, changes_b)):
        for i, (r, c) in enumerate(zip(team, changes), 1):
            print(f"Joueur {name}{i} : {r:.1f} -> {r + c:.2f} ({c:+.2f})")
    print(f"\nTotal A : {sum(changes_a):+.2f} | Total B : {sum(changes_b):+.2f}\n")

    return {"changes_a": changes_a, "changes_b": changes_b}


# Ton exemple
simulate_match([2000, 800], [1500, 1300], "A", 5, 4)

# 2 forts contre 2 faibles : gain minimal
simulate_match([1800, 1700], [800, 700], "A", 5, 0)

# 2 forts contre 2 forts : vrais gains
simulate_match([1800, 1700], [1750, 1650], "A", 5, 3)