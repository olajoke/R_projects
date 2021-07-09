library(cronR)

cron_clear()
cmd <- cron_rscript("src/process_new_data.R")
cron_add(command = cmd, frequency = "daily", id="update_db", description = "update_db")


