library(dplyr)
library(stringr)
library(rvest)
library(writexl)
library(readxl)
library(binancer)


today <- Sys.Date()
yesterday <-today-1
year <-format(Sys.Date(), "%Y")
day <- format(Sys.Date(), "%d")
month <- format(Sys.Date(), "%m")
last_month <- as.numeric(month) -1
if (as.numeric(last_month) <10 ) {
  last_month <- str_c('0',last_month)
} else {
  last_month <-last_month
}
month_date
as.numeric(day)
if (as.numeric(day) >1 ) {
    month_date <- format(Sys.Date(), "%m")
} else {
  month_date <- last_month
}

# 비트코인 시세(binance)
?binance_klines()
# binance_klines('BTCUSDT', interval = '1d', start_time = '2017-01-01', end_time ='2017-12-31')

stack <- NULL
for (i in 2017:year){
  annual <- binance_klines('BTCUSDT', interval = '1d', start_time = str_c(i,'-01-01'), end_time = str_c(i,'-12-31'))
  stack <- rbind(stack, annual)
}
View(stack)
write_xlsx(stack, "bitcoin.xlsx")

stack <- NULL
for (i in 2017:year){
  annual <- binance_klines('ETHUSDT', interval = '1d', start_time = str_c(i,'-01-01'), end_time = str_c(i,'-12-31'))
  stack <- rbind(stack, annual)
}
View(stack)
write_xlsx(stack, "ethereum.xlsx")


# library(ggplot2)
ggplot(stack, aes(close_time, close)) + geom_line()


# 달러지수
URL <- str_c("https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1318&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=RTWEXBGS&scale=left&cosd=2006-01-01&coed=2023-",yesterday , "-02&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=",yesterday,"&revision_date=",yesterday,"&nd=2006-01-01")


outfile <- "dollar_index.csv"
download.file(URL, outfile)


### 금/달러 spot price

URL <- "https://www.myfxbook.com/forex-market/currencies/XAUUSD-historical-data" 
res <- read_html(URL)

xauusd <- res %>% 
  html_table(fill=TRUE) %>% 
  .[[2]]

xauusd
write_xlsx(xauusd, "xauusd.xlsx")


### 나스닥 100

URL <- str_c("https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=958&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=NASDAQ100&scale=left&cosd=2000-01-01&coed=", yesterday, "&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily%2C%20Close&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=", yesterday ,"&revision_date=", yesterday,"&nd=2000-01-01")

outfile <- "nasdaq100.csv"
download.file(URL, outfile)


### 연방 기금 금리

URL <- str_c("https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1318&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=FEDFUNDS&scale=left&cosd=2000-01-01&coed=", yesterday,"&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=", yesterday,"&revision_date=", yesterday,"&nd=1954-07-01")
outfile <- "fedfunds.csv"
download.file(URL, outfile)


# 실업률
URL <- str_c("https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1318&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=UNRATE&scale=left&cosd=2000-01-01&coed=", yesterday,"&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=", yesterday,"&revision_date=", yesterday,"&nd=1948-01-01")
outfile <- "unem_rate.csv"
download.file(URL, outfile)


# GDP
URL <- "https://stats.oecd.org/sdmx-json/data/DP_LIVE/USA.REALGDPFORECAST.TOT.AGRWTH.Q/OECD?contentType=csv&amp;detail=code&amp;separator=comma&amp;csv-lang=en&amp;startPeriod=2013-Q1"
outfile <- "GDP_forecast_US.csv"
download.file(URL, outfile)


# CPI
URL <- str_c("https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1318&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=CPIAUCSL&scale=left&cosd=2000-01-01&coed=", yesterday,"&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=", yesterday,"&revision_date=", yesterday,"&nd=1947-01-01")
outfile <- "CPI.csv"
download.file(URL, outfile)


# 국제 유가
URL <- str_c("https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1318&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=DCOILWTICO&scale=left&cosd=2000-01-02&coed=", yesterday,"&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Daily&fam=avg&fgst=lin&fgsnd=2020-02-01&line_index=1&transformation=lin&vintage_date=", yesterday,"&revision_date=", yesterday,"&nd=1986-01-02")
outfile <- "oil.csv"
download.file(URL, outfile)


