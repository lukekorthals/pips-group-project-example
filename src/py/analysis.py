import numpy as np
import pandas as pd
from functools import lru_cache
from pingouin import bayesfactor_ttest
from pprint import pprint
import seaborn as sns
from scipy import optimize, stats
from statsmodels.stats.power import TTestIndPower
from typing import Tuple



def _validate_stroop_df(df: pd.DataFrame) -> None:
    """Check that simulated data contain the required columns."""
    assert {"group", "reaction_time_ms"} <= set(df.columns)


def _get_groups(df: pd.DataFrame, con_label: str, exp_label: str) -> Tuple[pd.Series, pd.Series]:
    """Select the control and experimental reaction-time series."""
    _validate_stroop_df(df)
    control = df.loc[df["group"] == con_label, "reaction_time_ms"]
    experimental = df.loc[df["group"] == exp_label, "reaction_time_ms"]
    if control.empty or experimental.empty:
        raise ValueError("con_label and exp_label must match values in the group column")
    return control, experimental


def stroop_histplot(df: pd.DataFrame) -> None:
    """
    Plot reaction-time distributions by group.

    Parameters
    ----------
    df : pd.DataFrame
        Simulated data with ``group`` and ``reaction_time_ms`` columns.
    """
    _validate_stroop_df(df)
    sns.histplot(
        data=df,
        x="reaction_time_ms",
        hue="group",
        bins=30,
        kde=True,
    )


def stroop_t_test(df: pd.DataFrame, alpha: float = 0.05, silent: bool = False,
                  con_label: str = "control", exp_label: str = "depressed") -> Tuple[float, float, Tuple[float, float], bool]:
    """
    Compare experimental and control reaction times with Welch's t-test.

    Parameters
    ----------
    df : pd.DataFrame
        Simulated data containing two groups.
    alpha : float, optional
        Significance level; the confidence level is ``1 - alpha``.
    silent : bool, optional
        Suppress the formatted result when ``True``.
    con_label : str, optional
        Label for the control group.
    exp_label : str, optional
        Label for the experimental group.

    Returns
    -------
    tuple
        Test statistic, p-value, confidence interval, and significance decision.
    """
    control, experimental = _get_groups(df, con_label, exp_label)

    result = stats.ttest_ind(experimental, control, equal_var=False)
    ci = result.confidence_interval(confidence_level=1 - alpha)
    sig = result.pvalue < alpha

    if sig:
        conclusion = "differed significantly in reaction time"
    else:
        conclusion = "did not differ significantly in reaction time"

    if not silent:
        pprint(
            f"{con_label} (M = {control.mean():.2f}, SD = {control.std(ddof=1):.2f}) "
            f"and {exp_label} (M = {experimental.mean():.2f}, "
            f"SD = {experimental.std(ddof=1):.2f}) {conclusion}, "
            f"t({result.df:.1f}) = {result.statistic:.2f}, p = {result.pvalue:.3f}, "
            f"mean difference = {experimental.mean() - control.mean():.2f} ms, "
            f"95% CI [{ci.low:.2f}, {ci.high:.2f}]."
        )
    return result.statistic, result.pvalue, ci, sig


def interpret_bf10(bf10: float) -> str:
    """
    Interpret a Bayes factor using common evidence thresholds.

    Parameters
    ----------
    bf10 : float
        Evidence for a difference relative to no difference.

    Returns
    -------
    str
        Short evidence interpretation.
    """
    if bf10 >= 10:
        return "strong evidence for a difference"
    if bf10 >= 3:
        return "moderate evidence for a difference"
    if bf10 <= 0.1:
        return "strong evidence for no difference"
    if bf10 <= 1 / 3:
        return "moderate evidence for no difference"
    return "inconclusive evidence"


def stroop_bayes_t_test(df: pd.DataFrame, silent: bool = False,
                        con_label: str = "control", exp_label: str = "depressed") -> Tuple[float, str]:
    """
    Compare groups with a two-sided JZS Bayesian t-test.

    Parameters
    ----------
    df : pd.DataFrame
        Simulated data containing two groups.
    silent : bool, optional
        Suppress the formatted result when ``True``.
    con_label : str, optional
        Label for the control group.
    exp_label : str, optional
        Label for the experimental group.

    Returns
    -------
    tuple
        BF10 and its evidence interpretation.
    """
    control, experimental = _get_groups(df, con_label, exp_label)
    t = stats.ttest_ind(experimental, control, equal_var=True).statistic
    bf10 = float(bayesfactor_ttest(t, len(experimental), len(control)))
    interpretation = interpret_bf10(bf10)
    if not silent:
        pprint(f"BF10 = {bf10:.2f}: {interpretation}.")
    return bf10, interpretation


def stroop_power(n: int, g: float, desired_power: float = 0.8, alpha: float = 0.05) -> Tuple[float, int]:
    """
    Calculate independent-samples t-test power and required sample size.

    Parameters
    ----------
    n : int
        Participants per group in the current design.
    g : float
        Standardized population effect estimated by Hedges' g.
    desired_power : float, optional
        Target statistical power.
    alpha : float, optional
        Significance level.

    Returns
    -------
    tuple
        Current power and required participants per group.
    """
    analysis = TTestIndPower()

    current_power = analysis.power(
        effect_size=g,
        nobs1=n,
        alpha=alpha
    )

    required_n = int(np.ceil(
        analysis.solve_power(
            effect_size=g,
            power=desired_power,
            alpha=alpha
        )
    ))

    return current_power, required_n


@lru_cache
def _bf_t_cutoff(n: int, target_bf: float) -> float:
    """Find the absolute t-value that reaches a BF10 threshold."""
    return optimize.brentq(
        lambda t: bayesfactor_ttest(t, n, n) - target_bf,
        0,
        20,
    )


def stroop_bayes_probability(n: int, g: float, target_bf: float = 10) -> float:
    """
    Calculate the probability that a study reaches a BF10 threshold.

    Parameters
    ----------
    n : int
        Participants per group.
    g : float
        Standardized population effect estimated by Hedges' g.
    target_bf : float, optional
        BF10 evidence threshold.

    Returns
    -------
    float
        Probability of reaching the threshold.
    """
    df = 2 * n - 2
    cutoff = _bf_t_cutoff(n, target_bf)
    distribution = stats.nct(df, g * np.sqrt(n / 2))
    return distribution.cdf(-cutoff) + distribution.sf(cutoff)


def stroop_bayes_design(n: int, g: float, desired_probability: float = 0.8, target_bf: float = 10) -> Tuple[float, int]:
    """
    Calculate BF design probability and required sample size.

    Parameters
    ----------
    n : int
        Participants per group in the current design.
    g : float
        Standardized population effect estimated by Hedges' g.
    desired_probability : float, optional
        Target probability of reaching ``target_bf``.
    target_bf : float, optional
        BF10 evidence threshold.

    Returns
    -------
    tuple
        Current probability and required participants per group.
    """
    current = stroop_bayes_probability(n, g, target_bf)
    low, high = 2, 4
    while stroop_bayes_probability(high, g, target_bf) < desired_probability:
        low, high = high, high * 2
    while low < high:
        middle = (low + high) // 2
        if stroop_bayes_probability(middle, g, target_bf) >= desired_probability:
            high = middle
        else:
            low = middle + 1
    return current, low


def stroop_experiment_plot(df: pd.DataFrame) -> None:
    """
    Plot participant-level reaction times by congruency.

    Parameters
    ----------
    df : pd.DataFrame
        Trial-level experiment data returned by ``load_experiment_data``.
    """
    means = df.loc[df["correct"]].groupby(["participant_id", "congruent"], as_index=False)["rt_ms"].mean()
    sns.pointplot(data=means, x="congruent", y="rt_ms", errorbar="se")


def stroop_experiment_t_test(df: pd.DataFrame) -> Tuple[float, float, float]:
    """
    Compare participant means with paired frequentist and Bayesian t-tests.

    Parameters
    ----------
    df : pd.DataFrame
        Trial-level experiment data returned by ``load_experiment_data``.

    Returns
    -------
    tuple
        Paired t statistic, p-value, and BF10.
    """
    means = df.loc[df["correct"]].groupby(["participant_id", "congruent"])["rt_ms"].mean().unstack()
    result = stats.ttest_rel(means[False], means[True])
    bf10 = float(bayesfactor_ttest(result.statistic, len(means), paired=True))
    pprint(f"t({len(means) - 1}) = {result.statistic:.2f}, p = {result.pvalue:.3f}, "
           f"BF10 = {bf10:.2f}: {interpret_bf10(bf10)}.")
    return result.statistic, result.pvalue, bf10
