#


#* Sort df
#* @param df
#* @serializer json
#* @post /credit_predict

function(new_data) {
  
  super_model <- readr::read_rds("gbtree.rds")
  
  predict(super_model, new_data, type = "prob")

  }



#################################################################################################################




