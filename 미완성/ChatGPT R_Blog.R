#01 PKG
install.packages("chatgpt")
install_github("MichelNivard/GPTstudio")
install.packages("openai")

#02 Load
library(chatgpt)
library(gptstudio)
library(openai)

#03 ChatGPT API key
Sys.setenv(OPENAI_API_KEY = "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")



#03 R에서 ChatGPT에 질문하기 : ask_chatgpt 
cat(ask_chatgpt("Show me text mining sample code using tm packages"))



#04 R에서 한글로 질문하기 : ask_chatgpt
cat(ask_chatgpt("텍스트마이닝 샘플 코드를 보여줘"))



#05 코드 설명 : explain_code 
cat(explain_code("dtm <- DocumentTermMatrix(myCorpus)"))
