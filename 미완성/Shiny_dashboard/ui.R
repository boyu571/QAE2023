#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(httr)
library(sass)
library(markdown)
library(waiter)
library(shinyjs)
library(shinyCopy2clipboard)

# Define UI for application
ui <- fluidPage(
  useWaiter(),
  useShinyjs(),
  use_copy(),
  tags$head(tags$style(css)),
  sidebarLayout(
    sidebarPanel(
      textInput("apiKey", "API Key", "sk-xxxxxxxxxxxxxxxxxxxx"),
      selectInput("model", "Model", choices = c("gpt-3.5-turbo", "gpt-4"), selected = "gpt-3.5-turbo"),
      style = "background-color: #fff; color: #333; border: 1px solid #ccc;"
    ),
    
    mainPanel(
      tags$div(
        id = "chat-container",
        tags$div(
          id = "chat-header",
          tags$img(src = "TnUa864.png", alt = "AI Profile Picture"),
          tags$h3("AI Assistant")
        ),
        tags$div(
          id = "chat-history",
          uiOutput("chatThread"),
        ),
        tags$div(
          id = "chat-input",
          tags$form(
            column(12,textAreaInput(inputId = "prompt", label="", placeholder = "Type your message here...", width = "100%")),
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

# Define server logic
server <- function(input, output, session) {
  
  historyALL <- reactiveValues(df = data.frame() , val = character(0))
  
  # On click of send button
  observeEvent(input$submit, {
    
    if (nchar(trimws(input$prompt)) > 0) {
      
      # Spinner
      w <- Waiter$new(id = "chat-history",
                      html = spin_3(),
                      color = transparent(.5))
      w$show()
      
      # Response
      chatGPT <- chatGPT_R(input$apiKey, input$prompt, input$model)
      historyALL$val <- chatGPT
      history <- data.frame(users = c("Human", "AI"),
                            content = c(input$prompt, markdown::mark_html(text=chatGPT)),
                            stringsAsFactors = FALSE)
      historyALL$df <- rbind(historyALL$df, history)
      updateTextInput(session, "prompt", value = "")
      
      # Conversation Interface
      output$chatThread <- renderUI({
        conversations <- lapply(seq_len(nrow(historyALL$df)), function(x) {
          tags$div(class = ifelse(historyALL$df[x, "users"] == "Human",
                                  "user-message",
                                  "bot-message"),
                   HTML(paste0(ifelse(historyALL$df[x, "users"] == "Human",
                                      "
<img src='girl.avif' class='img-wrapper2'>
",
                                      "
<img src='boy.avif' class='img-wrapper2'>
"),
                               historyALL$df[x, "content"])))
        })
        do.call(tagList, conversations)
      })
      
      w$hide()
      execute_at_next_input(runjs(jscode))
      
    }
    
  })
  
  observeEvent(input$remove_chatThread, {
    output$chatThread <- renderUI({return(NULL)})
    historyALL$df <- NULL
    updateTextInput(session, "prompt", value = "")
  })
  
  observe({
    req(input$clipbtn)
    CopyButtonUpdate(session,
                     id = "clipbtn",
                     label = "Copy",
                     icon = icon("clipboard"),
                     text = as.character(historyALL$val))
    
  })
  
  
}
