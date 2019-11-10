fluidPage(

  title = "EU births shiny demo",

  sidebarPanel(
    "placeholder for input widgets"
  ),

  mainPanel(
    tabsetPanel(
      tabPanel(
        title = "table",
        dataTableOutput(outputId = "birth_dt")
      )
    )
  )
)
