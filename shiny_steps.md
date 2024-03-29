# Steps for creating a simple shiny app to explore some data on births and mother's education in the EU.

## References

- [deployed app](https://ildi-czeller.shinyapps.io/eu_births_shiny_app/)
- [slides](https://docs.google.com/presentation/d/1KSFLI_mAo_xnZaYSZA71Qo2AN5DjwkWH1EDiC3tBHno/edit#slide=id.p1)
- [shiny cheatsheet](https://www.rstudio.com/wp-content/uploads/2016/01/shiny-cheatsheet.pdf)

## Preparation

1. required packages: `shiny`, `ggplot2`, `dplyr` (`ggplot2` and `dplyr` are in the [`tidyverse`](https://www.tidyverse.org/packages/))
```r
install.packages(c("shiny", "ggplot2", "dplyr"))
```

2. Recommended: Download ZIP and extract or download these 2 files to a directory from [here](https://github.com/czeildi/shiny-intro-workshop-datafest-2019): `app.R`, `cleaned_birth_data.rds`

To work in [RStudio](https://rstudio.com/products/rstudio/) is highly recommended, but not necessary.

At any point to run your app, either press the green run App button in RStudio, or paste the following to your R console: `shiny::runApp(launch.browser = TRUE)`

## Step 1 - try minimal sample app

Run your app, it already shows our raw data with interactive searching.

>The ui tells us what type of inputs and outputs has to be shown in what layout, and contains static content not depending on data or calculation: e.g. labels, menu bars, etc. The layout is based on a 12 wide rectangular grid system.

>The server is responsible for calculations and filling the input and output containers in the ui with actual content.


## Step 2 - add summary plot

In `ui` add a new tab with title `birth summary` containing a `plotOutput` with id `birth_summary_plot`.

In `server` assign a call to `renderPlot` to `output$birth_summary_plot`. To generate the plot, put the following code inside the `renderPlot` function. Do not forget to add `library(ggplot2)` or `library(tidyverse)` to the beginning of your `app.R` file.

```r
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
```

>It is crucial that the ids are the same in your ui and server:

```r
# ui
plotOutput("whatever_id_you_type_in_here")

# server
output$whatever_id_you_type_in_here <- renderPlot({})
```

## Optional step 3 - adjust layout

you can adjust the relative width of main elements, and also the absolute height of plots:

```r
# ui
sidebarPanel(..., width = 2),
plotOutput(..., height = "600px")
```

**Q**: What is the default value of width for `sidebarPanel`, `mainPanel`, and for the height of `plotOutput`?

## Step 4 - filter data on period of years

>Raw data contains data for years from 2007 to 2015. The user may want to focus on a narrower period, but want to change this period dynamically.
You can receive user input and use it on the server side with widgets. Examples are [here](https://shiny.rstudio.com/gallery/widget-gallery.html).

**Your turn**: Let's use a slider range for filtering!
In `ui`, create your widget with params:

```r
# ui
sliderInput(
  inputId = "period", label = "Period to show:",
  min = 2007, max = 2015, value = c(2007, 2015),
  sep = "", step = 1
)
```

>You can use the current value of the slider at all times with `input$period`. This is a range slider, so its value is a vector of length 2. `input$period[1]` is the lower endpoint.

Use `dplyr::filter` inside your `renderPlot` function to keep data only within the selected period.

```r
# server
filter(..., year >= input$period[1] & year <= ...)
```

I advise the use of the pipe, but it is optional.

Without pipe:

```r
ggplot(filter(readRDS(...), ...), aes(...)) +
  geom_col(...)
```
or
```r
birth_dt <- readRDS(...)

filtered_dt <- filter(birth_dt, ...)

ggplot(filtered_dt, aes(...)) +
  geom_col(...)
```

With pipe:

```r
readRDS(...) %>%
  filter(year >= input$period[1] & ...) %>%
  ggplot(aes(...)) +
  geom_col(...)
```

**Your turn**: Apply the same filtering in the call to `renderDataTable`.

## Step 5 - use reactive expressions

We now have a significant amount of repeated code - let's move this to a function!


```r
# server
filtered_birth_dt <- function(period) {
  filter(
    readRDS("cleaned_birth_data.rds"),
    year >= period[1] & year <= period[2]
  )
}
```

Now use this function within `renderPlot` and `renderDataTable` as well like `filtered_birth_dt(input$period)`

To track how many times and with what parameters is this called, let's add a message inside:

```r
# server
filtered_birth_dt <- function(period) {
  message(
    "filtered birth dt function has been called with ",
    period
  )
  # ...
}
```

**Your turn**: Run your app and verify that the function gets called twice upon every change of the slider.

>Imagine this filtering was a somewhat more expensive calculation, or we have more plots using the same data. Then it is important to recalculate if and only if the values of the relevant input widgets change.
This is achieved with so called `reactive` expressions in `shiny`. You just have to define your function as a reactive expression and optimal recalculation and caching is automatically taken care of. Now you do not have to pass `input$period` as an argument because `input` is available to all reactive contexts: reactives and render... functions.

```r
# server
filtered_birth_dt <- reactive({
  message(
    "filtered birth dt function has been called with ",
    input$period
  )
  # ...
})
```
**Your turn**: Run your app and verify that the function now gets called only once upon every change of the slider.

>A reactive expression is essentially three things together:
> - a recipe: the code tells **how** to calculate the result **if** it needs to be calculated
> - a value: the result calculated the last time this expression was evaluated
> - a `TRUE/FALSE` value: whether the last calculated value is still up-to-date considering the possible change in dependencies


## Optional step 6 - practice filtering based on user input

**Your turn**: Add the option of filtering for an arbitrary subset of countries.

Hints:

```r
# ui
checkboxGroupInput(
  inputId = "countries", label = "Countries to show:",
  choices = unique(...),
  selected = ...
),
```

```r
# server
filter(
  readRDS("cleaned_birth_data.rds"),
  year >= input$period[1] & year <= input$period[2] &
      country %in% input$countries
)
```

>Notice that now that we use the same reactive expression for rendering the table and the plot as well, this new filter gets applied to both of them.

## Step 7 - control execution with action buttons

>By default a recalculation will happen every time a value of any input widget changes. It means 4 recalculations if you decide you want to focus on only one country but have to uncheck 4 checkboxes one by one. This recalculation is quite fast with this amount of data but the rendering of the plot already takes up a noticable amount of time.

>An **action button** is a special input widget which changes its value on startup and every time it is pressed.

>So if it is included in a expression with the server that expression will recalculate every time you press the button.

>However, if your calculation depends on other input values as well you want to stop recalculation if those values change but your user haven't pressed the action button yet. This can be achieved with `isolate`: Although it can contain input values, their change won't trigger a recalculation. But when you press the action button it will recalculate and use the current values of input widgets.

```r
# ui
actionButton(
  inputId = "recalculate_plot",
  label = "Apply filters on plot!"
)
```

```r
# server
output$birth_plot <- renderPlot({

  input$recalculate_plot

  isolate(
    ggplot(
      filtered_birth_dt(),
      aes(x = age, y = num_birth, fill = education_level)
    ) +
      geom_col(position = "dodge") +
      facet_grid(year ~ country) +
      theme(
        legend.position = "bottom",
        legend.direction = "vertical"
      )
  )
})
```

>Now your renderPlot function encloses multiple expressions so don't forget to enclose them with `{}`.

>Notice that the table recalculated upon every filter change but the plot does not.

**Your turn**:

- What happens if you leave the call to `isolate` out?
- What can you use if you want to wait for the button press at the first time as well?
  - *Hint*: `eventReactive`

## Optional assignments to work on at home

_This assignments are in an approximate order of increasing difficulty._

- add a new completely empty tab with some title
- use a different `id` for the shown table. check if the app is still working
- Show the current value of the period slider with a `textOutput` and `renderText`, in the `sidebarPanel`, below the slider.
- use `tableOutput` and `renderTable` instead of `dataTableOutput` and `renderDataTable`. What is the difference?
- Add the option of filtering for an arbitrary subset of countries. (Hint: use `checkboxGroupInput`). [Reference here](https://shiny.rstudio.com/gallery/widget-gallery.html)
- separate `app.R` to `ui.R` and `server.R`, possibly use `global.R`

**Q**: add a new tab with a plot on ratio of all births by education, regardless of mother's age.

*Hint*:

for aggregating you can use `dplyr::group_by` and `dplyr::summarise`:

```r
filtered_birth_dt() %>%
  group_by(year, country, education_level) %>%
  summarise(num_birth = sum(num_birth))
```

For the plot you may use `geom_area(position = 'fill')`

**Q**: Put the summary table alongside of this plot and try different layouts: below, alongside.

*Hint*: two columns of width 6 make a 100% width:

```r
tabPanel(
  title = "",
  column(
    6, plotOutput(...)
  ),
  column(
    6, dataTableOutput(...)
  )
)
```

**Q**: Add a new tab and a new user input widget to show min/max/avg/median of age by year, country, education level.

*Hint*: use `selectInput(..., choices = c('min', 'max', 'mean', 'median'))` to control the shown metric.

- Create an entirely new shiny app which uses a built-in dataset, e.g. diamonds. Show an arbitrary plot of your choice.
