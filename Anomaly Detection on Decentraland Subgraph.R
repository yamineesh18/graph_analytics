rm(list = ls())

library(ghql)
library(jsonlite)
library(dplyr)

# initialize connection to the subgraph
con = GraphqlClient$new(
  url = "https://gateway.thegraph.com/api/f78445eb195e7b8c535adfacba2d5a34/subgraphs/id/GnwyhKp8uQkktC3vgMxWpg9f9qea75WQ6GXTxjW6BbZq"
)
# initialize a new query
graphql_request = Query$new()
# make request to only get 'Estate' data
graphql_request$query('mydata', '{
  sales(first: 1000, where: {searchCategory: "estate"}) {
    buyer
    price
    searchCategory
    seller
    timestamp
    id
  }
}')
# Run query (pull data)
sales = con$exec(graphql_request$queries$mydata)
# convert results to JSON
salesjson = fromJSON(sales)
# Extract JSON to convert to a dataframe
sales_df = as.data.frame(salesjson$data$sales)
dim(sales_df)
head(sales_df)
str(sales_df)
sales_df$price <- as.numeric(sales_df$price)

# Identify Transaction Anomalies
buyers <- with(sales_df, names(table(sales_df$buyer[price > mean(price)])))
sellers <- with(sales_df, names(table(sales_df$seller[price < mean(price)])))

# Identify sales anomalies
sales_anomalies <- sales_df[sales_df$buyer %in% buyers & sales_df$seller %in% sellers,]
anomaly_count <- nrow(sales_anomalies)

# Print results
print(anomaly_count)
