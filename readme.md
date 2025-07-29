### **README for Data Analysis and R Graphics - Crime Data Analysis Case Study**

---

#### **Project Overview:**

This project focuses on **crime data analysis** and **visualization**. The primary goal is to explore the relationship between **crime rates** and **police stations** in Nigeria across various states. The data includes information on various crimes, police stations, and their respective locations. We use **R programming** to clean, process, analyze, and visualize the data, demonstrating practical applications of **Exploratory Data Analysis (EDA)**, **data cleaning**, and **data visualization**.

---

### **1. Data Source:**

The data for this project is sourced from the **2017 Crime Statistics in Nigeria**. It contains multiple sheets:

1. **Offences Against Lawful Authority** - Crime data across various Nigerian states.
2. **Area Commands, Divisions** - Information about police stations and posts in various states.

The analysis compares **crime rates** (total crimes) against the **number of police stations** in each state to identify trends, potential correlations, and outliers.

---

### **2. Data Preprocessing and Cleaning:**

* **Reading Data**: The data is read from an Excel file using the **`readxl`** package.
* **Cleaning Data**:

  * The **`janitor`** package is used to clean column names.
  * **Missing Data**: Rows with **missing values** in `police_stations` are handled by replacing `"NIL"` with `NA` and converting the columns to numeric types.
  * **Data Merging**: The crime data and police data are merged based on the state name to create a unified dataset.

### **3. Data Analysis Process:**

* **Summing Crimes**: For each state, the total number of crimes across three categories (**crimes against persons, property, and authority**) is calculated using `rowSums()`.
* **Crime Rate Calculation**: The **crime rate per police station** is calculated by dividing the total number of crimes by the number of police stations in each state.

---

### **4. Data Visualization:**

We create multiple visualizations to explore the data and identify key insights:

1. **Bar Plot of Total Offences by State**:

   * A **bar plot** is used to show the total number of offences in each state.
   * **`ggplot2`** is used to create the plot with the `geom_bar()` function.

2. **Heatmap of Offences by State and Offence Type**:

   * A **heatmap** is created to show how various types of offences are distributed across states.
   * **`geom_tile()`** is used in `ggplot2` to visualize the intensity of each offence type.

3. **Scatter Plot to Compare Crime Rate and Number of Police Stations**:

   * A **scatter plot** is used to compare the **crime rate** (total crimes) against the **number of police stations** in each state.
   * A **linear regression line** is added using **`geom_smooth()`** to identify trends.

4. **Final Scatter Plot with Enhanced Visuals**:

   * A final **scatter plot** is created with enhanced visuals using the **`viridis`** color palette for better readability and clarity. Points are colored by state, and the size is determined by the number of total crimes.

---

### **5. Code Breakdown:**

#### **Reading and Cleaning Data:**

```r
crime_data <- read_excel(file_path, sheet = "Offences Against Lawful Auth.", skip = 1)
crime_data <- clean_names(crime_data)
crime_data$total_offences <- rowSums(crime_data[, 2:10], na.rm = TRUE)
```

#### **Merging Data:**

```r
merged_data <- merge(crime_data, police_data, by.x = "state", by.y = "zonal_hq", all.x = TRUE)
```

#### **Creating Visualizations:**

* **Bar Plot**:

```r
plot_bar <- ggplot(crime_data, aes(x = state, y = total_offences)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Total Offences by State", x = "State", y = "Total Offences")
ggsave("offences_plot.png", plot = plot_bar)
```

* **Heatmap**:

```r
data_long <- crime_data %>% pivot_longer(cols = -state, names_to = "offence_type", values_to = "offence_count")
plot_heatmap <- ggplot(data_long, aes(x = offence_type, y = state, fill = offence_count)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Heatmap of Offences by State and Offence Type", x = "Offence Type", y = "State")
ggsave("offences_heatmap.png", plot = plot_heatmap, width = 10, height = 6, units = "in")
```

* **Scatter Plot**:

```r
plot_scatter <- ggplot(merged_data, aes(x = total_offences, y = police_stations)) +
  geom_point(aes(color = state), size = 3, alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +  
  labs(title = "Relationship Between Crime Rate and Number of Police Stations",
       x = "Total Offences", y = "Police Stations")
ggsave("crime_vs_police_stations.png", plot = plot_scatter, width = 10, height = 6, units = "in")
```

---

### **6. Insights and Conclusions:**

* The **bar plot** provides a clear comparison of the **total crimes** reported across different states.
* The **heatmap** shows how different types of crimes vary across states.
* The **scatter plot** helps analyze the relationship between **crime rates** and the **number of police stations** in each state. A **linear regression line** is added to highlight trends.

---

### **7. Files Produced:**

* `offences_plot.png`: Bar plot of total offences by state.
* `offences_heatmap.png`: Heatmap showing offences by type and state.
* `crime_vs_police_stations.png`: Scatter plot comparing total crimes vs. police stations.

---

### **8. Conclusion:**

This analysis and visualization provide valuable insights into the relationship between **crime statistics** and **police resources** across Nigerian states. It highlights the distribution of different types of offences, the total crimes per state, and the comparison between crime rates and police stations. The visualizations make it easier to identify trends and anomalies in the data.

---

### **9. Future Steps:**

* Further analysis can be performed to assess the impact of **police presence** on crime reduction.
* More granular data, such as the types of crimes in relation to population density or economic factors, could improve insights.

---

### **End of README**

Let me know if you need further edits or additional sections in the README!
