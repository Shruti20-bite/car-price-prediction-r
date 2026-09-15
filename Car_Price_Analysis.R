setwd("D:/BDA Project")

library(tidyverse)
library(ggplot2)
library(randomForest)
library(DT)

car_data2 <- read.csv("Car_sales_v2.csv")

head(car_data2)
str(car_data2)
summary(car_data2)
scatterplot_v2 <- ggplot(car_data2, aes(x = Mileage, y = Price, color = Condition)) +
  geom_point(size = 2, alpha = 0.5) +
  labs(title = "Mileage vs Price (colored by Condition)",
       x = "Mileage", y = "Price") +
  theme_minimal()

print(scatterplot_v2)

price_histogram_v2 <- ggplot(car_data2, aes(x = Price)) +
  geom_histogram(aes(y = after_stat(density)), fill = "skyblue", color = "black", bins = 40) +
  geom_density(alpha = 0.7, fill = "orange") +
  labs(title = "Distribution of Car Prices (New Dataset)", x = "Price", y = "Density")

print(price_histogram_v2)

ggsave("histogram_price_v2.png", plot = price_histogram_v2, width = 8, height = 6)
ggsave("scatterplot_mileage_price.png", plot = scatterplot_v2, width = 8, height = 6)
set.seed(123)

car_model_v2 <- car_data2 %>%
  select(Car.Make, Year, Mileage, Price, Fuel.Type, Color, Transmission, Condition, Accident) %>%
  drop_na()

car_model_v2$Car.Make <- as.factor(car_model_v2$Car.Make)
car_model_v2$Fuel.Type <- as.factor(car_model_v2$Fuel.Type)
car_model_v2$Color <- as.factor(car_model_v2$Color)
car_model_v2$Transmission <- as.factor(car_model_v2$Transmission)
car_model_v2$Condition <- as.factor(car_model_v2$Condition)
car_model_v2$Accident <- as.factor(car_model_v2$Accident)

train_indices2 <- sample(1:nrow(car_model_v2), 0.8 * nrow(car_model_v2))
train_data2 <- car_model_v2[train_indices2, ]
test_data2 <- car_model_v2[-train_indices2, ]

mtry_opt2 <- floor(sqrt(ncol(train_data2) - 1))

rf_model_price <- randomForest(
  Price ~ .,
  data = train_data2,
  ntree = 500,
  mtry = mtry_opt2,
  nodesize = 5,
  importance = TRUE
)

pred_price <- predict(rf_model_price, newdata = test_data2)

rmse_price <- sqrt(mean((pred_price - test_data2$Price)^2))
cat("RMSE:", round(rmse_price, 4), "\n")

mapping_accuracy_price <- 1 - (rmse_price / sd(test_data2$Price))
cat("Mapping Accuracy:", round(mapping_accuracy_price, 4), "\n")

importance(rf_model_price)
varImpPlot(rf_model_price, main = "Feature Importance - Price Prediction")
new_car <- data.frame(
  Car.Make = factor("Honda", levels = levels(car_model_v2$Car.Make)),
  Year = 2022,
  Mileage = 25000,
  Fuel.Type = factor("Hybrid", levels = levels(car_model_v2$Fuel.Type)),
  Color = factor("Black", levels = levels(car_model_v2$Color)),
  Transmission = factor("Automatic", levels = levels(car_model_v2$Transmission)),
  Condition = factor("Used", levels = levels(car_model_v2$Condition)),
  Accident = factor("No", levels = levels(car_model_v2$Accident))
)

future_price_prediction <- predict(rf_model_price, newdata = new_car)
print(future_price_prediction)
saveRDS(rf_model_price, "rf_model_price.rds")
saveRDS(car_model_v2, "car_model_v2.rds")