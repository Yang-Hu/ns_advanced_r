library(shiny)
library(tidyverse)
library(bslib)
library(ggrepel)


ui <- page_sidebar(

  title = "Visualise Sine",

  sidebar = sidebar(sliderInput(inputId = "max_degree", label = "Max degree:",
                                value = 0, min = 0, max = 360, step = 15, animate = TRUE),

                    sliderInput(inputId = "current_degree", label = "Current degree:",
                                value = 0, min = 0, max = 360, ticks = FALSE, animate = TRUE)),

  plotOutput(outputId = "triangle"),

  textOutput(outputId = "sin_calculation"),

  plotOutput(outputId = "plot"))


server <- function(input, output, session) {

  # Define the data frame:
  df <- reactive({
    tibble(
      degree       = 0:input$max_degree,
      point_degree = input$current_degree,

      sin          = sin(degree * pi / 180),
      point_sin    = sin(point_degree * pi / 180),

      sin_text     = paste0("Degree:", point_degree, ", Sin:", round(point_sin, digits = 2)))
  })


  # Define the triangle points:
  tri_df <- reactive({
    tibble(
      x    = c(0, sqrt(2), cos(input$current_degree * pi / 180) * sqrt(2)),
      y    = c(0, 0,       sin(input$current_degree * pi / 180) * sqrt(2)),
      text = paste0("Degree:", input$current_degree, ", Sin:", round(sin(input$current_degree * pi / 180), digits = 2)))
  })


  tri_text_df <- reactive({
    tri_df()[3, ]
  })


  # Control the flow of inputs (need to review the reversed case):
  observeEvent(input$current_degree, {
    if (input$current_degree > input$max_degree) {
      updateSliderInput(session = session, inputId = "current_degree", value = input$max_degree)
    }
  })


  # Code for the triangle plot:
  output$triangle <- renderPlot({

    tibble(
      radian = seq(from = 0, to = input$current_degree, length.out = 100) * pi / 180,
      x_cord = sqrt(2) * cos(radian),
      y_cord = sqrt(2) * sin(radian)) |>

      add_row(radian = NA, x_cord = 0, y_cord = 0) |>

      ggplot(aes(x = x_cord, y = y_cord)) +

      geom_path(data = tibble(
        radian = seq(from = 0, to = input$max_degree, length.out = 100) * pi / 180,
        x_cord = sqrt(2) * cos(radian),
        y_cord = sqrt(2) * sin(radian)),

        aes(x = x_cord, y = y_cord), colour = "black") +

      geom_polygon(fill = NA) +

      geom_polygon(data = tri_df(),
                   aes(x = x, y = y),
                   colour = "red",
                   fill = NA,
                   linewidth = 0.5) +

      geom_label_repel(
        data = tri_text_df(),
        aes(x = x, y = y, label = text)) +

      annotate(geom = "segment",
               x    = cos(input$current_degree * pi / 180) * sqrt(2),
               xend = cos(input$current_degree * pi / 180) * sqrt(2),

               y    = 0,
               yend = sin(input$current_degree * pi / 180) * sqrt(2),

               linetype = 3,
               linewidth = 0.5) +



      geom_hline(yintercept = 0, colour = "grey70", linewidth = 0.1) +

      geom_vline(xintercept = 0, colour = "grey70", linewidth = 0.1) +

      scale_x_continuous(limits = c(-sqrt(2), sqrt(2))) +
      scale_y_continuous(limits = c(-sqrt(2), sqrt(2))) +

      coord_fixed() +

      theme_bw() +

      theme(panel.grid = element_blank())
  }, res = 96)


  # Code for the output text:
  output$sin_calculation <- renderText({

    paste0("For a degree of ", input$current_degree, ", and a hypotenuse with a length of sqrt(2), the value of sine is: ",
           round(sin(input$current_degree * pi / 180), digits = 2), ".")
    })



  # Code for the trigonometric (sin) plot:
  output$plot <- renderPlot({

    df() |>
      ggplot() +

      geom_hline(yintercept = 0, colour = "grey70", linewidth = 0.1) +

      geom_hline(yintercept = c(-1, 1), colour = "grey70", linewidth = 0.1) +

      geom_line(aes(x = degree, y = sin), colour = "darkgreen") +

      geom_point(aes(x = point_degree, y = point_sin), size = 3) +

      geom_label(aes(x = point_degree, y = point_sin, label = sin_text), hjust = -0.1) +

      theme_bw() +

      scale_x_continuous(limits = c(0, 360),
                         breaks = seq(from = 0, to = 360, by = 15),
                         expand = c(0, 0)) +

      scale_y_continuous(limits = c(-1, 1)) +

      theme(
        panel.grid = element_blank()
      )
  }, res = 96)

} # <- The end of the server call

shinyApp(ui, server)
