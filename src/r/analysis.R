invisible(lapply(c("BayesFactor", "ggplot2"), function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package, repos = "https://cloud.r-project.org")
  }
}))


.validate_stroop_df <- function(df) {
  if (!all(c("group", "reaction_time_ms") %in% names(df))) {
    stop("df must contain group and reaction_time_ms columns")
  }
}


.get_groups <- function(df, con_label, exp_label) {
  .validate_stroop_df(df)
  control <- df$reaction_time_ms[df$group == con_label]
  experimental <- df$reaction_time_ms[df$group == exp_label]
  if (!length(control) || !length(experimental)) {
    stop("con_label and exp_label must match values in the group column")
  }
  list(control = control, experimental = experimental)
}


#' Plot reaction-time distributions by group
#'
#' @param df Simulated data with `group` and `reaction_time_ms` columns.
#'
#' @return A ggplot object.
stroop_histplot <- function(df) {
  .validate_stroop_df(df)
  ggplot2::ggplot(df, ggplot2::aes(reaction_time_ms, fill = group, colour = group)) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins = 30, alpha = 0.35, position = "identity"
    ) +
    ggplot2::geom_density(alpha = 0.15) +
    ggplot2::labs(x = "Reaction time (ms)", y = "Density", fill = "Group", colour = "Group") +
    ggplot2::theme_minimal()
}


#' Compare experimental and control reaction times with Welch's t-test
#'
#' @param df Simulated data containing two groups.
#' @param alpha Significance level; the confidence level is `1 - alpha`.
#' @param silent Suppress the formatted result when `TRUE`.
#' @param con_label Label for the control group.
#' @param exp_label Label for the experimental group.
#'
#' @return A list with the test statistic, p-value, confidence interval, and
#'   significance decision.
stroop_t_test <- function(df, alpha = 0.05, silent = FALSE,
                          con_label = "control", exp_label = "depressed") {
  groups <- .get_groups(df, con_label, exp_label)
  result <- t.test(
    groups$experimental, groups$control,
    var.equal = FALSE, conf.level = 1 - alpha
  )
  significant <- result$p.value < alpha
  conclusion <- if (significant) {
    "differed significantly in reaction time"
  } else {
    "did not differ significantly in reaction time"
  }

  if (!silent) {
    cat(sprintf(
      paste0(
        "%s (M = %.2f, SD = %.2f) and %s (M = %.2f, SD = %.2f) %s, ",
        "t(%.1f) = %.2f, p = %.3f, mean difference = %.2f ms, %.0f%% CI [%.2f, %.2f].\n"
      ),
      con_label, mean(groups$control), sd(groups$control),
      exp_label, mean(groups$experimental), sd(groups$experimental), conclusion,
      result$parameter, result$statistic, result$p.value,
      mean(groups$experimental) - mean(groups$control),
      100 * (1 - alpha), result$conf.int[1], result$conf.int[2]
    ))
  }

  list(
    statistic = unname(result$statistic),
    p_value = result$p.value,
    conf_int = unname(result$conf.int),
    significant = significant
  )
}


#' Interpret a Bayes factor using common evidence thresholds
#'
#' @param bf10 Evidence for a difference relative to no difference.
#'
#' @return A short evidence interpretation.
interpret_bf10 <- function(bf10) {
  if (bf10 >= 10) return("strong evidence for a difference")
  if (bf10 >= 3) return("moderate evidence for a difference")
  if (bf10 <= 0.1) return("strong evidence for no difference")
  if (bf10 <= 1 / 3) return("moderate evidence for no difference")
  "inconclusive evidence"
}


#' Compare groups with a two-sided JZS Bayesian t-test
#'
#' @param df Simulated data containing two groups.
#' @param silent Suppress the formatted result when `TRUE`.
#' @param con_label Label for the control group.
#' @param exp_label Label for the experimental group.
#'
#' @return A list containing BF10 and its evidence interpretation.
stroop_bayes_t_test <- function(df, silent = FALSE,
                                con_label = "control", exp_label = "depressed") {
  groups <- .get_groups(df, con_label, exp_label)
  test <- BayesFactor::ttestBF(
    x = groups$experimental, y = groups$control, rscale = "medium"
  )
  bf10 <- as.numeric(BayesFactor::extractBF(test, onlybf = TRUE))
  interpretation <- interpret_bf10(bf10)
  if (!silent) cat(sprintf("BF10 = %.2f: %s.\n", bf10, interpretation))
  list(bf10 = bf10, interpretation = interpretation)
}


.t_test_power <- function(n, g, alpha) {
  df <- 2 * n - 2
  cutoff <- qt(1 - alpha / 2, df)
  ncp <- g * sqrt(n / 2)
  pt(-cutoff, df, ncp) + pt(cutoff, df, ncp, lower.tail = FALSE)
}


.required_n <- function(probability, target) {
  low <- 2L
  high <- 4L
  while (probability(high) < target) {
    low <- high
    high <- high * 2L
  }
  while (low < high) {
    middle <- (low + high) %/% 2L
    if (probability(middle) >= target) high <- middle else low <- middle + 1L
  }
  low
}


#' Calculate independent-samples t-test power and required sample size
#'
#' @param n Participants per group in the current design.
#' @param g Standardised population effect estimated by Hedges' g.
#' @param desired_power Target statistical power.
#' @param alpha Significance level.
#'
#' @return A list with current power and required participants per group.
stroop_power <- function(n, g, desired_power = 0.8, alpha = 0.05) {
  probability <- function(x) .t_test_power(x, g, alpha)
  list(
    power = probability(n),
    required_n = .required_n(probability, desired_power)
  )
}


.bf10_from_t <- function(t, n) {
  as.numeric(BayesFactor::ttest.tstat(t, n, n, rscale = "medium", simple = TRUE))
}


.bf_cutoffs <- new.env(parent = emptyenv())


.bf_t_cutoff <- function(n, target_bf) {
  key <- paste(n, target_bf, sep = "-")
  if (!exists(key, envir = .bf_cutoffs, inherits = FALSE)) {
    cutoff <- uniroot(
      function(t) .bf10_from_t(t, n) - target_bf,
      c(0, 20)
    )$root
    assign(key, cutoff, envir = .bf_cutoffs)
  }
  get(key, envir = .bf_cutoffs, inherits = FALSE)
}


#' Calculate the probability that a study reaches a BF10 threshold
#'
#' @param n Participants per group.
#' @param g Standardised population effect estimated by Hedges' g.
#' @param target_bf BF10 evidence threshold.
#'
#' @return The probability of reaching the threshold.
stroop_bayes_probability <- function(n, g, target_bf = 10) {
  df <- 2 * n - 2
  cutoff <- .bf_t_cutoff(n, target_bf)
  ncp <- g * sqrt(n / 2)
  pt(-cutoff, df, ncp) + pt(cutoff, df, ncp, lower.tail = FALSE)
}


#' Calculate BF design probability and required sample size
#'
#' @param n Participants per group in the current design.
#' @param g Standardised population effect estimated by Hedges' g.
#' @param desired_probability Target probability of reaching `target_bf`.
#' @param target_bf BF10 evidence threshold.
#'
#' @return A list with current probability and required participants per group.
stroop_bayes_design <- function(n, g, desired_probability = 0.8, target_bf = 10) {
  probability <- function(x) stroop_bayes_probability(x, g, target_bf)
  list(
    probability = probability(n),
    required_n = .required_n(probability, desired_probability)
  )
}


#' Plot participant-level reaction times by congruency
#'
#' @param df Trial-level experiment data returned by `load_experiment_data()`.
#'
#' @return A ggplot object.
stroop_experiment_plot <- function(df) {
  means <- aggregate(
    rt_ms ~ participant_id + congruent,
    data = df[df$correct, ], FUN = mean
  )
  means$congruency <- factor(
    means$congruent,
    levels = c(TRUE, FALSE), labels = c("Congruent", "Incongruent")
  )

  ggplot2::ggplot(means, ggplot2::aes(congruency, rt_ms, group = 1)) +
    ggplot2::stat_summary(fun = mean, geom = "line") +
    ggplot2::stat_summary(fun = mean, geom = "point", size = 2) +
    ggplot2::stat_summary(fun.data = ggplot2::mean_se, geom = "errorbar", width = 0.1) +
    ggplot2::labs(x = "Congruency", y = "Mean reaction time (ms)") +
    ggplot2::theme_minimal()
}


#' Compare participant means with paired frequentist and Bayesian t-tests
#'
#' @param df Trial-level experiment data returned by `load_experiment_data()`.
#'
#' @return A list with the paired t statistic, p-value, and BF10.
stroop_experiment_t_test <- function(df) {
  means <- aggregate(
    rt_ms ~ participant_id + congruent,
    data = df[df$correct, ], FUN = mean
  )
  wide <- reshape(means, idvar = "participant_id", timevar = "congruent", direction = "wide")
  wide <- wide[complete.cases(wide), ]
  incongruent <- wide$rt_ms.FALSE
  congruent <- wide$rt_ms.TRUE

  result <- t.test(incongruent, congruent, paired = TRUE)
  test <- BayesFactor::ttestBF(x = incongruent, y = congruent, paired = TRUE)
  bf10 <- as.numeric(BayesFactor::extractBF(test, onlybf = TRUE))
  cat(sprintf(
    "t(%d) = %.2f, p = %.3f, BF10 = %.2f: %s.\n",
    length(incongruent) - 1, result$statistic, result$p.value,
    bf10, interpret_bf10(bf10)
  ))
  list(statistic = unname(result$statistic), p_value = result$p.value, bf10 = bf10)
}
