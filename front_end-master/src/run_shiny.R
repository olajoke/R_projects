data <- read.csv("src/data.csv")

run_shiny_front <- function(external_ip,port){
    
    # Load data sample
    data <- read.csv("src/data.csv")
    
    options(shiny.host = "0.0.0.0", shiny.port = 3838)
    
    ui <- shinyUI(fluidPage(theme = shinythemes::shinytheme("flatly"),
                      tagList( useShinyjs(),
                               navbarPage("Churn Risk Accessment App", id = "navbar",
                                          collapsible = TRUE,
                                          position = "fixed-top",
                                          windowTitle = "Churn-Prediction",
                                          header =  tags$style("body {padding-top: 75px;}"),
                                          tabPanel("Dashboard",
                                                   tabsetPanel(
                                                       tabPanel("Overview", 
                                                                div(align = "center",
                                                                    tags$iframe( height=1200, width= 1500,frameborder="0", scrolling="no",style="border:0; overflow:hidden;",
                                                                                 src="https://datastudio.google.com/embed/reporting/d6bee4ef-e9a2-4c34-87cc-e4cd9285a3c9/page/0mVmB"))
                                                       )
                                                   ) #tabsetPanel ends
                                          ), #tabPanel Dasboard ends
                                          tabPanel("Prediction",
                                                   fluidRow(column(12, #style = "background-color:	#d8d8d8;",
                                                                   div(align = "center", h2("Predict the customer's churn probability")),
                                                                   #fluidRow(style = " height:350px;"),
                                                                   fluidRow( 
                                                                       column(4),
                                                                       column(4,
                                                                              div(class="panel panel-default",
                                                                                  div(class="panel-body",style = "background-color:	#d8d8d8;",
                                                                                      div(
                                                                                          id = "form",
                                                                                          div(align = "center",helpText(h5("Answer the following questions carefully to predict churn probability of the customer"))),
                                                                                          shiny::hr(),
                                                                                          
                                                                                          div(style="display: inline-block;vertical-align:top;",h5(tags$b("Credit Score:")), selected='mean'),
                                                                                          div(style="display: inline-block;vertical-align:top; width: 60%;",numericInput("credit_score", NULL, max = max(data$credit_score), min = min(data$credit_score), value = 0 )),
                                                                                          tags$br(),
                                                                                          
                                                                                          sliderInput("tenure", "What is the customer's tenure:",1, max = max(data$tenure), 2, 1),
                                                                                          
                                                                                          
                                                                                          
                                                                                          div(style="display: inline-block;vertical-align:top;",h5(tags$b("Customer's Age:")), selected='mean'),
                                                                                          div(style="display: inline-block;vertical-align:top; width: 60%;",numericInput("age", NULL, min = 18, max = 100, value = 34)),tags$br(),
                                                                                          
                                                                                          div(style="display: inline-block;vertical-align:top;",h5(tags$b(" Client's Location:")), selected='mean'),
                                                                                          div(style="display: inline-block;vertical-align:top; width: 60%;",selectInput("geo_location", NULL,choices = 
                                                                                                                                                                            unique(data$geo_location)
                                                                                          )),tags$br(),
                                                                                          
                                                                                          
                                                                                          
                                                                                          sliderInput("num_products", "How many product(s) does the customer have?", 1, max = max(data$num_products), 2, 1),
                                                                                          
                                                                                          div(style="display: inline-block;vertical-align:top;",h5(tags$b("Enter the customer's annual income:")), selected='mean'),
                                                                                          div(style="display: inline-block;vertical-align:top; width: 60%;",numericInput("est_salary", NULL, value = 0)), tags$br(),
                                                                                          
                                                                                          div(style="display: inline-block;vertical-align:top;",h5(tags$b("What is the current balance:")), selected='mean'), tags$br(),
                                                                                          div(style="display: inline-block;vertical-align:top; width: 55%;",numericInput("balance", NULL, value = 0)),
                                                                                          
                                                                                          prettyRadioButtons( "gender", "Gender",choices = c("Female", "Male"), inline = TRUE,fill = TRUE),
                                                                                          shiny::hr(),
                                                                                          prettyCheckbox("is_active_member","Is the customer an active member?", value = FALSE, icon = icon("check"),animation = "rotate"),
                                                                                          prettyCheckbox("has_card","Does the customer have a card?", value = FALSE, icon = icon("check"), animation = "rotate"),
                                                                                          div( align ="center",actionBttn("submit",label = "Submit",style = "gradient", icon = icon("thumbs-up")))
                                                                                      )),
                                                                                  bsModal(id = "result", title = "Prediction Result for", trigger = "submit", 
                                                                                          size = "medium", div(align ="center",withSpinner(textOutput("note"), type = 0)), br(),
                                                                                          div(align="center", withSpinner(tableOutput("text")), shiny::hr(),  div(align = "center", actionLink("save_btn", "Save to potential customers list",icon = icon("upload"))))
                                                                                  ) # bsmodal ends
                                                                                  
                                                                              )),
                                                                       column(4)
                                                                   )
                                                   ))
                                          ), # tabpanel for predictionpage ends
                                          tabPanel("Query",
                                                   fluidRow(column(12,div(align = "center", h2("Query Customer Information Database")))),
                                                   fluidRow(column(3),
                                                            column(6, div(class="panel panel-default",
                                                                          div(class="panel-body",style = "background-color:	#d8d8d8;",
                                                                              tags$style(".selectize-input {min-height: 38px;}"),
                                                                              div(align = "center",helpText(h5("Enter a valid customer ID to get result"))),
                                                                              shiny::hr(),
                                                                              numericInput(
                                                                                  inputId = "get_query",
                                                                                  label = "search by customer ID...",
                                                                                  value = NA,
                                                                                  width = "100%"),
                                                                              div(align ="center", 
                                                                                  actionBttn("search","Request",color="primary",style ="jelly",icon =icon("search"))
                                                                              )
                                                                              
                                                                          ))
                                                            ), #column 8 ends
                                                            column(3)),
                                                   hidden(
                                                       div(id = "result_column",
                                                           fluidRow(style = " height:50px;"),
                                                           shiny::hr(),
                                                           fluidRow(column(12, div(#align = "Left",
                                                               h3("Search Result(s)")))),
                                                           fluidRow(DT::dataTableOutput("requestDT"))
                                                       )
                                                       )  #hidden function end
                                          ) # tabPanel query ends
                               ) # navbarpage ends
                      ) # tagsList ends
     ) # fluidpage ends
    ) # shinyUI ends
    
    

        
        
        
        # Define server logic required to draw a histogram
        server <- shinyServer(function(input, output, session, e = external_ip, p =  port) {
            
            drv <- dbDriver("PostgreSQL")
            
            
#------------------------------------------------------functions-------------------------------------------#
            
zero_one <-function(x) {# To convert a Logic input to 1 (if TRUE) or 0 (if FALSE)
            if (x == TRUE) {
              return(x = 1)
            }else {
              return(x = 0)
            }
          }
 
churn_value <- function(x){ # returns the column name with the highest value in uppercase 
                if (x[,1] > x[,2]){
                  df <- x[1]
                }else{
                  df <- x[2]
                }
                value <- df%>%colnames()%>%toupper()
                return(value)
              }           


`%notin%` <- Negate(`%in%`) # a not in function
 
            
#--------------------------------------------set constraints-------------------------------------------------------------#
            observe({
                # constrain age
                if (input$age < 18 || input$age > 120 || is.na(input$age))
                    showModal(
                        modalDialog(
                            title = "Warning!",
                            "The age entered is oustside the specified range. Please enter a value between 18-120 years",
                            easyClose = TRUE
                        )
                    )
            })
            
            
            observe({
                if (class(input$credit_score) %notin% c("numeric", "integer")) {
                    disable("submit")
                } else {
                    enable("submit")
                }
            })
            
            observe({
                if (class(input$age) %notin% c("numeric", "integer")) {
                    disable("submit")
                } else {
                    enable("submit")
                }
            })
            
            observe({
                if (class(input$balance) %notin% c("numeric", "integer")) {
                    disable("submit")
                } else {
                    enable("submit")
                }
            })
            
            observe({
                if (class(input$est_salary) %notin% c("numeric", "integer")) {
                    disable("submit")
                } else {
                    enable("submit")
                }
            })
            
            observe({
              if (class(input$get_query) %notin% c("integer")) {
                disable("search")
              } else {
                enable("search")
              }
            })
            
            
#--------------------------------------------------predict a churn on submissions----------------------------------------#
            
text_output <- eventReactive(input$submit, {
                
                potential <- data.frame("credit_score" = as.numeric(input$credit_score), "geo_location" = as.factor(input$geo_location),
                                        "gender" = input$gender, "age" = input$age, "tenure" = as.numeric(input$tenure),
                                        "balance" = as.numeric(input$balance), "num_products" = as.numeric(input$num_products),
                                        "has_card" = as.factor(zero_one(input$has_card)), "is_active_member" = as.factor(zero_one(input$is_active_member)),
                                        "est_salary" = as.numeric(input$est_salary))
                
                new_data <- paste0('{"new_data":', jsonlite::toJSON(potential), '}', sep = '')
                class(new_data) <- "json"
                
                # text_output <- reactive({
                    r <- httr::POST(
                        url = paste0("http://", e, ":", p, "/__swagger__/"),
                        path = "credit_predict",
                        body = new_data,
                        httr::write_disk("response_potential.json", overwrite = TRUE)
                    )
                    result <- jsonlite::fromJSON(content(r, "text"))
                    
                # })
  
                # create a table from result
                #     output$text = renderTable({ Output }) #output$text ends
                
                
            })  # observentEvent Submit ends
                
#------------------------------------------- generate text and table from result----------------------------------#
           
output$note = renderText({ # create a text result
               Output <- text_output()
               paste0("The predicted result for this potential customer is a ",churn_value(Output), " TO CHURN. The table below gives further details:")
                    #paste0("The predicted result for this potential customer is ",toupper(Output[,1]), " to churn", ". The table below gives further details:")
              
               })

output$text <- renderTable({ # create a table result
               text_output()  
               })
            
            
#----------------------------------------- option to save predicted to potential_customer db----------------------#
            
observeEvent(input$save_btn,{
                
                disable("save_btn")
                
                conn <- dbConnect(
                    drv,
                    dbname = "postgres",
                    host = "34.76.144.177",
                    port = 5432,
                    user = "postgres",
                    password = "yJKLI8gyEkGgJ71I")
                
                IdPlusOne <- sum(dbGetQuery(conn, "SELECT MAX(customer_id) FROM churn_yesno"), 1)
                
                result <- text_output() 
                result <- result %>% 
                    rename(no = No, yes = Yes)
                
                df_upload <- data.frame("customer_id" = as.integer(IdPlusOne), "credit_score" = input$credit_score,
                                        "geo_location" = input$geo_location, "gender" = input$gender,
                                        "num_products" = input$num_products,
                                        "age" = input$age, "tenure"= input$tenure, "balance" = input$balance,
                                        "has_card" = zero_one(input$has_card), "is_active_member" = zero_one(input$is_active_member),
                                        "est_salary" = input$est_salary)
                
                df_upload <- cbind(df_upload, result)
                
                dbWriteTable(conn, 'potential_customer', df_upload, row.names=FALSE, append=TRUE)
                
                #attend to constraints
                if(IdPlusOne == dbGetQuery(conn, "SELECT MAX(customer_id) FROM potential_customer")) {
                    sendSweetAlert(session = session,title = "Completed!!", text = "Query Successfully saved to Database",type = "success")
                }else{
                    sendSweetAlert(session = session,title = "Error!!", text = "Submission Failed. Try again!",type = "error")
                }
                
                reset("form")
          })
            
#--------------------------------get exist customer info from database by search via customer_id--------------------------------------#
            
            result_df <- eventReactive(input$search,{
                
                drv <- dbDriver("PostgreSQL")
                
                conn <- DBI::dbConnect(
                    drv,
                    dbname = "postgres",
                    host = "34.76.144.177",
                    port = 5432,
                    user = "postgres",
                    password = "yJKLI8gyEkGgJ71I")
                
                get_query <- as.numeric(input$get_query)
                request_df <- dbGetQuery(conn, paste0("SELECT * FROM churn_yesno WHERE customer_id = '", get_query ,"'"))
                dbDisconnect(conn)
                request_df
            })
            
            observe({
                if(length(result_df()) == 0){
                    hide("result_column")
                    sendSweetAlert(session = session,title = "Oops!!", text = "The customer ID provided is either invalid or does not exit! Try again",type = "warning")
                    #alert("The customer id is either invalid or does not exit!. Try again...")
                }else{shinyjs::show("result_column")}
            })
            
            # output$request <- renderTable({
            #     #DT::renderDataTable({
            #     result_df()#DT::datatable(result_df(), options = list(searching = FALSE, lengthChange = FALSE))
            # })
            
            output$requestDT <- DT::renderDataTable({
                DT::datatable(result_df(), options = list(searching = FALSE, lengthChange = FALSE))
            })
            
            
}) # shinyServer function ends
    
 shinyApp(ui, server) #unite ui and server function to create a shiny app
 
}