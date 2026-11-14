"""Plot the approved 200-cap curve without recalibrating its growth constant.

The earlier 180-cap comparison remains a historical proposal. This script reads
the same pinned Redux populations and writes the selected curve and town counts.
Requires matplotlib; does not modify gameplay or the engine test fixture.
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

GROWTH = math.log(11 / 7) / 50


def target(population: float) -> float:
    return max(10.0, min(200.0, 400.0 / (1 + math.exp(-GROWTH * population)) - 200.0))


def count(population: float) -> int:
    return math.floor(target(population) + 0.5)


def main() -> None:
    with (OUTPUT / "chernarus-redux-populations.csv").open(newline="", encoding="utf-8") as handle:
        towns = [{"source_key": r["source_key"], "population": int(r["population"])} for r in csv.DictReader(handle)]
    rows = [{**t, "infected": count(t["population"])} for t in towns]
    with (OUTPUT / "selected-town-counts.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=["source_key", "population", "infected"])
        writer.writeheader()
        writer.writerows(rows)
    parameters = {
        "status": "owner_approved_and_implemented",
        "decision_date": "2026-11-14", "minimum": 10, "ceiling": 200,
        "numerator": 400, "subtracted_term": 200, "growth_constant": GROWTH,
        "growth_rule": "ln(11/7)/50, unchanged from the selected 180-cap proposal",
        "integer_rounding": "nearest whole actor, positive halves upward",
        "population_records": len(rows), "matplotlib_version": matplotlib.__version__,
    }
    (OUTPUT / "selected-model-parameters.json").write_text(json.dumps(parameters, indent=2) + "\n", encoding="utf-8")
    plt.rcParams.update({
        "font.family": "DejaVu Sans", "font.size": 15, "axes.labelsize": 15,
        "axes.titlesize": 17, "xtick.labelsize": 13, "ytick.labelsize": 13,
        "svg.fonttype": "none", "svg.hashsalt": "infection-selected-logistic-v1",
        "axes.spines.top": False, "axes.spines.right": False,
        "axes.edgecolor": "#697386", "axes.labelcolor": "#1d2939",
        "text.color": "#1d2939", "figure.facecolor": "white", "axes.facecolor": "white",
    })
    figure, axes = plt.subplots(1, 2, figsize=(14, 7.2), gridspec_kw={"width_ratios": [1.65, 1]})
    figure.subplots_adjust(left=0.075, right=0.975, bottom=0.16, top=0.70, wspace=0.24)
    figure.suptitle("Selected infected town population", x=0.075, y=0.975, ha="left", fontsize=22)
    figure.text(0.075, 0.91, "Approved logistic · minimum 10 · cap 200 · unchanged growth constant", fontsize=15)
    figure.text(0.075, 0.85, r"$Z(P)=\mathrm{round}\!\left(\max\!\left(10,\frac{400}{1+e^{-kP}}-200\right)\right)$"
                + f"     k = {GROWTH:.12f}", fontsize=16)
    for axis, maximum, y_maximum, title in zip(axes, (1250, 200), (215, 155),
                                             ("Full Chernarus Redux range", "Detail: 0–200 citizens")):
        populations = [maximum * i / 1600 for i in range(1601)]
        axis.plot(populations, [target(p) for p in populations], color="#1465b4", linewidth=2.8)
        visible = [r for r in rows if r["population"] <= maximum]
        axis.scatter([r["population"] for r in visible], [r["infected"] for r in visible],
                     s=22, color="#344054", alpha=0.65, zorder=3)
        axis.axhline(10, color="#98a2b3", linestyle=":", linewidth=1)
        axis.set(xlim=(0, maximum), ylim=(0, y_maximum), xlabel="Town population, P (citizens)", ylabel="Infected count, Z(P)")
        axis.set_title(title, loc="left", pad=15)
        axis.set_axisbelow(True)
        axis.grid(True, color="#e5e7eb", linewidth=0.8)
    axes[0].axhline(200, color="#98a2b3", linewidth=1.2, linestyle=":")
    axes[0].text(680, 204, "200 cap", fontsize=13, color="#667085")
    axes[0].set_xticks([0, 250, 500, 750, 1000, 1250])
    axes[0].set_yticks([0, 50, 100, 150, 200])
    axes[1].set_xticks([0, 50, 100, 150, 200])
    axes[1].set_yticks([0, 25, 50, 75, 100, 125, 150])
    labels = [
        (axes[0], "city_Chernogorsk", "Chernogorsk", (850, 125)),
        (axes[0], "city_Zelenogorsk", "Zelenogorsk", (420, 90)),
        (axes[1], "vill_Olsha", "Olsha", (10, 105)),
        (axes[1], "vill_Dubrovka", "Dubrovka", (115, 28)),
    ]
    for axis, key, name, text_position in labels:
        row = next(r for r in rows if r["source_key"] == key)
        p, z = row["population"], row["infected"]
        axis.annotate(f"{name}\n{p:,} citizens\n{z} infected", (p, z), xytext=text_position,
                      arrowprops={"arrowstyle": "-", "color": "#98a2b3"}, fontsize=12)
    figure.text(0.075, 0.035, "Blue: continuous target before rounding. Dots: all 49 configured Redux towns (Ultimate 12.4.2).", fontsize=13)
    figure.savefig(OUTPUT / "selected-logistic.png", dpi=180)
    vector = OUTPUT / "selected-logistic.svg"
    figure.savefig(vector, metadata={"Date": None})
    vector.write_text("\n".join(line.rstrip() for line in vector.read_text(encoding="utf-8").splitlines()) + "\n", encoding="utf-8")
    plt.close(figure)
    print(json.dumps({"towns": len(rows), "minimum": min(r["infected"] for r in rows), "maximum": max(r["infected"] for r in rows)}))


if __name__ == "__main__":
    main()
