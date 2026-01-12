import matplotlib.pyplot as plt

vectors = {
    "cat": (2, 3),
    "dog": (2.2, 2.8),
    "car": (-1.5, -2)
}

for word, (x, y) in vectors.items():
    plt.arrow(0, 0, x, y, head_width=0.1)
    plt.text(x, y, word)

plt.axhline(0)
plt.axvline(0)
plt.xlabel("Weight 1")
plt.ylabel("Weight 2")
plt.title("Words as Vectors (Simplified)")
plt.show()
