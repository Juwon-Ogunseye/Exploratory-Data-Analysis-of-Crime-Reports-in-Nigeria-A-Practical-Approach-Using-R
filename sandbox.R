library(readxl)
library(janitor)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(viridis)

file_path = "/home/juwon/Exploratory-Data-Analysis-of-Crime-Reports-in-Nigeria-A-Practical-Approach-Using-R/CRIME STATISTICS 2017.xlsx"

crime_data <- read_excel(file_path, sheet = "Offences Against Lawful Auth.", skip = 1)
crime_data <- clean_names(crime_data)
police_data <- read_excel(file_path, sheet = "Area Commands,divisions......", skip = 1)
police_data <- clean_names(police_data)
crime_data$total_offences <- rowSums(crime_data[, 2:10], na.rm = TRUE)

print(colnames(crime_data))
print(colnames(police_data))

merged_data <- merge(crime_data, police_data, by.x = "state", by.y = "zonal_hq", all.x = TRUE)

print(head(merged_data))

plot_bar <- ggplot(crime_data, aes(x = state, y = total_offences)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Total Offences by State", x = "State", y = "Total Offences")
print(plot_bar)
ggsave("offences_plot.png", plot = plot_bar)

data_long <- crime_data %>%
  pivot_longer(cols = -state, names_to = "offence_type", values_to = "offence_count")

plot_heatmap <- ggplot(data_long, aes(x = offence_type, y = state, fill = offence_count)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Heatmap of Offences by State and Offence Type", x = "Offence Type", y = "State")
print(plot_heatmap)
ggsave("offences_heatmap.png", plot = plot_heatmap, width = 10, height = 6, units = "in")

plot_scatter <- ggplot(merged_data, aes(x = total_offences, y = police_stations)) +
  geom_point(aes(color = state), size = 3, alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +  
  labs(title = "Relationship Between Crime Rate and Number of Police Stations",
       x = "Total Offences",
       y = "police_stations") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(plot_scatter)

ggsave("crime_vs_police_stations.png", plot = plot_scatter, width = 10, height = 6, units = "in")

crime_data <- read_excel(file_path, sheet = "Summary", skip = 2, col_names = FALSE)
crime_data <- data.frame(
  state = crime_data[[1]],  
  against_persons = as.numeric(crime_data[[2]]),
  against_property = as.numeric(crime_data[[3]]),
  against_authority = as.numeric(crime_data[[4]])
)

police_data <- read_excel(file_path, 
                         sheet = "Area Commands,divisions......", 
                         skip = 2, 
                         col_names = FALSE)
police_data <- data.frame(
  state = police_data[[2]],
  police_stations = police_data[[6]]
)

police_data$police_stations <- ifelse(police_data$police_stations == "NIL", NA, police_data$police_stations)
police_data$police_stations <- as.numeric(police_data$police_stations)
police_data <- police_data[!is.na(police_data$police_stations) & !is.na(police_data$state), ]

merged_data <- merge(crime_data, police_data, by = "state")
merged_data$total_crimes <- rowSums(merged_data[, c("against_persons", "against_property", "against_authority")], na.rm = TRUE)
merged_data$crimes_per_station <- merged_data$total_crimes / merged_data$police_stations

ggplot(merged_data, aes(x = police_stations, y = total_crimes)) +
  geom_point(aes(size = total_crimes, fill = state), 
             shape = 21, color = "white", alpha = 0.8, stroke = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "red3", linetype = "dashed", size = 1) +
  geom_text(aes(label = ifelse(total_crimes > median(total_crimes), state, "")),
            hjust = -0.1, vjust = 0.5, size = 3, color = "black") +
  scale_x_continuous(limits = c(0, max(merged_data$police_stations, na.rm = TRUE) * 1.1),
                   name = "Number of Police Stations") +
  scale_y_continuous(labels = comma, 
                    limits = c(0, max(merged_data$total_crimes, na.rm = TRUE) * 1.1),
                    name = "Total Crimes Reported") +

  scale_fill_viridis_d(option = "plasma", guide = "none") +
  scale_size_continuous(range = c(3, 12), guide = "none") +
  labs(title = "Police Resources vs Crime Volume (2017)",
       subtitle = "Each point represents a Nigerian state",
       caption = paste("Correlation:", round(cor(merged_data$police_stations, 
                                               merged_data$total_crimes, use = "complete.obs"), 3))) +
  theme_minimal(base_size = 12) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white"),
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16, color = "black"),
    plot.subtitle = element_text(size = 12, color = "black"),
    axis.title = element_text(color = "black", size = 12),
    axis.text = element_text(color = "black"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  )

ggsave("police_vs_crimes_improved.png", width = 10, height = 8, dpi = 300, bg = "white")

cat("Analysis complete. Visualization saved as 'police_vs_crimes_improved.png'\n")
cat("States with highest crime-to-station ratios:\n")
print(head(merged_data[order(-merged_data$crimes_per_station), c("state", "crimes_per_station")], 5))