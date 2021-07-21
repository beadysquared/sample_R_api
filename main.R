
library(plumber)


# create config.yaml file with format below:
# 
# client_key: XXXXXXXXXXXXXXXXXXX
# client_secret: XXXXXXXXXXXXXXXXXXXX

# 
# setwd() to your folder

# Install plumberDeploy and analogsea for Digital Ocean deployment

r <- plumber::plumb("plumber.R")
r$run(host="0.0.0.0", port=8000)
