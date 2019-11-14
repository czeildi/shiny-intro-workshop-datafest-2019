# global ------------------------------------------------------------------

library("shiny")
library("ggplot2")
suppressPackageStartupMessages(library("dplyr"))

# UI ----------------------------------------------------------------------

ui <- fluidPage(

  title = "EU births shiny demo",

  sidebarPanel(
    sliderInput(
      inputId = "period", label = "Period to show:",
      min = 2007, max = 2015, value = c(2007, 2015),
      sep = "", step = 1
    ),
    width = 2
  ),

  mainPanel(
    tabsetPanel(
      tabPanel(
        title = "table",
        DT::dataTableOutput(outputId = "birth_dt")
      ),
      tabPanel(
        title = "birth summary",
        plotOutput("birth_summary_plot", height = "600")
      )
    ),
    width = 10
  )
)

# server ------------------------------------------------------------------

server <- function(input, output) {

  filtered_birth_dt <- function(period) {
    message(
      "filtered birth dt function has been called with ",
      period
    )
    filter(
      readRDS("cleaned_birth_data.rds"),
      year >= period[1] & year <= period[2]
    )
  }

  output$birth_dt <- DT::renderDataTable({
    filtered_birth_dt(input$period)
  })

  output$birth_summary_plot <- renderPlot({
    filtered_birth_dt(input$period) %>%
      ggplot(
        aes(x = age, y = num_birth, fill = education_level)
      ) +
      geom_col(position = "dodge") +
      facet_grid(year ~ country) +
      theme(
        legend.position = "bottom",
        legend.direction = "vertical"
      )
  })

}

# app ---------------------------------------------------------------------

shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
