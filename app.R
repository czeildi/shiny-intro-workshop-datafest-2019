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
    readRDS("cleaned_birth_data.rds") %>%
      filter(year >= input$period[1] & year <= input$period[2])
  }, escape = FALSE)

  output$birth_summary_plot <- renderPlot({
    readRDS("cleaned_birth_data.rds") %>%
      filter(year >= input$period[1] & year <= input$period[2]) %>%
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
