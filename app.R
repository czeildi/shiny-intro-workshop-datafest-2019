# global ------------------------------------------------------------------

# install.packages(c("shiny", "dplyr", "ggplot2", "DT"))

library("shiny")
# library("ggplot2")
suppressPackageStartupMessages(library("dplyr"))

# UI ----------------------------------------------------------------------

ui <- fluidPage(

  title = "EU births shiny demo",

  sidebarPanel(
    "placeholder for input widgets"
  ),

  mainPanel(
    tabsetPanel(
      tabPanel(
        title = "table",
        DT::dataTableOutput(outputId = "birth_dt")
      )
    )
  )
)

# server ------------------------------------------------------------------

server <- function(input, output) {

  output$birth_dt <- DT::renderDataTable({
    readRDS("cleaned_birth_data.rds")
  })
}

# app ---------------------------------------------------------------------

shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
