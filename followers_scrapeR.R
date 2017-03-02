# Leslie Huang
# Twitter network scraping: How many of a user's followers are connected to each other?

### Set up the workspace
rm(list=ls())
setwd("/Users/lesliehuang/Dropbox/twitter-scrapeR/")

set.seed(1234)

libraries <- c("foreign", "utils", "dplyr", "devtools", "ggplot2", "twitteR")
lapply(libraries, require, character.only=TRUE)

# Get these from your API:
# CONSUMER KEY, CONSUMER SECRET, ACCESS TOKEN, ACCESS SECRET

consumer_key <- "L3hRFSHaBtcLqJBd0vyuTNBLQ"
consumer_secret <- "0xQD1LhefrpcP83pjVJqteyxhsO7Xsiw9tyGDPxRSoOr1F9joc"
access_token <- "836246147295371264-4bYPgGiBS1iU0L2vxvg2rSvXICWYG9l"
access_secret <- "w8v89nJmHeJTFKCvTQYOmm3OqRUatpyt3Aco4OtNCgmWO"

setup_twitter_oauth(consumer_key = consumer_key, consumer_secret = consumer_secret,
                    access_token = access_token, access_secret = access_secret)

#############################################################
# Get our central user: ego

# Make a dataframe to populate
ego_network <- data.frame(user = character(), follower_name = character())

# Function to create a dataframe of all links between an ego and followers
# @param df: name of df (must already be instantiated)
# @param ego: ego username
# @param n : max number of followers to retrieve
generate_edgelist_from_ego_followers <- function(df, ego_name, n) {
  ego <- getUser(ego_name)

  followers <- ego$getFollowers(n = n)
  
  num_edges <- length(followers)
  
  for (i in 1:num_edges) {
    df <- rbind(df, data.frame(user = ego$screenName, 
                                              follower_name = followers[[i]]$screenName))
  }
  
  return(df)
  
}

# Get initial network of nodes connected to the APSA twitter account
ego_user <- "APSAtweets"

ego_network <- generate_edgelist_from_ego_followers(ego_network, ego_user, 10)

# Get networks of ego's followers
followers_network <- data.frame(user = character(), follower_name = character())

for (i in 1:length(ego_network$follower_name)) {
  temp_ego <- as.character(ego_network$follower_name[i])
  temp_ego_user <- getUser(temp_ego)
  
  # Pause if rate limit has been exceeded
  if (as.numeric(getCurRateLimitInfo("followers")$limit[1]) == 0) {
    Sys.sleep(15 * 60)
  }
    
  # Check if follower has public account; exclude private users
  if (temp_ego_user$protected == FALSE) {
    followers_network <- generate_edgelist_from_ego_followers(followers_network, temp_ego, 10)
  }
  
  else {
    print(paste("Skipping private user", temp_ego$name, sep = " "))
  }
    
}
