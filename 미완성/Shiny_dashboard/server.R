library(shiny)
library(httr)
library(sass)
library(markdown)
library(waiter)
library(shinyjs)
library(shinyCopy2clipboard)
# remotes::install_github("deepanshu88/shinyCopy2clipboard")

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
      model = model,
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