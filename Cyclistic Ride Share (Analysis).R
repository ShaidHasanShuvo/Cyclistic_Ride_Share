#installing important packages
install.packages('tidyverse')
library(tidyverse)

# Load the ggplot2 package
library(ggplot2)

# Load data
trip_data <- read.csv('Cyclistic Bike Share_csv.csv')

# Having a glance at the data set
head(trip_data)
str(trip_data)
colnames(trip_data)
glimpse(trip_data)


## Calculate average trip length for each age group and user type
average_trip_length <- trip_data %>%
  group_by(usertype, agegroup) %>%
  summarise(avg_trip_length = mean(trip_length_minute))

# Plot for Subscriber with labels
ggplot(average_trip_length %>% filter(usertype == "Subscriber"), aes(x = agegroup, y = avg_trip_length)) +
  geom_bar(stat = "identity", fill = "#F8766D", color = "black") +
  geom_text(aes(label = round(avg_trip_length, 2)), 
            vjust = -0.5, 
            size = 3, 
            position = position_dodge(width = 0.9)) +  # Adjust label position and size as needed
  labs(title = "Average Trip Length by Age Group (Subscriber)",
       x = "Age Group",
       y = "Avg Trip Length (minutes)") +
  theme_minimal()

# Plot for Customer with labels
ggplot(average_trip_length %>% filter(usertype == "Customer"), aes(x = agegroup, y = avg_trip_length)) +
  geom_bar(stat = "identity", fill = "#00BFC4", color = "black") +
  geom_text(aes(label = round(avg_trip_length, 2)), 
            vjust = -0.5, 
            size = 3, 
            position = position_dodge(width = 0.9)) +  # Adjust label position and size as needed
  labs(title = "Average Trip Length by Age Group (Customer)",
       x = "Age Group",
       y = "Avg Trip Length (minutes)") +
  theme_minimal()

## Total Number of users each age group and user type
customer_counts <- trip_data %>%
  group_by(agegroup, usertype) %>%
  summarise(total_customers = n())

# Plot stacked bar chart
ggplot(customer_counts, aes(x = agegroup, y = total_customers, fill = usertype)) +
  geom_bar(stat = "identity") +
  labs(title = " Total Users by Age Group and User Type",
       x = "Age Group",
       y = "",
       fill = "User Type") +
  theme_minimal()


## Group data by user type and day type, then calculate the average trip length
avg_trip_length <- trip_data %>%
  group_by(usertype, daytype) %>%
  summarise(avg_trip_length = mean(trip_length_minute))


# Plot grouped bar chart with labels
ggplot(avg_trip_length, aes(x = usertype, y = avg_trip_length, fill = daytype)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = round(avg_trip_length, 2)), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, 
            size = 3) +  # Adjust label position and size as needed
  labs(title = "Average Trip Length by User Type and Day Type",
       x = "User Type",
       y = "Average Trip Length (minutes)",
       fill = "Day Type") +
  theme_minimal()

# Calculate the percentage of each user type
user_type_percentage <- trip_data %>%
  group_by(usertype) %>%
  summarise(total_trips = n()) %>%
  mutate(percentage = total_trips / sum(total_trips) * 100)

# Plot pie chart with labels
ggplot(user_type_percentage, aes(x = "", y = percentage, fill = usertype, label = paste0(round(percentage), "%"))) +
  geom_bar(stat = "identity", width = 1) +
  geom_text(position = position_stack(vjust = 0.5), color = "white") +
  coord_polar("y", start = 0) +
  labs(title = "Percentage of User Types",
       fill = "User Type",
       x = NULL,
       y = NULL) +
  theme_void() +
  theme(legend.position = "right")


# Filter data for valid trip hours
trip_data <- trip_data %>% filter(!is.na(trip_hour))

# Group data by user type and trip hour, then count the number of trips
peak_hours <- trip_data %>%
  group_by(usertype, trip_hour) %>%
  summarise(total_trips = n())

# Plot peak hours for each user type with labels
ggplot(peak_hours, aes(x = trip_hour, y = total_trips, color = usertype)) +
  geom_line() +
  geom_text(data = peak_hours %>% group_by(usertype) %>% top_n(1, total_trips),
            aes(label = total_trips), vjust = -0.5, hjust = -0.5, color = "black", size = 3) +
  labs(title = "Peak Hours for User Types",
       x = "Trip Hour",
       y = "Total Trips",
       color = "User Type") +
  theme_minimal()

## Popular routes

# Count occurrences of each route
route_counts <- trip_data %>%
  count(trip_route) %>%
  arrange(desc(n)) %>%
  head(10)

# Plot top 10 popular routes with labels
ggplot(route_counts, aes(x = reorder(trip_route, n), y = n)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_text(aes(label = n), vjust = -0.5, size = 3, color = "black") +
  coord_flip() +
  labs(title = "Top 10 Popular Routes",
       x = "Route",
       y = "Number of Trips") +
  theme_minimal()

# Count occurrences of each route by user type
route_counts <- trip_data %>%
  count(trip_route, usertype) %>%
  group_by(usertype) %>%
  arrange(usertype, desc(n)) %>%
  mutate(rank = row_number()) %>%
  filter(rank <= 10)

# Plot stacked bar charts for top 10 popular routes by user type with labels
ggplot(route_counts, aes(x = trip_route, y = n, fill = usertype, label = n)) +
  geom_bar(stat = "identity") +
  geom_text(position = position_stack(vjust = 0.5), color = "white") +
  labs(title = "Top 10 Popular Routes by User Type",
       x = "Route",
       y = "Number of Trips",
       fill = "User Type") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  facet_wrap(~ usertype, scales = "free_y", nrow = 2)



