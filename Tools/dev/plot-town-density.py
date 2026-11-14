"""Reproduce the proposed density curves; this does not change gameplay.

Requires matplotlib. Population inputs and source provenance are committed in
docs/research/town-density/. Run from any directory with this script's Python.
"""

from __future__ import annotations

import csv
import json
import math
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "docs/research/town-density"
os.environ.setdefault("MPLCONFIGDIR", str(ROOT / ".work/matplotlib-cache"))

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

MINIMUM = 10.0
CEILING = 180.0
ANCHOR_POPULATION = 50.0
ANCHOR_INFECTED = 40.0
K = math.log((CEILING + ANCHOR_INFECTED) / (CEILING - ANCHOR_INFECTED)) / ANCHOR_POPULATION
H = ANCHOR_POPULATION * (CEILING / ANCHOR_INFECTED - 1.0)


def logistic(population: float) -> float:
    # Equivalent to 360 / (1 + exp(-K * P)) - 180. tanh is stable for large P.
    return max(MINIMUM, CEILING * math.tanh(K * population / 2.0))


def rational(population: float) -> float:
    return max(MINIMUM, CEILING * population / (population + H))


def rounded_count(value: float) -> int:
    # Nearest whole actor with positive half-values rounded upward, as in SQF.
    return min(int(CEILING), max(int(MINIMUM), math.floor(value + 0.5)))


def validate() -> dict:
    populations = [i / 10.0 for i in range(100001)]
    checks = {}
    for name, function in (("logistic", logistic), ("rational", rational)):
        values = [function(p) for p in populations]
        ratios = [z / p for p, z in zip(populations[1:], values[1:])]
        checks[f"{name}_floor_ceiling"] = all(MINIMUM <= z <= CEILING for z in values)
        checks[f"{name}_nondecreasing_count"] = all(a <= b + 1e-10 for a, b in zip(values, values[1:]))
        checks[f"{name}_decreasing_density"] = all(a + 1e-10 >= b for a, b in zip(ratios, ratios[1:]))
        checks[f"{name}_calibration"] = math.isclose(function(ANCHOR_POPULATION), ANCHOR_INFECTED, abs_tol=1e-10)
        checks[f"{name}_integer_bounds"] = all(10 <= rounded_count(z) <= 180 for z in values)
    checks["logistic_equivalent_forms"] = all(
        math.isclose(logistic(p), max(MINIMUM, 2 * CEILING / (1 + math.exp(-K * p)) - CEILING), abs_tol=1e-10)
        for p in (0, 10, 23, 50, 100, 367, 603, 1176, 10000)
    )
    if not all(checks.values()):
        raise AssertionError(checks)
    return checks


def save_plot(figure, name: str) -> None:
    figure.savefig(OUTPUT / f"{name}.png", dpi=180)
    vector = OUTPUT / f"{name}.svg"
    figure.savefig(vector, metadata={"Date": None})
    # Matplotlib emits trailing spaces in path data. Newlines preserve the SVG
    # separators, so normalize the export for clean repository whitespace checks.
    vector.write_text("\n".join(line.rstrip() for line in vector.read_text(encoding="utf-8").splitlines()) + "\n", encoding="utf-8")


def draw_curves(towns: list[dict]) -> None:
    plt.rcParams.update({
        "font.family": "DejaVu Sans", "font.size": 16,
        "axes.labelsize": 16, "axes.titlesize": 17,
        "xtick.labelsize": 14, "ytick.labelsize": 14,
        "svg.fonttype": "none", "svg.hashsalt": "infection-town-density-v1",
        "axes.spines.top": False, "axes.spines.right": False,
        "axes.edgecolor": "#697386", "axes.labelcolor": "#1d2939",
        "text.color": "#1d2939", "xtick.color": "#344054", "ytick.color": "#344054",
        "figure.facecolor": "white", "axes.facecolor": "white",
    })
    series = (("Shifted logistic", logistic, "#1465b4", "-"),
              ("Rational saturation", rational, "#b44b18", (0, (6, 3))))
    figure, axes = plt.subplots(1, 2, figsize=(14, 7.2), gridspec_kw={"width_ratios": [1.65, 1]})
    figure.subplots_adjust(left=0.075, right=0.975, bottom=0.16, top=0.72, wspace=0.24)
    figure.suptitle("Town population and infected count", x=0.075, y=0.975, ha="left", fontsize=22)
    figure.text(0.075, 0.91, "Proposed curves · minimum 10 · ceiling 180 · both pass through (50, 40)", fontsize=15)
    for axis, maximum, y_maximum, title in zip(
        axes, (1250, 200), (195, 140), ("Full Chernarus Redux range", "Detail: 0-200 citizens")
    ):
        populations = [maximum * i / 1600 for i in range(1601)]
        for label, function, color, style in series:
            axis.plot(populations, [function(p) for p in populations], label=label, color=color, linestyle=style, linewidth=2.7)
        axis.axhline(MINIMUM, color="#98a2b3", linewidth=1, linestyle=":", zorder=0)
        axis.set(xlim=(0, maximum), ylim=(0, y_maximum), xlabel="Town population, P (citizens)", ylabel="Infected count, Z(P)")
        axis.set_title(title, loc="left", pad=15)
        axis.set_axisbelow(True)
        axis.grid(True, color="#e5e7eb", linewidth=0.8)
    axes[0].axhline(CEILING, color="#98a2b3", linewidth=1.2, linestyle=":", zorder=0)
    axes[0].text(580, 184, "180 ceiling", fontsize=13, color="#667085")
    axes[0].text(940, 14, "10 minimum", fontsize=13, color="#667085")
    chernogorsk = next(t["population"] for t in towns if t["source_key"] == "city_Chernogorsk")
    for _, function, color, _ in series:
        axes[0].scatter([chernogorsk], [function(chernogorsk)], color=color, s=38, zorder=5)
        axes[0].annotate(str(rounded_count(function(chernogorsk))), (chernogorsk, function(chernogorsk)),
                         xytext=(-16, -25), textcoords="offset points", fontsize=14)
    axes[0].annotate(f"Chernogorsk\nP = {chernogorsk:,}", (chernogorsk, rational(chernogorsk)), xytext=(760, 95),
                     arrowprops={"arrowstyle": "-", "color": "#98a2b3"}, fontsize=14)
    axes[1].scatter([50], [40], color="#344054", s=42, zorder=5)
    axes[1].annotate("50 citizens\n40 infected", (50, 40), xytext=(13, 98),
                     arrowprops={"arrowstyle": "-", "color": "#98a2b3"}, fontsize=14)
    axes[0].set_xticks([0, 250, 500, 750, 1000, 1250])
    axes[0].set_yticks([0, 30, 60, 90, 120, 150, 180])
    axes[1].set_xticks([0, 50, 100, 150, 200])
    axes[1].set_yticks([0, 20, 40, 60, 80, 100, 120, 140])
    handles, labels = axes[0].get_legend_handles_labels()
    figure.legend(handles, labels, loc="upper left", bbox_to_anchor=(0.075, 0.86), ncol=2, frameon=False, fontsize=15)
    figure.text(0.075, 0.035, "Lines show continuous targets; displayed town counts round to whole infected.", fontsize=13)
    save_plot(figure, "town-density-curves")
    plt.close(figure)

    # Companion plot makes the user's declining per-citizen requirement visible.
    figure, axis = plt.subplots(figsize=(11, 6.4))
    figure.subplots_adjust(left=0.10, right=0.97, bottom=0.16, top=0.82)
    populations = [10 + i * 1240 / 1600 for i in range(1601)]
    for label, function, color, style in series:
        axis.plot(populations, [function(p) / p for p in populations], label=label, color=color, linestyle=style, linewidth=2.7)
    axis.plot(populations, [CEILING / p for p in populations], color="#667085", linestyle=":", linewidth=1.5, label="Upper bound from the 180 cap")
    axis.axhline(0.2, color="#98a2b3", linewidth=1, linestyle="--")
    axis.axvline(900, color="#98a2b3", linewidth=1, linestyle="--")
    axis.text(905, 0.98, "P > 900:\n0.2 per citizen\nexceeds 180", fontsize=13, va="top")
    axis.set(xlim=(0, 1250), ylim=(0, 1.05), xlabel="Town population, P (citizens)", ylabel="Infected per citizen, Z(P) / P")
    axis.set_axisbelow(True)
    axis.grid(True, color="#e5e7eb", linewidth=0.8)
    axis.legend(loc="upper right", bbox_to_anchor=(0.72, 1.01), frameon=False, fontsize=13)
    figure.suptitle("Density falls as town population grows", x=0.10, y=0.96, ha="left", fontsize=20)
    figure.text(0.10, 0.03, "The minimum of 10 exceeds one infected per citizen only below P = 10; Redux's smallest listed town has P = 23.", fontsize=11)
    save_plot(figure, "town-density-ratios")
    plt.close(figure)


def main() -> None:
    with (OUTPUT / "chernarus-redux-populations.csv").open(newline="", encoding="utf-8") as handle:
        towns = [{"source_key": r["source_key"], "population": int(r["population"])} for r in csv.DictReader(handle)]
    if not towns or len({r["source_key"] for r in towns}) != len(towns):
        raise ValueError("Missing or duplicate town population records")
    rows = []
    for town in sorted(towns, key=lambda r: (r["population"], r["source_key"])):
        population = town["population"]
        if population <= 0:
            raise ValueError("Town comparison requires positive population")
        left, right = logistic(population), rational(population)
        rows.append({**town, "logistic_target": round(left, 6), "logistic_count": rounded_count(left),
                     "logistic_per_citizen": round(left / population, 6),
                     "rational_target": round(right, 6), "rational_count": rounded_count(right),
                     "rational_per_citizen": round(right / population, 6)})
    with (OUTPUT / "town-density-comparison.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    checks = validate()
    parameters = {
        "status": "proposal_only_not_applied_to_gameplay", "minimum": MINIMUM, "ceiling": CEILING,
        "proposed_calibration": {"population": ANCHOR_POPULATION, "infected": ANCHOR_INFECTED},
        "logistic_k": K, "rational_h": H,
        "logistic_leaves_floor_at_population": math.log((CEILING + MINIMUM) / (CEILING - MINIMUM)) / K,
        "rational_leaves_floor_at_population": MINIMUM * H / (CEILING - MINIMUM),
        "integer_rounding": "nearest whole number, positive halves upward, bounded to 10..180",
        "population_records": len(towns), "population_range": [min(r["population"] for r in towns), max(r["population"] for r in towns)],
        "validation_grid": {"minimum_population": 0, "maximum_population": 10000, "step": 0.1},
        "checks": checks, "matplotlib_version": matplotlib.__version__,
    }
    (OUTPUT / "model-parameters.json").write_text(json.dumps(parameters, indent=2) + "\n", encoding="utf-8")
    draw_curves(towns)
    print(json.dumps({"checks_passed": len(checks), "towns": len(towns), "k": K, "h": H,
                      "selected_towns": [r for r in rows if r["source_key"] in (
                          "vill_Olsha", "vill_Tulga", "vill_Dubrovka", "vill_Pavlovo", "city_Zelenogorsk", "city_Elektrozavodsk", "city_Chernogorsk")]}))


if __name__ == "__main__":
    main()
