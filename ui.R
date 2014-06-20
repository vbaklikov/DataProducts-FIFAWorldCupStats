
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggvis)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("FIFA World Cup analyzer"),
  fluidRow(
    column(3,
           wellPanel(
             h4("World Cup Range"),
             sliderInput("year", "World Cup Year", 1930, 2014, value = c(1930,2014), step=4)
             
           ),
           wellPanel(
             textInput("team", "Games by country",value = "All"),
             actionButton("goButton","Get games")
             ),
           wellPanel(
             selectInput("gameType", "Stage", 
                         c("All" = "All",
                           "Group Stage" = "Matchday",
                           "Round of 16" = "Round of 16",
                           "Quarter Finals" = "Quarterfinals",
                           "Semi Finals" = "Semifinals",
                           "Third place match" = "Third place match",
                           "Final"= "Final"), 
                         selected = "All")
           ),
           wellPanel(
             span("Total goals scored:",
                  textOutput("n_goals"),
                  span("Total games played:"),
                  textOutput("n_games")
             )
           )
    ),
    mainPanel(
      ggvisOutput("distPlot")
      )
  )
)
)