library(shiny)
library(httr)
library(sass)
library(markdown)
library(waiter)
library(shinyjs)
library(shinyCopy2clipboard)
library(flexdashboard)
library(XML)
library(rvest)
library(dplyr)
library(stringr)
library(writexl)
library(readxl)
library(tidyr)
library(knitr)
library(kableExtra)


# Define UI for application

ui <- dashboardPage(
  dashboardHeader(title = "Cryptocurrency Research App"),
  dashboardSidebar(
    width = 220,
    sidebarMenu(
      
      menuItem("Bitcoin", tabName = "bitcoin", icon = icon("bitcoin")),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-bar")),
      menuItem("ChatGPT", tabName = "chatgpt", icon = icon("comments"))

    )),
  
  
  dashboardBody(
    tabItems(
      tabItem("bitcoin",
              fluidRow(
                column(width = 12,
                       box(width = NULL,
                           uiOutput('tz'),
                           plotlyOutput('period_graph', height = 250)
                       )),
                column(width = 12,
                       box(width = NULL,
                           DT::dataTableOutput('return_table'),
                           style = "height:400px; overflow-y: scroll"
                       ))
              )
      ),
      
      tabItem("dashboard",
              fluidRow(
                column(width = 12,
                       box(width = NULL,
                           uiOutput('tz'),
                           plotlyOutput('period_graph', height = 250)
                       )),
                column(width = 12,
                       box(width = NULL,
                           DT::dataTableOutput('return_table'),
                           style = "height:400px; overflow-y: scroll"
                       ))
              )
      ),
      
      tabItem("chatgpt",
              fluidRow(
                column(width = 12, height = 300,
                       box(
                         tags$div(
                           id = "chat-container",
                           tags$div(
                             id = "chat-header",
                             tags$h3("ChatGPT")
                           ),
                           tags$div(
                             id = "chat-history",
                             uiOutput("chatThread"),
                           ),
                           tags$div(
                             id = "chat-input",
                             tags$form(
                               column(12,textAreaInput(inputId = "prompt", label="", placeholder = "Send a message.", width = "100%")),
                               fluidRow(
                                 tags$div(style = "margin-left: 1.5em;",
                                          actionButton(inputId = "submit",
                                                       label = "Send",
                                                       icon = icon("paper-plane")),
                                          actionButton(inputId = "remove_chatThread",
                                                       label = "Clear History",
                                                       icon = icon("trash-can")),
                                          CopyButton("clipbtn",
                                                     label = "Copy",
                                                     icon = icon("clipboard"),
                                                     text = "")
                                          
                                 ))
                             ))
                         )
                       ))
              )
              
      )
    )
  
    
    
  )
)