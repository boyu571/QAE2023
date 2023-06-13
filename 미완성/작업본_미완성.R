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

today <- Sys.Date()
bitcoin <- read_xlsx("binance.xlsx")
bitcoin <- bitcoin[order(bitcoin$close_time, decreasing = T),]
cpi <- read.csv("CPI.csv")
cpi <- cpi[order(cpi$DATE, decreasing = T),]
dollar <- read.csv("dollar_index.csv")
dollar <- dollar[order(dollar$DATE, decreasing = T),]
fed <- read.csv("fedfunds.csv")
fed <- fed[order(fed$DATE, decreasing = T),]
GDP <- read.csv("GDP_forecast_US.csv")
GDP <- GDP[order(GDP$TIME, decreasing = T),]
nasdaq <- read.csv("nasdaq100.csv")
nasdaq <- nasdaq[order(nasdaq$DATE, decreasing = T),]
oil<- read.csv("oil.csv")
oil <- oil[order(oil$DATE, decreasing = T),]
unem<- read.csv("unem_rate.csv")
unem <- unem[order(unem$DATE, decreasing = T),]
gold <- read_xlsx("xauusd.xlsx")
gold <- gold[order(gold$X1, decreasing = T), ]
bitcoin <- bitcoin[, 1:5]


css <- sass(sass_file("www/chat.scss"))
jscode <- 'var container = document.getElementById("chat-container");
if (container) {
  var elements = container.getElementsByClassName("user-message");
  if (elements.length > 1) {
    var lastElement = elements[elements.length - 1];
    lastElement.scrollIntoView({
      behavior: "smooth"
    });
  }
}'

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

# Define UI for application

ui <- dashboardPage(
  dashboardHeader(title = "Cryptocurrency Research"),
  dashboardSidebar(
    width = 220,
    sidebarMenu(
      # uiOutput('date'),
      menuItem("Info", tabName = "info", icon = icon("info-circle")),#stra
      menuItem("Bitcoin", tabName = "bitcoin", icon = icon("bitcoin")),#overview
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-bar")),#return
      menuItem("ChatGPT", tabName = "chatgpt", icon = icon("comments"))#weight

    )),
  

  dashboardBody(
    tags$head(tags$style(HTML("
	                .main-header .logo {
	                font-size: 16px;
                    }"))),
    
    tabItems(
      tabItem("info",
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
      
      
      tabItem("bitcoin",
              fluidRow(
                column(width = 12,
                       box(width = NULL,
                           uiOutput('tz'),
                           plotlyOutput('period_graph', height = 250)
                       )),
                column(width = 12,
                       box(width = NULL,
                           withSpinner(tableOutput('bitcoin_table')),
                           # DT::dataTableOutput('bitcoin_table'),
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
                       )),
                
                column(width = 12, height = 300,
                       box(textInput("apiKey", "API Key", "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"),
                           style = "background-color: #fff; color: #333; border: 1px solid #ccc;"),),)
      )#gpt end
      
      

    )
    
    
  )
)

# Define server logic
server <- function(input, output, session) {
  
  output$bitcoin_table = function() {
    
    bitcoin  %>%
      kable() %>%
      kable_styling(bootstrap_options =
                      c("striped", "hover", "condensed", "responsive"))
    
  }
  
  

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


# Run the application
shinyApp(ui=ui, server=server)


