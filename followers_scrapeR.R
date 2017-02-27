# Leslie Huang
# Twitter network scraping: How many of a user's followers are connected to each other?

### Set up the workspace
rm(list=ls())
setwd("/Users/lesliehuang/Dropbox/scrapeR/")

set.seed(1234)

libraries <- c("foreign", "utils", "dplyr", "devtools", "ggplot2", "twitteR")
lapply(libraries, require, character.only=TRUE)

# Get these from your API:
# CONSUMER KEY, CONSUMER SECRET, ACCESS TOKEN, ACCESS SECRET

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
ego_network <- generate_edgelist_from_ego_followers(twitter_network_edges, "APSAtweets", 10)

# Get networks of ego's followers
followers_network <- data.frame(user = character(), follower_name = character())

for (i in 1:length(ego_network$follower_name)) {
  temp_ego <- as.character(ego_network$follower_name[i])
  followers_network <- generate_edgelist_from_ego_followers(followers_network, temp_ego, 10)
}

# Function to filter dataframe for only users in the original network