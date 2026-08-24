invisible(lapply(c("ggplot2", "shiny"), function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package, repos = "https://cloud.r-project.org")
  }
}))


if (!exists("simulate_stroop")) source(file.path("src", "r", "simulate.R"))
if (!exists("stroop_power")) source(file.path("src", "r", "analysis.R"))


ui <- shiny::fluidPage(
  shiny::tags$head(shiny::tags$style(shiny::HTML(
    ".container-fluid {max-width: 1200px; margin: auto;}"
  ))),
  shiny::titlePanel("Stroop simulation and design analysis"),
  shiny::p(
    paste(
      "Use the sample controls to simulate reaction times and inspect the group distributions.",
      "Then choose the design criteria to compare frequentist power with the probability",
      "of reaching a Bayes-factor threshold."
    )
  ),

  shiny::h3("Sample characteristics"),
  shiny::fluidRow(
    shiny::column(6, shiny::sliderInput("n", "Participants per group", 10, 200, 50, step = 10)),
    shiny::column(6, shiny::sliderInput("mean", "Control mean (ms)", 400, 800, 600, step = 25))
  ),
  shiny::fluidRow(
    shiny::column(6, shiny::sliderInput("sd", "Pooled SD (ms)", 25, 200, 100, step = 25)),
    shiny::column(6, shiny::sliderInput("g", "Hedges' g", 0.1, 1.5, HEDGES_G, step = 0.01))
  ),
  shiny::plotOutput("distribution", height = "400px"),
  shiny::textOutput("results"),

  shiny::h3("Design criteria"),
  shiny::fluidRow(
    shiny::column(4, shiny::sliderInput("desired", "Target probability", 0.6, 0.95, 0.8, step = 0.05)),
    shiny::column(4, shiny::sliderInput("alpha", "Frequentist alpha", 0.01, 0.10, 0.05, step = 0.01)),
    shiny::column(4, shiny::radioButtons(
      "target_bf", "Bayes factor threshold",
      choices = c("BF10 >= 3" = 3, "BF10 >= 10" = 10, "BF10 >= 30" = 30),
      selected = 10, inline = TRUE
    ))
  ),
  shiny::fluidRow(
    shiny::column(6, shiny::plotOutput("power")),
    shiny::column(6, shiny::plotOutput("bayes_design"))
  ),

  shiny::h3("Required sample size"),
  shiny::textOutput("power_comment"),
  shiny::textOutput("bayes_comment")
)


server <- function(input, output, session) {
  simulated <- shiny::reactive({
    simulate_stroop(input$n, ms_mean = input$mean, ms_sd = input$sd, g = input$g)
  })

  tests <- shiny::reactive({
    list(
      frequentist = stroop_t_test(simulated(), silent = TRUE),
      bayesian = stroop_bayes_t_test(simulated(), silent = TRUE)
    )
  })

  designs <- shiny::reactive({
    target_bf <- as.numeric(input$target_bf)
    list(
      frequentist = stroop_power(input$n, input$g, input$desired, input$alpha),
      bayesian = stroop_bayes_design(input$n, input$g, input$desired, target_bf),
      target_bf = target_bf
    )
  })

  curves <- shiny::reactive({
    ns <- 10:200
    target_bf <- as.numeric(input$target_bf)
    data.frame(
      n = ns,
      power = vapply(ns, .t_test_power, numeric(1), g = input$g, alpha = input$alpha),
      bayes = vapply(ns, stroop_bayes_probability, numeric(1), g = input$g, target_bf = target_bf)
    )
  })

  output$distribution <- shiny::renderPlot(stroop_histplot(simulated()))

  output$results <- shiny::renderText({
    result <- tests()
    sprintf(
      "t = %.2f, p = %.3f; BF10 = %.2f: %s.",
      result$frequentist$statistic, result$frequentist$p_value,
      result$bayesian$bf10, result$bayesian$interpretation
    )
  })

  output$power <- shiny::renderPlot({
    ggplot2::ggplot(curves(), ggplot2::aes(n, power)) +
      ggplot2::geom_line() +
      ggplot2::geom_hline(yintercept = input$desired, linetype = "dashed") +
      ggplot2::geom_vline(xintercept = input$n, linetype = "dashed") +
      ggplot2::geom_point(
        data = data.frame(n = input$n, power = designs()$frequentist$power), size = 2
      ) +
      ggplot2::coord_cartesian(ylim = c(0, 1)) +
      ggplot2::labs(title = "Frequentist power", x = "Participants per group", y = "Power") +
      ggplot2::theme_minimal()
  })

  output$bayes_design <- shiny::renderPlot({
    ggplot2::ggplot(curves(), ggplot2::aes(n, bayes)) +
      ggplot2::geom_line() +
      ggplot2::geom_hline(yintercept = input$desired, linetype = "dashed") +
      ggplot2::geom_vline(xintercept = input$n, linetype = "dashed") +
      ggplot2::geom_point(
        data = data.frame(n = input$n, bayes = designs()$bayesian$probability), size = 2
      ) +
      ggplot2::coord_cartesian(ylim = c(0, 1)) +
      ggplot2::labs(
        title = "Bayes-factor design", x = "Participants per group",
        y = sprintf("P(BF10 >= %s)", designs()$target_bf)
      ) +
      ggplot2::theme_minimal()
  })

  output$power_comment <- shiny::renderText({
    result <- designs()$frequentist
    if (result$power >= input$desired) {
      sprintf(
        "Frequentist: power %.2f >= %.2f. %d participants per group are required.",
        result$power, input$desired, result$required_n
      )
    } else {
      missing <- result$required_n - input$n
      sprintf(
        paste0(
          "Frequentist: power %.2f < %.2f. %d participants per group are required; ",
          "add %d per group (%d total)."
        ),
        result$power, input$desired, result$required_n, missing, 2 * missing
      )
    }
  })

  output$bayes_comment <- shiny::renderText({
    result <- designs()$bayesian
    sprintf(
      "Bayesian: P(BF10 >= %s) = %.2f. %d participants per group are required for probability %.2f.",
      designs()$target_bf, result$probability, result$required_n, input$desired
    )
  })
}


power_analysis_app <- shiny::shinyApp(ui, server)


if (sys.nframe() == 0L) shiny::runApp(power_analysis_app)
