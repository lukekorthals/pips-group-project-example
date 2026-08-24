from dash import Dash, Input, Output, dcc, html
import numpy as np
import plotly.express as px

from .simulate import HEDGES_G, simulate_stroop
from .analysis import (
    stroop_bayes_design,
    stroop_bayes_probability,
    stroop_bayes_t_test,
    stroop_power,
    stroop_t_test,
)


app = Dash(__name__)

app.layout = html.Div([
    html.H2("Stroop simulation and design analysis"),
    html.P(
        "Use the sample controls to simulate reaction times and inspect the group distributions. "
        "Then choose the design criteria to compare frequentist power with the probability of reaching a Bayes-factor threshold."
    ),

    html.H3("Sample characteristics"),
    html.Div([
        html.Div([html.Label("Participants per group"), dcc.Slider(10, 200, 10, value=50, id="n")]),
        html.Div([html.Label("Control mean (ms)"), dcc.Slider(400, 800, 25, value=600, id="mean")]),
        html.Div([html.Label("Pooled SD (ms)"), dcc.Slider(25, 200, 25, value=100, id="sd")]),
        html.Div([html.Label("Hedges' g"), dcc.Slider(0.1, 1.5, 0.01, value=HEDGES_G, id="g")]),
    ], style={"display": "grid", "gridTemplateColumns": "repeat(2, minmax(0, 1fr))", "gap": "24px"}),

    dcc.Graph(id="distribution", style={"width": "100%"}),
    html.P(id="results"),

    html.H3("Design criteria"),
    html.Div([
        html.Div([html.Label("Target probability"), dcc.Slider(0.6, 0.95, 0.05, value=0.8, id="desired-power")]),
        html.Div([html.Label("Frequentist alpha"), dcc.Slider(0.01, 0.10, 0.01, value=0.05, id="alpha")]),
        html.Div([
            html.Label("Bayes factor threshold"),
            dcc.RadioItems([
                {"label": "BF10 ≥ 3", "value": 3},
                {"label": "BF10 ≥ 10", "value": 10},
                {"label": "BF10 ≥ 30", "value": 30},
            ], 10, inline=True, id="target-bf"),
        ]),
    ], style={"display": "grid", "gridTemplateColumns": "repeat(3, minmax(0, 1fr))", "gap": "24px"}),

    html.Div([
        dcc.Graph(id="power", style={"width": "50%", "minWidth": "0"}),
        dcc.Graph(id="bayes-design", style={"width": "50%", "minWidth": "0"}),
    ], style={"display": "flex"}),

    html.H3("Required sample size"),
    html.P(id="power-comment"),
    html.P(id="bayes-comment")

], style={"maxWidth": "1200px", "margin": "auto"})


@app.callback(
    Output("results", "children"),
    Output("distribution", "figure"),
    Output("power", "figure"),
    Output("bayes-design", "figure"),
    Output("power-comment", "children"),
    Output("bayes-comment", "children"),
    Input("n", "value"),
    Input("mean", "value"),
    Input("sd", "value"),
    Input("g", "value"),
    Input("desired-power", "value"),
    Input("alpha", "value"),
    Input("target-bf", "value")
)
def update(n, mean, sd, g, desired_probability, alpha, target_bf):
    """
    Update the simulation, design plots, and sample-size summaries.

    Parameters
    ----------
    n : int
        Participants per group.
    mean : float
        Control-group mean reaction time.
    sd : float
        Pooled reaction-time standard deviation.
    g : float
        Standardized effect estimated by Hedges' g.
    desired_probability : float
        Target power and BF design probability.
    alpha : float
        Frequentist significance level.
    target_bf : float
        BF10 evidence threshold.

    Returns
    -------
    tuple
        Result text, three figures, and two sample-size summaries.
    """
    df = simulate_stroop(n=n, ms_mean=mean, ms_sd=sd, g=g)

    t, p, _, _ = stroop_t_test(df, silent=True)
    bf10, interpretation = stroop_bayes_t_test(df, silent=True)
    current_power, required_n = stroop_power(n, g, desired_probability, alpha)
    current_bayes, required_bayes_n = stroop_bayes_design(n, g, desired_probability, target_bf)

    distribution = px.histogram(
        df,
        x="reaction_time_ms",
        color="group",
        barmode="overlay",
        opacity=0.6,
        nbins=30,
        title="Simulated reaction times",
        labels={"reaction_time_ms": "Reaction time (ms)", "group": "Group"},
    )

    ns = np.arange(10, 201)
    powers = [stroop_power(x, g, desired_probability, alpha)[0] for x in ns]
    bayes_probabilities = [stroop_bayes_probability(x, g, target_bf) for x in ns]

    power_plot = px.line(
        x=ns,
        y=powers,
        labels={
            "x": "Participants per group",
            "y": "Power"
        },
        title="Frequentist power",
    )

    power_plot.add_hline(y=desired_probability, line_dash="dash")
    power_plot.add_vline(x=n, line_dash="dash")
    power_plot.add_scatter(
        x=[n],
        y=[current_power],
        mode="markers",
        name="Current design"
    )

    bayes_plot = px.line(
        x=ns,
        y=bayes_probabilities,
        labels={"x": "Participants per group", "y": f"P(BF10 ≥ {target_bf})"},
        title="Bayes-factor design",
    )
    bayes_plot.add_hline(y=desired_probability, line_dash="dash")
    bayes_plot.add_vline(x=n, line_dash="dash")
    bayes_plot.add_scatter(x=[n], y=[current_bayes], mode="markers", name="Current design")

    if current_power >= desired_probability:
        power_comment = (
            f"Frequentist: power {current_power:.2f} ≥ {desired_probability:.2f}. "
            f"{required_n} participants per group are required."
        )
    else:
        missing = required_n - n
        power_comment = (
            f"Frequentist: power {current_power:.2f} < {desired_probability:.2f}. "
            f"{required_n} participants per group are required; add {missing} per group ({2 * missing} total)."
        )

    bayes_comment = (
        f"Bayesian: P(BF10 ≥ {target_bf}) = {current_bayes:.2f}. "
        f"{required_bayes_n} participants per group are required for probability {desired_probability:.2f}."
    )

    return (
        f"t = {t:.2f}, p = {p:.3f}; BF10 = {bf10:.2f}: {interpretation}.",
        distribution,
        power_plot,
        bayes_plot,
        power_comment,
        bayes_comment
    )


if __name__ == "__main__":
    app.run(debug=False)
