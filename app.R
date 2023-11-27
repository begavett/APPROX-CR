#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(workflows)
library(magrittr)
library(dplyr)
library(sjlabelled)
library(sjmisc)
library(vetiver)

# Define UI
ui <- fluidPage(
  
  # Application title
  titlePanel("Generate APPROX-CR Scores to Estimate Cognitive Reserve"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      HTML("Uploaded data must be formatted correctly. Download a data template <a href='https://www.dropbox.com/s/yu1jwxxrfsan7mk/datatemplate.csv?dl=1'> here</a>."),
      p("(You may need to refresh this window after downloading the data template.)"),
      br(),
      br(),
      textInput(inputId = "missing_code",
                label = "Value used to code for missingness in dataset (e.g., -999)",
                value = NA,
                placeholder = "If missing cells are left blank or NA, ignore this box."),
      fileInput(inputId = "userdata",
                label = "Choose file",
                accept = c('text/csv', 
                           'text/comma-separated-values,text/plain', 
                           '.csv'),
                buttonLabel = "Browse...",
                placeholder = "Data must be in .csv format"),
      actionButton("submit",
                   label = "Generate Scores")
    ),
    
    mainPanel(
      uiOutput("downloadButton"),
      br(), br(),
      dataTableOutput('tablePreview')
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  data_out <- eventReactive(input$submit, {
    
    req(input$userdata)
    ext <- tools::file_ext(input$userdata$name)
    validate(need(ext == "csv", "Please upload a .csv file"))
    
    userdata <- read.csv(input$userdata$datapath) %>%
      set_na(na = input$missing_code) %>%
      rename(rid = id,
             cohort = label) %>%
      mutate(bmi = weight_kg / height_m^2,
             pulspres = bpsys - bpdias,
             wh_ratio = waist_cm/hip_cm,
             ABSI = (waist_cm*10) * weight_kg^(-2/3) * height_m^(5/6),
             HI = hip_cm * (weight_kg/73)^-.482 * ((height_m*100)/166)^.310,
             WHI = wh_ratio * weight_kg^(-1/4) * (height_m*100)^(1/2))
    
    out <- readRDS(gzcon(url("https://raw.githubusercontent.com/begavett/APPROX-CR/main/cr_xgb_v.Rds"))) %>%
      augment(userdata)
    
    return(out)
  })
  
  output$tablePreview <- renderDataTable({
    data_out() %>%
      rename(id = rid,
             label = cohort) %>%
      mutate(across(where(is.numeric), \(x) round(x, digits = 2))) %>%
      select(id, label, approx_cr = .pred, everything()) %>%
      datatable()
  })
  
  output$downloadResults <- downloadHandler(
    filename = function() {
      paste0("approx-cr-data-", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(data_out() %>%
                  rename(id = rid,
                         label = cohort) %>%
                  select(id, label, approx_cr = .pred, everything()) %>%
                  replace_na(value = input$missing_code), 
                file)
    }
  )
  
  output$downloadButton <- renderUI({
    req(input$userdata, data_out())
    downloadButton("downloadResults",
                   label = "Download APPROX-CR Scores") 
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
