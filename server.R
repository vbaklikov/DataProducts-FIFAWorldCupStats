
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(ggvis)

#read the tables on app start
allFIFAwc <- read.csv(file="allFIFAwc.csv", header=FALSE, stringsAsFactors = FALSE)
names(allFIFAwc) <- c("id","gameType", "team1", "team2", "gameDate", "score1", "score2", "score1et", "score2et", "score1p", "score2p", "winner" )
allFIFAwc[is.na(allFIFAwc)] <- 0
allFIFAwc$wcYear <- format(as.Date(allFIFAwc$gameDate),"%Y")
allFIFAwc$goals <- allFIFAwc$score1 + allFIFAwc$score2 + allFIFAwc$score1et + allFIFAwc$score2et
allFIFAwc$gameType[allFIFAwc$gameType == "Semi-finals"] <- "Semifinals"
allFIFAwc$gameType[allFIFAwc$gameType == "Quarter-finals"] <- "Quarterfinals"
allFIFAwc$gameType[allFIFAwc$gameType == "Third Place play-off" | 
                     allFIFAwc$gameType == "Third-place match" |
                     allFIFAwc$gameType == "Third-place play-off"] <- "Third place match"
allFIFAwc$isFinalGame <- "No"
allFIFAwc$isFinalGame[allFIFAwc$gameType == "Final"] <- "Yes"

shinyServer(function(input, output,session) {
  
  #Filter the games based on input
  games <- reactive({
    minyear <- input$year[1]
    maxyear <- input$year[2]
    stage <- input$gameType
    
    g <- allFIFAwc %>%
      filter(
        wcYear >= minyear,
        wcYear <= maxyear
      )
    
    if(input$goButton ){
      isolate(country <- input$team)
      if(country != "All"){
        g <- g %>% filter(grepl(country, team1) | grepl(country, team2))
      }
    }
   
    if(stage != "All"){
      g <- g %>% filter(grepl(paste("^",stage,sep=""),gameType,ignore.case = TRUE))
    }
    
    g
  })
  
  games_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$id)) return(NULL)
    temp <- isolate(games())
    game <- temp[temp$id == x$id,]
    
    paste0("<b>", game$team1,"-", game$team2, "</b><br>",
           "Main time score: ", "<b>",game$score1, "-", game$score2, "</b><br>",
           "Extra time score: ", game$score1et, "-", game$score2et, "<br>",
           "Penalties: ", game$score1p, "-", game$score2p, "<br>",
           "Game played on: ", as.Date(game$gameDate), "<br>",
           "Game Stage: ", game$gameType, "<br>")
  }
  
  
  vis <- reactive({
    
    games %>% ggvis(x=~wcYear, y=~goals) %>%
      layer_points(size := 50, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5,
                   stroke = ~isFinalGame, key := ~id) %>%
                   add_tooltip(games_tooltip, "hover") %>%
                   add_axis("x", title = "World Cup Year") %>%
                   add_axis("y", title = "Total Goals") %>%
                   add_legend(c("stroke"), title="Final Game") %>%
                   scale_nominal("stroke",domain = c("Yes", "No"),range = c("orange", "#aaa"))  
                   #add_legend(stroke = "stroke", title = "Final Game", values = c("Yes", "No")) %>%
                   #set_dscale("stroke", type = "nominal", domain = c("Yes", "No"), range = c("orange", "#aaa")) %>%
                   #set_options(width = 500, height = 500, renderer = "canvas", duration = 0)
    
    
  })
  
  vis %>% bind_shiny("distPlot")
  
  output$n_goals <- renderText({
    temp <- games()
    sum(temp$goals)
  })
  
  output$n_games <- renderText({
    temp <- games()
    nrow(temp)
  })
  
})
