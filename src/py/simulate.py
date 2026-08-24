import numpy as np
import pandas as pd

HEDGES_G = 0.68
SEED = 12312421


def simulate_stroop(n: int, seed: int = SEED, ms_mean: float = 600, ms_sd: float = 100,
                    g: float = HEDGES_G, con_label: str = "control",
                    exp_label: str = "depressed") -> pd.DataFrame:
    """
    Simulate negative-stimulus reaction times for experimental and control groups.

    The default effect size is based on randomized designs in Epp et al. (2012).
    The control mean and pooled standard deviation are illustrative.

    Parameters
    ----------
    n : int
        Number of participants per group.
    seed : int, optional
        Random seed for reproducibility.
    ms_mean : float, optional
        Control-group mean reaction time in milliseconds.
    ms_sd : float, optional
        Pooled reaction-time standard deviation in milliseconds.
    g : float, optional
        Hedges' g estimate for the difference between groups.
    con_label : str, optional
        Label for the control group.
    exp_label : str, optional
        Label for the experimental group.

    Returns
    -------
    pd.DataFrame
        Simulated data with ``group`` and ``reaction_time_ms`` columns.
    """
    # Compute mean reaction time for the experimental group
    ms_mean_exp = ms_mean + g * ms_sd

    # Simulate data
    rng = np.random.default_rng(seed)
    df = pd.DataFrame({
        "group": np.repeat([con_label, exp_label], n),
        "reaction_time_ms": np.r_[rng.normal(ms_mean, ms_sd, n),
                                rng.normal(ms_mean_exp, ms_sd, n)]
    })
    return df
