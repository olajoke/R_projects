library(httr)
library(jsonlite)
library(RPostgres)
library(RPostgreSQL)
library(DBI)
library(dplyr)

# using Package Keyring to secure Database Password and Username
install.packages('keyring')
library(keyring)

key_set(service = 'demo', username = 'postgres')

#################################################
#in every 24 hours
#connect to db

# 
conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  host = db_ipAddress, 
  port = 5432,
  user = username,
  password = key_get('demo', username)
  )




#pull new data of the last 24 hours
new_add <- data.frame(dbGetQuery(conn, "SELECT * FROm raw_customer_data WHERE created_at >= NOW() - '1 day'::INTERVAL"))

#remove timestamp
new_add <- new_add %>% 
  subset(select = -c(created_at))

#pass to back end model
a <- paste0('{"new_data":', jsonlite::toJSON(new_add), '}', sep = '')
class(a) <- "json"

req <- httr::POST(
  url = paste0("http://", e, ":", p, "/__swagger__/"),
  path = "credit_predict",
  httr::accept_json(),
  body = a,
  httr::write_disk("response.json", overwrite = TRUE))

result <- jsonlite::fromJSON(httr::content(req, as = "text"))

result <- result %>% 
  rename(no = No, yes = Yes)
    
new_processed_customer_data <- cbind(new_add, result)
dbWriteTable(conn, "customer_data", new_processed_customer_data, row.names=FALSE, append = TRUE)

dbDisconnect(conn)