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

chatGPT_R <- function(apiKey, prompt, model="gpt-3.5-turbo") {
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", apiKey)),
    content_type("application/json"),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      messages = list(
        list(role = "user", content = prompt)
      )
    )
  )

  if(status_code(response)>200) {
    result <- trimws(content(response)$error$message)
  } else {
    result <- trimws(content(response)$choices[[1]]$message$content)
  }

  return(result)

}

execute_at_next_input <- function(expr, session = getDefaultReactiveDomain()) {
  observeEvent(once = TRUE, reactiveValuesToList(session$input), {
    force(expr)
  }, ignoreInit = TRUE)
}

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
                                      "<div class='img-wrapper'><img src='skku_logo.avif' class='img-wrapper2'></div>",
                                      "<div class='img-wrapper'><img src='ChatGPT_logo.avif' class='img-wrapper2'></div>"),
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


