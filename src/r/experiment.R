invisible(lapply(c("later", "shiny"), function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package, repos = "https://cloud.r-project.org")
  }
}))


DATA_DIR <- "data"
COLORS <- c(red = "#d62728", green = "#2ca02c", blue = "#1f77b4", yellow = "#bcbd22")
KEYS <- c(r = "red", g = "green", b = "blue", y = "yellow")
COLUMNS <- c(
  "participant_id", "trial", "word", "ink_color", "congruent",
  "response", "correct", "rt_ms"
)


.make_stroop_trials <- function(n_trials, seed) {
  if (!is.null(seed)) set.seed(seed)
  colours <- names(COLORS)
  ink <- sample(colours, n_trials, replace = TRUE)
  congruent <- sample(c(rep(TRUE, n_trials %/% 2), rep(FALSE, n_trials - n_trials %/% 2)))
  word <- mapply(
    function(ink_colour, same) {
      if (same) ink_colour else sample(setdiff(colours, ink_colour), 1)
    },
    ink, congruent, USE.NAMES = FALSE
  )
  data.frame(word, ink_color = ink, congruent)
}


.bind_stroop_rows <- function(rows) {
  if (length(rows)) {
    do.call(rbind, rows)
  } else {
    setNames(data.frame(matrix(ncol = length(COLUMNS), nrow = 0)), COLUMNS)
  }
}


#' Run a small Stroop task and save one participant file
#'
#' @param participant_id Anonymous participant label used in the data and filename.
#' @param n_trials Number of trials to present.
#' @param seed Optional random seed for reproducible trial generation.
#'
#' @return A data frame with trial-level responses, accuracy, and reaction times.
run_stroop <- function(participant_id, n_trials = 20, seed = NULL) {
  participant_id <- gsub("[^A-Za-z0-9_-]", "", participant_id)
  if (!nzchar(participant_id)) stop("participant_id is required")
  trials <- .make_stroop_trials(n_trials, seed)

  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML(
        ".stroop {text-align:center; margin:12vh auto; font-family:Arial; font-size:48px;}"
      )),
      shiny::tags$script(shiny::HTML(
        paste0(
          "document.addEventListener('keydown', function(e) {",
          "Shiny.setInputValue('key', e.key.toLowerCase(), {priority: 'event'});",
          "});",
          "Shiny.addCustomMessageHandler('close', function(x) { window.close(); });"
        )
      ))
    ),
    shiny::div(class = "stroop", shiny::uiOutput("task"))
  )

  server <- function(input, output, session) {
    state <- shiny::reactiveValues(
      started = FALSE, accepting = FALSE, finished = FALSE,
      trial = 1L, text = "", colour = "black", onset = 0, rows = list()
    )

    show_trial <- function() {
      trial <- shiny::isolate(state$trial)
      state$text <- toupper(trials$word[trial])
      state$colour <- COLORS[[trials$ink_color[trial]]]
      state$onset <- proc.time()[["elapsed"]]
      state$accepting <- TRUE
    }

    output$task <- shiny::renderUI({
      if (!state$started) {
        return(shiny::tagList(
          shiny::h3("Name the INK COLOR"),
          shiny::p("R = red, G = green, B = blue, Y = yellow"),
          shiny::actionButton("start", "Start")
        ))
      }
      shiny::h1(style = paste("color:", state$colour), state$text)
    })

    shiny::observeEvent(input$start, {
      state$started <- TRUE
      show_trial()
    }, once = TRUE)

    shiny::observeEvent(input$key, {
      key <- substr(input$key, 1, 1)
      if (!state$accepting || !key %in% names(KEYS)) return()
      state$accepting <- FALSE
      response <- unname(KEYS[[key]])
      trial <- trials[state$trial, ]
      state$rows[[length(state$rows) + 1L]] <- data.frame(
        participant_id = participant_id,
        trial = state$trial,
        word = trial$word,
        ink_color = trial$ink_color,
        congruent = trial$congruent,
        response = response,
        correct = response == trial$ink_color,
        rt_ms = round(1000 * (proc.time()[["elapsed"]] - state$onset))
      )

      if (state$trial == n_trials) {
        state$finished <- TRUE
        state$text <- "Done"
        state$colour <- "black"
        data <- .bind_stroop_rows(state$rows)
        session$sendCustomMessage("close", list())
        later::later(function() shiny::stopApp(data), 0.2)
      } else {
        state$text <- "+"
        state$colour <- "black"
        state$trial <- state$trial + 1L
        later::later(show_trial, 0.25)
      }
    }, ignoreInit = TRUE)

    session$onSessionEnded(function() {
      if (!state$finished) shiny::stopApp(.bind_stroop_rows(state$rows))
    })
  }

  data <- shiny::runApp(shiny::shinyApp(ui, server), launch.browser = TRUE)
  dir.create(DATA_DIR, showWarnings = FALSE)
  filename <- file.path(
    DATA_DIR,
    sprintf("experiment_%s_%s.csv", participant_id, format(Sys.time(), "%Y%m%d-%H%M%S"))
  )
  write.csv(data, filename, row.names = FALSE)
  data
}


#' Load and combine all participant experiment files
#'
#' @return Combined trial-level data, or an empty data frame when no files exist.
load_experiment_data <- function() {
  files <- sort(list.files(DATA_DIR, "^experiment_.*\\.csv$", full.names = TRUE))
  if (!length(files)) return(setNames(data.frame(matrix(ncol = length(COLUMNS), nrow = 0)), COLUMNS))
  data <- do.call(rbind, lapply(files, read.csv))
  data$congruent <- tolower(as.character(data$congruent)) == "true"
  data$correct <- tolower(as.character(data$correct)) == "true"
  data
}


if (sys.nframe() == 0L) run_stroop(readline("Participant ID: "))
