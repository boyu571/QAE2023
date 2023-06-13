
library("bitGPT")

# 실제 사용자가 할당받은 openai API key를 사용합니다.
regist_openai_key("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")

# 실제 사용자가 할당받은 Naver API key를 사용합니다.
regist_naver_key(client_id = "3Oh_JkM1vgdrN47sVFo6", client_secret = "Ucd6clb9OO")

library(shinyGPT)

shiny_chatgpt()
