#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(spotifyr)
library(yaml)

config = read_yaml("config.yaml")

Sys.setenv(SPOTIFY_CLIENT_ID = config$client_key)
Sys.setenv(SPOTIFY_CLIENT_SECRET = config$client_secret)

access_token <- get_spotify_access_token()


getID <- function (substr, query) {
  ############################
  # Function to translate
  # search name to Spotify ID
  # returns only TOP 1
  ############################
  
  name = sub(paste(substr, ":"), "", query)
  
  
  id = search_spotify(name,
                      type = substr,
                      authorization = access_token)[1,]
  return (id)
}


#* @Spotify Plumber Example API


#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* Spotify Recommends: get recommendations based on a song or artist
#* @param query string specifying your query; e.g. track:name, artist:name; otherwise, returns an error
#* @post /RecommendMe
function(res, query) {
  if (grepl(":", query, fixed = TRUE)) {
    if (grepl("artist:", query, fixed = TRUE)) {
      out <- tryCatch({
        id = getID("artist", query)
        x = get_recommendations(seed_artists = id$id, authorization = access_token)
        return (list(id, x))
      },
      error = function(cond) {
        res$status <- 400
        return(list(error = "Artist not found."))
      })
      return(out)
    } else if (grepl("track:", query, fixed = TRUE)) {
      out <- tryCatch({
        id = getID("track", query)
        x = get_recommendations(seed_tracks = id$id, authorization = access_token)
        return (list(id, x))
      },
      error = function(cond) {
        res$status <- 400
        return(list(error = "Track not found."))
      })
    } else {
      res$status <- 400
      return(list(error = "Wrong input."))
    }
    
  } else {
    res$status <- 400
    return(list(error = "Please specify if track or artist."))
  }
  
}
