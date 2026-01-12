import random
import math
import matplotlib.pyplot as plt

# ----------------------------
# Configuration
# ----------------------------
SEED = 42
POINTS_PER_CLUSTER = 60      # "a lot more data" -> increase this (e.g., 200)
LABEL_EVERY_N = 12           # label every Nth point to keep the chart readable
DRAW_ARROWS = False          # set True to draw arrows from origin (can get busy)
JITTER = 0.8                 # spread within each cluster

random.seed(SEED)

# ----------------------------
# Create synthetic "embedding-like" vectors
# Each cluster has a center point, and we sample around it.
# ----------------------------
clusters = [
    # name, (cx, cy), example words for nicer labels
    ("Animals",   ( 2.5,  3.2), ["cat", "dog", "fox", "horse", "lion", "tiger", "mouse", "wolf"]),
    ("Vehicles",  (-3.2, -2.4), ["car", "truck", "bike", "train", "plane", "boat", "scooter", "bus"]),
    ("Tech",      ( 3.6, -2.0), ["server", "cloud", "api", "python", "docker", "kubernetes", "azure", "m365"]),
    ("Food",      (-2.2,  3.4), ["pizza", "pasta", "salad", "bread", "soup", "coffee", "tea", "burger"]),
    ("Places",    ( 0.5, -3.6), ["london", "paris", "tokyo", "nyc", "sydney", "berlin", "madrid", "rome"]),
]

def sample_point(cx, cy, jitter=1.0):
    # sample around the center with a bit of random noise
    x = random.gauss(cx, jitter)
    y = random.gauss(cy, jitter)
    return x, y

# Build dataset: list of dicts {label, x, y, cluster}
data = []
for cluster_name, (cx, cy), seed_labels in clusters:
    # Use provided seed labels first (nice human labels)
    for w in seed_labels:
        x, y = sample_point(cx, cy, JITTER)
        data.append({"label": w, "x": x, "y": y, "cluster": cluster_name})

    # Then generate a bunch more synthetic points (keeps the chart dense)
    remaining = POINTS_PER_CLUSTER - len(seed_labels)
    for i in range(max(0, remaining)):
        x, y = sample_point(cx, cy, JITTER)
        data.append({"label": f"{cluster_name[:3].lower()}_{i:03d}", "x": x, "y": y, "cluster": cluster_name})

# ----------------------------
# Plotting
# ----------------------------
plt.figure(figsize=(10, 8))

# Group points by cluster for plotting
cluster_to_points = {}
for row in data:
    cluster_to_points.setdefault(row["cluster"], []).append(row)

for cluster_name, rows in cluster_to_points.items():
    xs = [r["x"] for r in rows]
    ys = [r["y"] for r in rows]
    plt.scatter(xs, ys, label=cluster_name, alpha=0.8)

    # Optionally draw arrows from origin (can get visually noisy with lots of points)
    if DRAW_ARROWS:
        for r in rows:
            plt.arrow(0, 0, r["x"], r["y"], length_includes_head=True, head_width=0.08, alpha=0.12)

# Label a subset so it stays readable
for idx, r in enumerate(data):
    if idx % LABEL_EVERY_N == 0:
        plt.text(r["x"], r["y"], r["label"], fontsize=8)

# Axes and grid
plt.axhline(0, linewidth=1)
plt.axvline(0, linewidth=1)
plt.grid(True, alpha=0.25)
plt.xlabel("Weight / Feature 1 (2D simplification)")
plt.ylabel("Weight / Feature 2 (2D simplification)")
plt.title("Vectors on an X–Y Plane (Synthetic 'Embedding-like' Clusters)")
plt.legend()
plt.tight_layout()

# Either show or save
plt.show()
# plt.savefig("vectors.png", dpi=200)
