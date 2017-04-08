# Leslie Huang
# Twitter network scraping: How many of a user's followers are connected to each other?

### Set up the workspace
rm(list=ls())
setwd("/Users/lesliehuang/Dropbox/twitter-scrapeR/")

set.seed(1234)

libraries <- c("foreign", "utils", "dplyr", "devtools", "ggplot2", "twitteR", "igraph")
lapply(libraries, require, character.only=TRUE)

devtools::install_github("leslie-huang/twitterNetworkGraphR/")
library("twitterNetworkGraphR")

# Get these from the API:
# Don't have the API? Make an app at https://apps.twitter.com/
# CONSUMER KEY, CONSUMER SECRET, ACCESS TOKEN, ACCESS SECRET

setup_twitter_oauth(consumer_key = consumer_key, consumer_secret = consumer_secret,
                    access_token = access_token, access_secret = access_secret)

#############################################################
#############################################################

# Some basics of how to use the TwitteR package (not mine)

# Get a user object
user <- getUser("MelvilleHouse")

# Basic info about this user
user$id
user$screenName
user$description
user$protected
user$location

# How many friends/followers and who are they?
user$followersCount
user$friendsCount
user$getFollowers(n = 10) # Note that if this user has 1 million followers, this counts as only 1 API call!
user$getFriends(n = 10)

# Important notes about the rate limit for API calls
# https://dev.twitter.com/rest/public/rate-limiting
# Basically: 15 API calls every 15 minutes.
# My package is designed to sleep for 15 minutes when you run out of API calls.

# What counts as an API call?
# Different rate limits
# Don't get blacklisted

#############################################################
#############################################################

# My package: You can get the latest version on my GitHub

### Test on a user with 0 followers
ego_user <- "lsh2114"

# Get ego's first degree network of followers
ego_network <- twitterNetworkGraphR::generate_ego_follower_edgelist(ego_user)

# Get 2nd degree followers of the ego network
alters_network <- twitterNetworkGraphR::generate_alters_followers(ego_network, 2, 17, 50)

### Test on a large user
ego_user <- "APSAtweets"

# Let's get 20 followers of APSA
ego_network <- twitterNetworkGraphR::generate_ego_follower_edgelist(ego_user, n = 20)

# Let's look at what we've scraped. Keep in mind that if you are only scraping a first degree network of 1 user, it counts as 1 API call even if that user has 1 million followers. The reason to limit the number of 1st degree followers is if you need to get 2nd degree followers through all of them.
View(ego_network)

### 2nd degree followers
# Let's get 100 followers for each of those 20
# See the documentation for the arguments this function takes
alter_network <- twitterNetworkGraphR::generate_alters_followers(ego_network, 2, 20, 20)


# Note that the API automatically skips over dead accounts.
# If a private user follows the ego user, that edge will be scraped.
# But if you attempt to scrape the followers of the private user, they will automatically be skipped over.


# The output
View(alter_network)


#############################################################
#############################################################
# Now, to igraph

APSA_followers <- graph.data.frame(rbind(alter_network, ego_network), directed = TRUE)

# Look at the nodes
V(APSA_followers)

# Look at the mean edges per vertex
mean(degree(APSA_followers))

# Visualize it

# We want different colors for 1st and 2nd degree followers
palette <- c("red", "black")

V(APSA_followers)$color <- palette[V(APSA_followers)$degree_n]

V(APSA_followers)$label <- NA # we don't want node labels cluttering up the graph

V(APSA_followers)$size <- 1 / V(APSA_followers)$degree_n

plot(APSA_followers)

# Add a legend
legend(x = -5, y = -5, c("1st degree followers", "2nd degree followers"), pt.bg = palette, pch = 21, pt.cex = 2, ncol = 1)
