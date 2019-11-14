# global ------------------------------------------------------------------

library("shiny")
library("ggplot2")
suppressPackageStartupMessages(library("dplyr"))

# UI ----------------------------------------------------------------------

ui <- fluidPage(

  title = "EU births shiny demo",

  sidebarPanel(
    "placeholder for input widgets",
    width = 2
  ),

  mainPanel(
    tabsetPanel(
      tabPanel(
        title = "table",
        dataTableOutput(outputId = "birth_dt")
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

  output$birth_dt <- renderDataTable({
    readRDS("cleaned_birth_data.rds")
  }, escape = FALSE)

  output$birth_summary_plot <- renderPlot({
    ggplot(
      readRDS("cleaned_birth_data.rds"),
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
