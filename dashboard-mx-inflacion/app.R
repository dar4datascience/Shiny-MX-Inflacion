library(shiny)
library(plotly)
library(gridlayout)
library(bslib)
library(DT)

# Your server function remains unchanged

# New bslib cards
cards <- list(
  card(
    full_screen = TRUE,
    card_header("Inflaciones"),
    card_body(DTOutput(outputId = "myTable", width = "100%"))
  ),
  card(
    full_screen = TRUE,
    card_header("Grafica Inflacion 2"),
    card_body(plotlyOutput(outputId = "distPlot", width = "100%", height = "100%"))
  ),
  card(
    full_screen = TRUE,
    card_body(
      value_box(
        title = "Look at me!",
        showcase = bsicons::bs_icon("graph-up-arrow"),
        value = 100
      )
    )
  ),
  card(
    full_screen = TRUE,
    card_body(plotOutput(outputId = "bluePlot"))
  )
)

# Sidebar definition
sidebar_ui <- sidebar(
  card_header("Controles"),
  card_body(
    sliderInput(
      inputId = "bins",
      label = "Number of Bins",
      min = 12,
      max = 100,
      value = 30,
      width = "100%"
    ),
    numericInput(
      inputId = "numRows",
      label = "Number of table rows",
      value = 10,
      min = 1,
      step = 1,
      width = "100%"
    ),
    radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                 inline = TRUE),
    downloadButton('downloadReport')
  )
)

# Updated UI
ui <- page_sidebar(
  theme = bs_theme(bootswatch = "superhero"),
  title = "La Inflacion en Mexico",
  sidebar = sidebar_ui,
  layout_columns(
    col_widths = c(4, 8, 12),
    row_heights = c(1, 2),
    cards[[3]],
    cards[[2]],
    cards[[1]]
  )
)

server <- function(input, output) {
  output$distPlot <- renderPlotly({
    # generate bins based on input$bins from ui.R
    plot_ly(x = ~ faithful[, 2], type = "histogram")
  })

  output$bluePlot <- renderPlotly({
    # generate bins based on input$bins from ui.R
    plot_ly(x = ~ faithful[, 2], type = "histogram")
  })


  output$myTable <- renderDT({
    head(faithful, input$numRows)
  })

  output$downloadReport <- downloadHandler(
    filename = function() {
      paste('my-report', sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
      ))
    },

    content = function(file) {
      src <- normalizePath('report.Rmd')

      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd', overwrite = TRUE)

      library(rmarkdown)
      out <- render('report.Rmd', switch(
        input$format,
        PDF = pdf_document(), HTML = html_document(), Word = word_document()
      ))
      file.rename(out, file)
    }
  )

}

shinyApp(ui, server)
