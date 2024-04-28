**R Analysis of EV Populations**
This repository contains an R script for analyzing extracellular vesicle (EV) populations using data obtained from two different conditions: untreated and detergent-treated. The script calculates the difference in particle concentrations between these conditions to isolate the EV population and provides comprehensive visualizations and statistical summaries.

**Features**
Data Merging: Combines data from two conditions using a full join.
EV Population Estimation: Calculates EV population based on concentration differences.
Data Visualization:
Plot of all data including isolated EV populations.
Detailed plot of isolated EV population with error shading.
Additional plot with smoothed data for clearer visualization.
Statistical Summaries: Outputs include average concentration, particle size, and standard deviation.
**Requirements**
To run this script, you will need R installed on your computer along with the following R packages:

readxl
openxlsx
dplyr
ggplot2

You can install these packages using R commands like:

R
Copy code
install.packages("readxl")
install.packages("openxlsx")
install.packages("dplyr")
install.packages("ggplot2")

**Data Files**
This script expects two Excel files to be present in the working directory:

Book1.xlsx : Data from untreated samples.

Book2.xlsx : Data from detergent-treated samples.
**Usage**
Ensure the required Excel files (Book1.xlsx and Book2.xlsx) are in your working directory.

Open and run the script in an R environment such as RStudio.
**Outputs**
The script will generate several outputs:

Excel files with raw and summary data of EV populations.
Plots in PNG format:
all_data_plot.png: Visualizes all data including untreated, treated, and isolated EV populations.
ev_only_plot.png: Focuses on isolated EV population with error shading.
ev_only_plot_smoothed.png: Shows the smoothed data plot for isolated EV population.
**Error Handling**
The script includes basic error handling for missing files or data inconsistencies. Error messages will guide you to resolve common issues such as missing files or required data columns.
