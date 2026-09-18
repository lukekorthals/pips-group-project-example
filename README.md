# PIPS group project example

This repository serves as a template for the group project in the Programming in Psychological Science (PIPS) course of the Research Master Psychology at the University of Amsterdam and explains the task, requirements, and assessment criteria. 

The following will explain what you are expected to do, and how we will assess your work. Further down starts an example for how you could document your own repository in a README. This repository also includes a bunch of working examples in Python and R, which serve as inspiration for your own project. 

>[!WARNING]
> Like your own projects, parts of this repository were written with AI assistance. Be mindful that this repository is not reflective of a perfect project that would automatically receive a 10. All of the code was written (or prompted) in about five hours, and it is shallower than what we expect from your group projects.

## Instructions for the group project

In groups of three, you will create a GitHub repository to which every group member contributes.

### Repository and deliverable

Your repository must contain:

1. A concise README with a brief project description, all dependencies and references, and instructions for using the repository. We will clone your repository and expect to run the main deliverable without errors.
2. A sensible folder structure, good organization of scripts, consistent naming conventions, and code that is easily understood.
3. One main deliverable which can be a jupyter notebook, R markdown file, Quarto document, or any other file that combines markdown and code. It must be called `main.<fileextension>` and should NOT contain all code. Instead, store supporting code and data in separate folders, import them into the main deliverable, only expose high level functions to users and provide concise explanations in markdown to guide users through the project.

### Project content

Your project must include:

1. An anylsis of psychological data, including at least one appropriate inferential statistical analysis and an informative plot supporting it. 
2. A data simulation OR an experiment script (e.g., PsychoPy) OR an app (e.g., Dash, Streamlit, or Shiny). One is required, multiple are a bonus.
3. A single `main.<filextension>` deliverable as described above. This file must combine code and markdown, and allow running the simulation, experiment, or app (1) and the analysis (2). 

**Main Deliverable:**

Structure it in a sensible way and include markdown explanations that will guide us through the project. Avoid verbose code in the main file, instead define functionality in separate scripts and import them. If you use publicly available data, replicate studies, or use references in any other way, make sure to cite them in the main deliverable (in-text citations and bibliography).

**Data Simulation, Experiment, or App:**

You only have to create one of these but feel free to create more if you want. Whatever you build must be useful and connected to the analysis of psychological data. For example, you could simulate realistic data to run your analysis on, or actually collect data using your experimental script from fellow students. An app could provide an interactive interface to load, visualise, and analyse data, or it could let the user simulate data based on different parameters or implement a power-analysis for an experiment. These are only suggestions and you are free to do whatever, as long as it is useful and connected to the analysis of psychological data. Make sure the app/ experiment/ simulation runs from the main deliverable. If you decide to go with an app which includes the analysis, your main deliverable could consist of only a single code block that runs the app and additional explanations. If you go with a simulation, your main deliverable may consist of many code blocks and markdown explanations, guiding the user through simulation and analysis. 

**Analysis of psychological data:**

It does not matter, what data you use or where it comes from (simulation, publicly available, collected amongst your fellow students, etc.), as long as it is psychological in the broader sense. This includes, experimental data, questionnaire data, eye-tracking, brain imaging data, etc. The analysis must include at least one appropriate inferential statistical analysis; for example, running regression models or statistical tests. These analysis do not have to be complex, but they should be motivated and appropriate for the data your are using. You should also include at least one informative plot that supports the analysis. 

> [!CAUTION]
> If you take the easiest route, running two lines of code to sample from arbitrary normal distributions and calling it a simulation without motivation based on the literature, create a simple scatter plot without making it visually appealing and helpful, running a simple regression and reporting the result without interpretation or discussion, you probably wont fail, but cannot expect to get a high grade either. Instead, try things, explore, and make it interesting! See how far you can push your creativity by working in a group and utilizing large language models. The four lines of code below would not be enough and you would fail, so dont do it 😉: 

```{R}
# We simulated x and y. They are not related.
# simulation
x <- rnorm(100)
y <- rnorm(100)
plot(x, y)
summary(lm(y ~ x)) # no relationship
```


### Division of responsibilities

Each group member should take primary responsibility for one of the three contributions:

1. The `main.<fileextension>` file, README, and greater project structure
2. The data simulation, experiment, or app
3. The statistical analyses and visualisations

**1. Project structure and main deliverable:**

You are responsible for making sure other people (including us graders) can clone your repository, install requirements and run the main deliverable without issues. You are also responseble for ensureing that the project, the README, and the main deliverable are well structured, clear, and easy to understand. 

> [!TIP]
> This responsibility has the least exposure to low-level code, but it is not a trivial task to ensure that everything works. This task is probably best assigned to a group member who excells at organization and project management but also has a good understanding of working directories, and how different files in different locations containing data and code interact and can be used effectively in the main deliverable. Looking at this example repository will likely help you a lot!

**2. Data simulation, experiment, or app:**

You are responsible for creating what might be the most complicated part of your project and requirements change dramatically depending on what you choose to do. With AI assistance you can build big things, but you need to make sure that what you build is useful, and actually does what it is supposed to do. Working on this project also means that you likely have to work with packages or tools that you have never used before such as shiny, dash, streamlit, psychopy, etc.

> [!TIP]
> This part of the project will likely utilize the most amount of code, most of which will be AI generated and some of which might get complicated or is at least new to you because it relies on packages you are unfamiliar with. This task is probably best assigned to a group member who is excited about working with new technologies and is most confident in their ability to understand LLM written code and get LLMs to do what they want.

**3. Statistical analyses and visualisations:**

You are responsible for the statistical analyses and visualisations. You need to make sure that the analyses are appropriate for the data you are using, and that the visualisations are informative and support your analyses. You also need to make sure that the analyses and visualisations are reproducible, and that they work when the repository is cloned into a new environment. 

> [!TIP]
> This responsibility requires moderate coding skills but also a good understanding of statistics and data visualisations. This task is probably best assigned to a group member who feels confident in working with tidyr, dplyr, ggplot2, and other data manipulation and visualisation packages as well as statistical analyses in R or Python. This might be the best task for a group member who just learned how to code, as the lectures covered data manipulation, visualisation and statistical analyses. But even so we ecourage you to see how far you can push your new skills with LLM assistance.

> [Caution]
> Even though each group member has a primary responsibility and your individual score will largely depend on your individual contributions, you are all responsible for the overall quality of your groups work and the largest part of your final grade depends on the overall quality of your repository and main deliverable. Make sure to communicate with your group members and help each other out if needed.

### Collaboration on GitHub

At minimum, every group member must:

- Create one pull request that is reviewed and merged by another group member.
- Review one pull request from another group member.

For an illustration of this workflow, inspect the [Python](https://github.com/lukekorthals/pips-group-project-example/pull/1) and [R](https://github.com/lukekorthals/pips-group-project-example/pull/2) pull requests for this repository.

## Assessment

You will receive both a group grade and an individual grade. The group grade reflects the overall quality of the repository and main deliverable and is most important for your final grade. The individual grade is mainly determined by the quality of your pull request, the review of another group member's pull request. Additionally, we adjust your grade based on the quality of the part of the project for which you were primarily responsible.

We will assess your project by:
1. cloning your repository and following instructions in the README to install requirements and work through the main deliverable
2. Running the main deliverable from top to bottom according to the instructions and explanations in the README and main deliverable
3. Inspecting your individual pull request and the review of another group member's pull request
4. (Optionally) inspecting individual files, in case the main deliverable does not run or seems to produce inconsistent results.
5. Finally, we assign a group grade (60%), and an individual grade (40%) between 1 and 10 based on the criteria below. Your final grade is the weighted average of both grades. 

### Criteria for group grade (60% of your final grade)
- **Minimal requirements:** 
  - The repository contains a README, and a main deliverable.
  - The project is related to the analysis of psychological data and includes at least one informative plot and one inferential statistical analysis.
  - The project includes a data simulation, experiment, or app. 
- **Ease of use:** 
  - The repository contains a concise README, making it easy to understand the project, clone the repository, and install requirements.
  - After cloning and installing the necessary dependencies, the main deliverable can be run without errors.
  - The repository is well-organized and easy to navigate.
  - The repository uses consistent formatting, style, and naming.
  - The main deliverable is well structured and easy to understand.
- **Relevance and usefulness:**
  - The project is useful for researchers, students, or practitioners in psychology. For example, because it provides a useful tool, a novel look at published data, or is a starting point for conducting research into a specific topic.
- **Consistency between code and documentation:**
  - The code does what the documentation says it does.


### Criteria for individual grades (40% of your final grade)

#### Code quality in the pull request
- **Readability:** Another student should be able to understand the code and its purpose without needing an extensive explanation from its author.
  - Files, notebooks, functions, and code blocks follow a clear and logical structure.
  - Formatting and style are consistent throughout the contribution.
  - Files, functions, variables, and arguments have concise, meaningful, and consistent names.
  - Comments explain important decisions or non-obvious logic. Unnecessary comments stating the obvious are avoided.
  - Public functions include concise documentation of their purpose, inputs, outputs, and relevant assumptions.
  - Repeated, unused, overly complicated, or unrelated code is avoided.
- **Functionality:** The contribution should perform its intended task reliably and integrate with the rest of the repository.
  - The code runs without errors and produces correct, interpretable outputs.
  - All functionality described in the pull request is implemented; there are no incomplete code paths or placeholder values.
  - Functions handle expected inputs and provide informative errors for invalid inputs or missing data.
  - Results are reproducible where appropriate, for example through fixed random seeds and recorded dependencies.
  - File paths, imports, saved outputs, and dependencies work when the repository is cloned into a new environment.
  - Important behaviour and edge cases have been checked using suitable tests or clearly described manual checks.
- **Adaptability:** The code should be reusable beyond the exact example on which it was developed.
  - Functions have a single, clear responsibility and related functionality is separated into appropriate modules.
  - Values that users may reasonably change are parameters rather than hidden or hard-coded assumptions.
  - Functions accept clearly defined inputs and return useful outputs instead of relying unnecessarily on global state.
  - Reasonable changes to labels, sample sizes, data, file locations, or analysis settings require little or no rewriting.
  - Repeated logic is placed in reusable functions, while unnecessary abstraction is avoided.
  - New functionality could be added without breaking existing interfaces or duplicating substantial amounts of code.
- **Revisions based on feedback:** The contribution should address the reviewer's comments and suggestions.
  - Bugs that were identified in the review were fixed.
  - Suggestions by the reviewer were considered and implemented where appropriate.
  - The PR was successfuly merged into main eventually.


#### Quality of the review on another group member's pull request
- **Expertise:** The review should demonstrate that the reviewer understands both the submitted code and its role in the project.
  - It accurately summarises the purpose, approach, inputs, outputs, and main changes in the pull request.
  - It checks the logic and important assumptions rather than commenting only on surface-level formatting.
  - It considers how the contribution interacts with the main deliverable and other project files.
  - It checks relevant outputs, error cases, and reproducibility claims where possible.
  - It identifies meaningful strengths, limitations, or trade-offs in the chosen approach.
- **Constructive feedback:** Feedback should help the author make a concrete improvement.
  - Comments identify the exact file, line, behaviour, or design choice being discussed.
  - The reviewer explains why something is a problem and suggests a realistic way to address it.
  - Feedback is specific, respectful, and focused on the code rather than the author.
  - Blocking problems are distinguished from optional suggestions and minor style preferences.
  - Comments are prioritised so that correctness, reproducibility, and maintainability receive more attention than cosmetic details.
  - The review acknowledges good solutions as well as areas that require changes.
- **Appropriate decision:** The final review decision should follow logically from the evidence in the review.
  - The reviewer checks the full pull request and its stated purpose before deciding.
  - Approval is given when the code is understandable, functional, sufficiently adaptable, and free of unresolved blocking issues.
  - Changes are requested when substantive problems with correctness, integration, reproducibility, or maintainability remain.
  - Questions and optional improvements do not automatically prevent approval.
  - The final decision includes a concise justification and is updated after requested changes have been addressed.

## Using this template

This repository illustrates one possible project structure. Like your own projects, parts of it were written with AI assistance.

The template is intentionally minimal and is not a perfect example that would automatically receive a perfect grade. It includes a simulation, experiment, and app to demonstrate several options; your project only needs one of these. It also provides equivalent Python and R variants, whereas your group should normally choose one language and one main deliverable. However, you can mix Python and R -- for example creating an experiment in psychopy and analysing the results in R -- as long as the main deliverable runs all code without errors.

From here on, this README demonstrates how students could document their own repository.

---

# pips-stroop-task

*(Imagine this is the repository name.)*

This repository contains code to plan, run, and analyse a Stroop experiment. We created it for our group project in the Programming in Psychological Science course of the Research Master Psychology at the University of Amsterdam.

The project lets users simulate group data, compare frequentist and Bayesian study designs, explore these designs in an app, collect data with a short Stroop task, and analyse data from multiple participants. The same workflow is implemented in Python and R: `main.ipynb` uses Dash, while `main.rmd` uses Shiny.

## Citation

```text
[Add the citation for your repository here.]
```

## Getting started

Clone the repository and choose either the Python or R variant:

```bash
git clone https://github.com/lukekorthals/pips-group-project-example.git
cd pips-group-project-example
```

### Python

The Python variant requires Python 3.12 or newer and [uv](https://docs.astral.sh/uv/). Install the locked dependencies and open the notebook:

```bash
uv sync
uv run jupyter lab main.ipynb
```

Run `main.ipynb` from top to bottom. The Dash app and experiment open interactive interfaces; stop the app before continuing and keep the experiment window in focus while responding.

### R

The R variant requires R 4.4 or newer and RStudio is recommended. Install the packages needed to open an R Markdown document:

```r
install.packages(c("knitr", "rmarkdown"))
```

Open `main.rmd` in RStudio and run its chunks from top to bottom. The sourced R scripts use `requireNamespace()` and automatically install any other missing packages. Interactive Shiny chunks are not evaluated while knitting and should be run manually.

## Repository structure

```text
pips-stroop-task/
├── data/                       # Simulated and collected CSV files
├── src/
│   ├── py/                     # Python analysis, experiment, app, and simulation
│   └── r/                      # Equivalent R scripts
├── main.ipynb                  # Python main deliverable
├── main.rmd                    # R main deliverable
├── pyproject.toml              # Python metadata and dependencies
└── uv.lock                     # Exact Python dependency versions
```

## Using the project

Choose `main.ipynb` for Python or `main.rmd` for R. Both main deliverables cover the following steps:

1. Simulate and save reaction-time data.
2. Conduct frequentist power analysis and Bayesian Bayes-factor design analysis.
3. Explore both analyses in the Dash or Shiny app.
4. Run the Stroop experiment for one participant at a time.
5. Load and analyse data from all participants.

The experiment asks participants to report the ink colour using the R, G, B, and Y keys. Use an anonymous participant ID. Each run creates a separate timestamped CSV file in `data/`; both language variants use the same columns and can load each other's files.

The app and experiment can also be started outside the notebook:

```bash
uv run python -m src.py.power_analysis_app
uv run python -m src.py.experiment
```

The equivalent R commands are:

```bash
Rscript src/r/power_analysis_app.R
Rscript src/r/experiment.R
```

## Dependencies

The Python analysis uses NumPy, pandas, SciPy, statsmodels, Pingouin, seaborn, and Plotly. Dash provides the app, Tkinter provides the experiment window, and JupyterLab and ipykernel support the notebook. Python dependencies are declared in `pyproject.toml` and locked in `uv.lock`.

The R analysis uses ggplot2 and BayesFactor, while Shiny provides both interactive interfaces. `knitr` and `rmarkdown` support the main document, and `later` controls trial timing. The R scripts install these packages when they are missing.

## Reference

Epp, A. M., Dobson, K. S., Dozois, D. J. A., & Frewen, P. A. (2012). [A systematic meta-analysis of the Stroop task in depression](https://www.sciencedirect.com/science/article/pii/S0272735812000281?via%3Dihub). *Clinical Psychology Review, 32*(4), 316–328. [https://doi.org/10.1016/j.cpr.2012.02.005](https://doi.org/10.1016/j.cpr.2012.02.005)
