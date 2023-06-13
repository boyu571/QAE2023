dashboardSidebar(
  width = 220,
  sidebarMenu(
    # uiOutput('date'),
    menuItem("Info", tabName = "info", icon = icon("info-circle")),#stra
    menuItem("Bitcoin", tabName = "Bitcoin", icon = icon("bitcoin")),#overview
    menuItem("Dashboard", icon = icon("chart-bar")),#return
    menuItem("ChatGPT", tabName = "chatgpt", icon = icon("comments")),#weight
    menuItem("Raw Data", tabName = "raw", icon = icon("database")),
    menuItem("Profile", tabName = "profile", icon = icon("address-card"))
  )
)