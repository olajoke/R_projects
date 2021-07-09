############################################################################
#                                                                          #
# Topic: Webscrapping property data from a Nigeria Property website        #
# Site name: Propertpro.ng                                                 #
# Domain: https://www.propertypro.ng                                       #                                 #
# ID : PPN                                                                 #
#                                                                          #
############################################################################




# Uncomment the following to install the packages required
#install.packages("digest")
#install.packages("tidyverse")
#install.packages("rvest")


# Load libraries
library(rvest)
library(tidyverse)
library(digest)




# A craw delay function
nynyt <- function(periods = c(1,3)){
  runtime <- runif(1,periods[1],periods[2])
  cat(paste0(Sys.time(),". Sleeping for ", round(runtime,2),"seconds\n"))
  Sys.sleep(runtime)
}



get_ppn_data <- function(ppn){

# date
published_date <-  ppn %>% html_nodes(".listings-property") %>%
                   html_node("h5") %>%
                   html_text() %>%
                   str_squish()
 
# description
description <-  ppn %>% html_nodes(".listings-property") %>%
                   html_node("h2") %>%
                   html_text() %>%
                   str_squish()
  
# location
location <-  ppn %>% html_nodes(".listings-property") %>%
                     html_node("h4") %>%
                     html_text() %>%
                     str_squish()
                     
# bedrooms
bedrooms <-  ppn %>% html_nodes(".fur-areea span:nth-child(1)") %>%
                     html_text() %>%
                     str_squish()
# bathrooms
bathrooms <-  ppn %>% html_nodes(".fur-areea span:nth-child(2)") %>%
                      html_text() %>%
                      str_squish()

# toilets
toilets <-  ppn %>% html_nodes(".fur-areea span~ span+ span") %>%
                    html_text() %>%
                    str_squish()



# currency
currency <- ppn %>% html_nodes(".n50 span:nth-child(1)") %>%
          #html_nodes("span") %>%
          html_text() %>%
          str_squish()

# price data
price <- ppn %>% html_nodes(".n50 span+ span") %>%
           html_text() %>%
           str_squish()


tibble( published_date,
        description,
        location,
        currency,
        price,
        bedrooms,
        bathrooms,
        toilets
)

}




################# Scrape Property for sale data ###############################
url <- "https://www.propertypro.ng/property-for-sale?search=&type=&bedroom=&min_price=&max_price=&page="
 
ppn_url <- read_html(url) 
ppn_pages<- ppn_url %>% html_nodes(".room-sale-area") %>%
                html_nodes(".page-link") %>%
                html_attr("href")
  
page_nums <- ppn_pages[8] %>% str_extract("(?<=page=)\\d+") %>% as.integer()



all_sales_ppn <- map_dfr(1:page_nums, function(page){
  
  cat("starting page",page," now....\n")
  nynyt()
  cat("OPERATION ON PAGE",page," Done!\n")
  cat("\n")
  url <- glue::glue("https://www.propertypro.ng/property-for-sale?search=&type=&bedroom=&min_price=&max_price=&page={page}")
  ppn_url <- read_html(url) 
  ppn<- ppn_url %>% html_nodes(".room-sale-area")
  df <- map_dfr(ppn, get_ppn_data)
  df
})

hash <- digest(as.character(Sys.time()),"md5",serialize = F)
write.csv(all_sales_ppn, paste0("Raw_ppn_data/",hash,"_",Sys.Date(),".csv"), row.names = F )



################# Scrape Property for rent data ###############################

url <- "https://www.propertypro.ng/property-for-rent?search=&type=&bedroom=&min_price=&max_price=&page="
ppn_url <- read_html(url) 
ppn_pages<- ppn_url %>% html_nodes(".room-sale-area") %>%
  html_nodes(".page-link") %>%
  html_attr("href")

page_nums <- ppn_pages[8] %>% str_extract("(?<=page=)\\d+") %>% as.integer()



all_rents_ppn <- map_dfr(1:page_nums, function(page){
  
  cat("starting page",page," now....\n")
  nynyt()
  url <- glue::glue("https://www.propertypro.ng/property-for-rent?search=&type=&bedroom=&min_price=&max_price=&page={page}")
  ppn_url <- read_html(url) 
  ppn<- ppn_url %>% html_nodes(".room-sale-area")
  df <- map_dfr(ppn, get_ppn_data)
  df
})


hash <- digest(as.character(Sys.time()),"md5",serialize = F)
write.csv(all_rents_ppn, paste0("Raw_ppn_data/",hash,"_",Sys.Date(),".csv"), row.names = F )


