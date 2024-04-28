# Load necessary libraries
library(readxl)
library(openxlsx)
library(dplyr)
library(ggplot2)

# Error handling for file existence and data consistency
if (!file.exists("Book1.xlsx") || !file.exists("Book2.xlsx")) {
  stop("Error: Excel files not found!")
}

# Attempt to execute the main code block with error handling
tryCatch({
  # Read data from Excel files for graph1 and graph2
  graph_data1 <- read_excel("Book1.xlsx")
  graph_data2 <- read_excel("Book2.xlsx")
  
  # Check for required columns
  required_columns <- c("Bin centre (nm)", "Concentration average", "Standard Error")
  if (!all(required_columns %in% names(graph_data1)) ||
      !all(required_columns %in% names(graph_data2))) {
    stop("Error: One or more required columns are missing in the input files.")
  }
  
  # Selecting relevant columns for graph1 and graph2
  graph1 <- graph_data1[, required_columns]
  graph2 <- graph_data2[, required_columns]
  
  # Merge the datasets using a full join to ensure all peaks are captured
  all_peaks <- full_join(graph1, graph2, by = "Bin centre (nm)", suffix = c(".untreated", ".treated"))
  
  # Calculate the estimated EV population based on the concentration differences
  ev_population <- all_peaks %>%
    mutate(EV_Concentration = `Concentration average.untreated` - `Concentration average.treated`,
           EV_SE = sqrt(`Standard Error.untreated`^2 + `Standard Error.treated`^2)) %>%
    filter(EV_Concentration > 0) %>%
    select(`Bin centre (nm)`, EV_Concentration, EV_SE)
  
  # Output the EV population to an Excel file
  write.xlsx(ev_population, file = "ev_population.xlsx")
  
  # Calculate summary data including total concentration and standard deviation
  total_concentration <- sum(ev_population$EV_Concentration, na.rm = TRUE)
  total_se <- sqrt(sum(ev_population$EV_SE^2, na.rm = TRUE))  # Propagate error for total concentration
  
  summary_data <- ev_population %>%
    summarise(Average_Concentration = mean(EV_Concentration, na.rm = TRUE),
              Average_Particle_Size = weighted.mean(`Bin centre (nm)`, EV_Concentration, na.rm = TRUE),
              Average_SE = mean(EV_SE, na.rm = TRUE),
              Total_Concentration = total_concentration,
              Total_SE = total_se)  # Include total concentration and standard deviation in summary
  
  # Output summary data to an Excel file
  write.xlsx(summary_data, file = "ev_summary_data.xlsx")
  # Calculate plot limits
  x_min <- min(non_zero_data$`Bin centre (nm)`, na.rm = TRUE)
  x_max <- max(non_zero_data$`Bin centre (nm)`, na.rm = TRUE)
  y_min <- min(non_zero_data$`Concentration average`, na.rm = TRUE)
  y_max <- max(non_zero_data$`Concentration average`, na.rm = TRUE)
  
  
  # Plot to visualize all data including isolated EV population
  p_all_data <- ggplot() +
    geom_line(data = graph1, aes(x = `Bin centre (nm)`, y = `Concentration average`, color = "Untreated"), size = 1) +
    geom_line(data = graph2, aes(x = `Bin centre (nm)`, y = `Concentration average`, color = "Treated"), size = 1) +
    geom_line(data = ev_population, aes(x = `Bin centre (nm)`, y = EV_Concentration, color = "EV Population"), size = 1.5, linetype = "dashed") +
    labs(title = "Particle Size Distribution and Isolated EV Population", x = "Size (nm)", y = "Concentration (particles/ml)") +
    scale_color_manual(values = c("Untreated" = "blue", "Treated" = "green", "EV Population" = "red")) +
    theme_minimal() +
    xlim(x_min, x_max) +
    ylim(y_min, y_max) +
    theme_minimal() +
    theme(legend.title = element_blank())
  
  # Print the all data plot and save it
  print(p_all_data)
  ggsave("all_data_plot.png", p_all_data, width = 10, height = 6, units = "in", dpi = 300)
  
  # Plot to visualize only the isolated EV population with a shaded error range
  p_ev_only <- ggplot(ev_population, aes(x = `Bin centre (nm)`, y = EV_Concentration)) +
    geom_line(color = "red", size = 1.5) +  # Draw the main line for EV concentration
    geom_ribbon(aes(ymin = EV_Concentration - EV_SE, ymax = EV_Concentration + EV_SE), 
                fill = "lightpink", alpha = 0.4) +  # Add a shaded area for the standard error
    labs(title = "Isolated EV Population", x = "Particle Size (nm)", y = "Concentration (particles/ml)") +
    xlim(x_min, x_max) +
    ylim(y_min, y_max) +
    theme_minimal()
  
  # Print the EV-only plot and save it
  print(p_ev_only)
  ggsave("ev_only_plot.png", p_ev_only, width = 10, height = 6, units = "in", dpi = 300)
  
  # Assuming ev_population is your data frame and you want to smooth the EV_Concentration
  ev_population$Smoothed_EV_Concentration <- stats::filter(ev_population$EV_Concentration, rep(1/3, 3), sides=2)
  
  # Plotting the smoothed data
  ggplot(ev_population, aes(x = `Bin centre (nm)`, y = Smoothed_EV_Concentration)) +
    geom_line(color = "blue", size = 1.5) +
    labs(title = "Smoothed EV Population", x = "Particle Size (nm)", y = "Smoothed Concentration (particles/ml)") +
    xlim(x_min, x_max) +
    ylim(y_min, y_max) +
    theme_minimal()
  # Print the EV-only plot and save it
  print(p_ev_only)
  ggsave("ev_only_plot_smoothed.png", p_ev_only, width = 10, height = 6, units = "in", dpi = 300)
  
  # Print summary to console
  cat("Analysis and summary statistics completed successfully. Plots and data files have been generated.\n")
  
}, error = function(e) {
  # Handle errors that occur within the tryCatch block
  cat("An error occurred: ", e$message, "\n")
})
