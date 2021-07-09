library(lubridate)
library(quantmod)
library(rvest)
#library(RSelenium)
library(tidyverse)


# Create functions required
# Function unlist the single column dateframe and collapse all values into a single value
state_city <- function(state_city){
  state_city <- unlist(state_city) %>% paste(collapse = "|") %>% tolower()  # create a border between each words
  return(state_city)
}

# Function to extract the property type 
p_type <- function(value){
  value <- tolower(value) 
  if (str_detect(value, "for sale|for rent")){ # Returns the True if any of values is detected
    the_match <- str_match(value, "for sale|for rent") # Returns the exact matched value
    p_type <- toupper(the_match)
  } else{
    p_type <- "NA"
  }
  return(p_type)
}

# Function to extract the property name 
p_title <- function(value){
  
  value <- tolower(value)
  if (str_detect(value, "house") ){ # Return "HOUSE" if statement is true
    p_title <- "HOUSE"
  }else if (str_detect(value, "flat")){ # Return "FLAT" if statement is true
    p_title <- "FLAT"
  } else if (str_detect(value,"\\sland\\s|^land ")){ # Return "LAND" if statement is true
    p_title <- "LAND"
  }else {
    p_title <- "OTHERS" # Return "OTHERS" if none of the preceding statements is True
  }
  return(p_title)
}  


# Function to extract state names 
p_state <- function(value){
  value <- tolower(value) 
  if (str_detect(value, states)){ #  
    the_match <- str_match(value, states) # Returns the state name detected in states
    p_state <- toupper(the_match) 
  } else{
    p_state <- toupper(value) # Returns the initial value if the state name not in states
  }
  return(p_state[1]) # Returns the first value
}


# Load all and map multiple csv files into a single dataframe 
df  <- dir("Raw_ppn_data", full.names = TRUE) %>% map_dfr(read_csv)

# To import a single csv file
# df <- read.csv("Raw_ppn_data/1b4173a507fe8bb8fb6c0d62e863e00e_2020-12-21.csv")

# remove duplicates entries
df <- unique(df) 

######################## Begin Data Cleaning and preprocessing  ##########################

# get all 36 states in Nigeria
state_url <- "https://www.nigeriagalleria.com/Nigeria/Nigerian-States-Capital-Governors.html"

States_data <-  read_html(state_url) %>% 
  html_nodes(".col-t-contentgen")%>%
  html_table() %>% .[[1]] 

States_ng <- str_remove(States_data$State ,"State") %>% str_squish()
states <- state_city(States_ng)#Apply state_city functions


# import the city names
# cities_ng <- read_csv("state_city.csv") 
# cities <- state_city(cities_ng) #Apply state_city function 


################# Get current USD to NGN exchange rate #############################
currency_url <-"https://www.xe.com/currencyconverter/convert/?From=USD&To=NGN"
current_rate  <- read_html(currency_url)  %>%  
                 html_nodes(".iGrAod") %>% 
                 html_text() %>% 
                 str_extract(.,"\\d+.\\d+") %>% 
                 as.numeric()


#Extract current xchange rate with Rselenium
#open a selenium instance
# driver <- rsDriver(browser=c("chrome"), chromever = "87.0.4280.88", port=4554L)
# remDr <- driver[["client"]]
# # 
# url <-"https://www.xe.com/currencyconverter/convert/?From=USD&To=NGN"
# remDr$navigate(url)
# link <- read_html(remDr$getPageSource()[[1]])
# current_rate <- link %>% html_nodes(".converterresult-toAmount") %>% html_text() %>% as.numeric()
# remDr$close()
#########################################################

df$price <- str_remove_all(df$price, ",") %>% as.integer() # remove commas and integerize price column
df$currency <- if_else(df$currency == "$",current_rate, 1) # create a currency column
df$price <- as.integer(df$price * df$currency) # Calculate to get same currency in the price column

#Extract Date
pat <- "(?<=Added )\\d{2} [:alpha:]+ \\d+"
df$published_date <- str_extract(df$published_date , pat) %>% dmy() #%>% format(format = "%Y-%m")

# extract the numbers from bedroom, bathrooms $ toilet columns
pat <- "\\d+(?=[:graph:]*)" 

#get numbers of bedrooms
df$bedrooms <- str_extract(df$bedrooms, pat) %>% as.integer()

# get numbers of bathrooms
df$bathrooms <- str_extract(df$bathrooms, pat) %>% as.integer()

# get numbers of toilets
df$toilets <- str_extract(df$toilets, pat) %>% as.integer()

# Apply p_type function to the description column to extract the property type (For sale, for rent, or Others) 
df$type <- sapply(df$description, p_type)


# Apply p_title function to the description column to extract property name ("HOUSE", "LAND",  or "FLAT")
df$title <- sapply(df$description, p_title)

# Extract the city name from the tokenized location data
df$State<- word(df$location, -1) 
df$State<- sapply(df$State, p_state) 

#Select required columns and rearrange
cleaned_df <- select(df,
                    Date = published_date,
                    type,title,location,State,
                    Description = description,
                    price, bedrooms, bathrooms, 
                    toilets
                    ) 


#Save cleaned and process data
write.csv(cleaned_df,"Cleaned_PPN_DATA.csv", row.names = F) 
