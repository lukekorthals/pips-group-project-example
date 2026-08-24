from datetime import datetime
from pathlib import Path
from time import perf_counter
import tkinter as tk

import numpy as np
import pandas as pd


DATA_DIR = Path(__file__).resolve().parents[2] / "data"
COLORS = {"red": "#d62728", "green": "#2ca02c", "blue": "#1f77b4", "yellow": "#bcbd22"}
KEYS = {color[0]: color for color in COLORS}
COLUMNS = ["participant_id", "trial", "word", "ink_color", "congruent", "response", "correct", "rt_ms"]


def run_stroop(participant_id: str, n_trials: int = 20, seed: int | None = None) -> pd.DataFrame:
    """
    Run a small Stroop task and save one participant file.

    Parameters
    ----------
    participant_id : str
        Anonymous participant label used in the data and filename.
    n_trials : int, optional
        Number of trials to present.
    seed : int or None, optional
        Random seed for reproducible trial generation.

    Returns
    -------
    pd.DataFrame
        Trial-level responses, accuracy, and reaction times.
    """
    participant_id = "".join(c for c in participant_id if c.isalnum() or c in "-_")
    if not participant_id:
        raise ValueError("participant_id is required")

    rng = np.random.default_rng(seed)
    names = np.array(list(COLORS))
    ink_colors = rng.choice(names, n_trials)
    congruent = np.arange(n_trials) < n_trials // 2
    rng.shuffle(congruent)
    words = [ink if same else rng.choice(names[names != ink]) for ink, same in zip(ink_colors, congruent)]
    trials = list(zip(words, ink_colors, congruent))

    root = tk.Tk()
    root.title("Stroop task")
    label = tk.Label(root, text="Name the INK COLOR\nR = red, G = green, B = blue, Y = yellow\n\nPress space to start", font=("Arial", 28))
    label.pack(padx=80, pady=80)
    rows, trial, started, accepting, onset = [], 0, False, False, 0.0

    def show_trial():
        nonlocal accepting, onset
        word, ink, _ = trials[trial]
        label.config(text=word.upper(), fg=COLORS[ink])
        onset, accepting = perf_counter(), True

    def respond(event):
        nonlocal trial, started, accepting
        if not started and event.keysym == "space":
            started = True
            show_trial()
        if not accepting or event.char.lower() not in KEYS:
            return
        accepting = False
        word, ink, same = trials[trial]
        response = KEYS[event.char.lower()]
        rows.append([participant_id, trial + 1, word, ink, same, response, response == ink, round((perf_counter() - onset) * 1000)])
        trial += 1
        if trial == n_trials:
            root.after_idle(root.quit)
        else:
            label.config(text="+", fg="black")
            root.after(250, show_trial)

    root.bind("<Key>", respond)
    root.protocol("WM_DELETE_WINDOW", root.quit)
    try:
        root.mainloop()
    finally:
        root.destroy()

    data = pd.DataFrame(rows, columns=COLUMNS)
    DATA_DIR.mkdir(exist_ok=True)
    filename = DATA_DIR / f"experiment_{participant_id}_{datetime.now():%Y%m%d-%H%M%S}.csv"
    data.to_csv(filename, index=False)
    return data


def load_experiment_data() -> pd.DataFrame:
    """
    Load and combine all participant experiment files.

    Returns
    -------
    pd.DataFrame
        Combined trial-level data, or an empty table when no files exist.
    """
    files = sorted(DATA_DIR.glob("experiment_*.csv"))
    return pd.concat((pd.read_csv(file) for file in files), ignore_index=True) if files else pd.DataFrame(columns=COLUMNS)


if __name__ == "__main__":
    run_stroop(input("Participant ID: "))
