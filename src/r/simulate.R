HEDGES_G <- 0.68
SEED <- 12312421


#' Simulate negative-stimulus reaction times for two groups
#'
#' The default effect size is based on randomised designs in Epp et al. (2012).
#' The control mean and pooled standard deviation are illustrative.
#'
#' @param n Number of participants per group.
#' @param seed Random seed for reproducibility.
#' @param ms_mean Control-group mean reaction time in milliseconds.
#' @param ms_sd Pooled reaction-time standard deviation in milliseconds.
#' @param g Hedges' g estimate for the difference between groups.
#' @param con_label Label for the control group.
#' @param exp_label Label for the experimental group.
#'
#' @return A data frame with `group` and `reaction_time_ms` columns.
simulate_stroop <- function(n, seed = SEED, ms_mean = 600, ms_sd = 100,
                            g = HEDGES_G, con_label = "control",
                            exp_label = "depressed") {
  set.seed(seed)
  ms_mean_exp <- ms_mean + g * ms_sd

  data.frame(
    group = rep(c(con_label, exp_label), each = n),
    reaction_time_ms = c(
      rnorm(n, ms_mean, ms_sd),
      rnorm(n, ms_mean_exp, ms_sd)
    )
  )
}
