# Car Sales Data Analysis and Price Prediction Using Random Forest in R 🚗

An R-based analytics project that cleans, explores, and models a 23,000-row car sales dataset to predict vehicle prices using Random Forest regression — delivered through an interactive Shiny dashboard.

BDA Mini Project

---

## 📌 Project Overview

This project analyzes car sales data to uncover pricing patterns and build a predictive model that estimates a car's price based on its specifications — such as make, year, mileage, fuel type, transmission, condition, and accident history.

The final model achieves a **Mapping Accuracy of 0.59**, identifying **Car Manufacturer** as the single strongest driver of price, ahead of mileage, year, and condition.

## 🔍 The Journey

This project went through genuine iteration based on evidence, not just a single attempt:

| Version | Target Variable | Dataset Size | Features | Mapping Accuracy |
|---|---|---|---|---|
| v1 | Sales volume | 157 rows | 4 | 0.0542 |
| v2 | Sales volume | 157 rows | 12 | 0.32 |
| **v3 (final)** | **Price** | **23,000 rows** | **8** | **0.5934** |

Predicting *sales volume* proved difficult — it depends heavily on factors like marketing and brand loyalty that aren't captured in spec data. Pivoting to predict **price** instead — a target more directly determined by measurable car attributes — combined with a larger, richer dataset, resulted in a dramatically more reliable model.

## 📊 Dataset

- **23,000 rows**, 11 columns
- Columns: Car Make, Model, Year, Mileage, Price, Fuel Type, Color, Transmission, Options/Features, Condition, Accident history
- Verified: zero missing values, zero duplicate rows
- Price range: $4,000 – $299,922 | Year: 2010–2023 | Mileage: 5,015–149,987

## 🛠️ Tools & Technologies

- **R** & **RStudio**
- `tidyverse` — data manipulation
- `ggplot2` — visualization
- `randomForest` — predictive modeling
- `DT` — interactive data tables
- `shiny` + `bslib` — interactive dashboard

## 📈 Methodology

1. **Data Cleaning** — verified structure, types, missing values, duplicates
2. **Exploratory Data Analysis**
   - Scatter plot: Mileage vs Price (colored by Condition)
   - Histogram + density plot: Price distribution
   - Boxplot: outlier detection
3. **Investigative Finding** — discovered the price distribution's bimodal shape wasn't random: a distinct cluster of exotic/luxury brands (Ferrari, Lamborghini, Bentley, Rolls-Royce, McLaren) consistently priced $195k–$205k
4. **Random Forest Regression**
   - Features: Car.Make, Year, Mileage, Fuel.Type, Color, Transmission, Condition, Accident
   - 80/20 train-test split
   - **RMSE: 25,944 | Mapping Accuracy: 0.5934**
   - Feature importance confirmed Car.Make as the dominant predictor
5. **Future Prediction** — tested on a hypothetical 2022 Honda (25k miles, Hybrid, Automatic, Used, no accidents) → predicted **$36,917.65**

## 🖥️ Interactive Dashboard

Built with Shiny, featuring 4 tabs and global cross-tab filtering:

1. **Data Explorer** — searchable, sortable, paginated data table
2. **Visualizations** — dropdown-driven scatter/histogram/boxplot
3. **Brand Analysis** — bar chart ranking average price by manufacturer
4. **Predict Price** — live prediction from user-selected specs (Car Identity, Specs, Condition panels)

The model is pre-trained and saved (`.rds` files), so the dashboard loads in seconds instead of retraining on launch.

## 🚀 How to Run

1. Clone this repository
2. Open `app.R` in RStudio
3. Install required packages if needed:
   ```r
   install.packages(c("shiny", "tidyverse", "randomForest", "DT", "bslib"))
   ```
4. Click **Run App** in RStudio

To view the full analysis and model training process, open `Car_Price_Analysis.R`.

## 📁 Repository Structure

```
├── app.R                        # Shiny dashboard
├── Car_Price_Analysis.R         # Full analysis & model training script
├── Car_sales_v2.csv             # Dataset (23,000 rows)
├── rf_model_price.rds           # Pre-trained Random Forest model
├── car_model_v2.rds             # Cleaned training data (factor reference)
├── scatterplot_mileage_price.png
├── histogram_price_v2.png
├── boxplot_price_v2.png
└── feature_importance_price.png
```

## 🔑 Key Findings

- **Car Manufacturer** is the strongest predictor of price — brand identity matters more than mileage, year, or condition
- Mileage shows a moderate negative correlation with price (-0.36); Year shows a moderate positive correlation (+0.25)
- Luxury/exotic brands form a distinct, separate pricing tier in the market
- Choosing a well-defined, learnable prediction target improved model reliability nearly 10x over the original approach

## ⚠️ Limitations

- Model may not extrapolate well to rare/unusual spec combinations
- Some features (e.g., Color) contribute minimal predictive value
- Dataset's real-world collection methodology is not independently verified

---

*Built as part of a Big Data Analytics (BDA) mini-project.*
