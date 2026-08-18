source("R/haam_distance.R")

# Example numeric features
person_a_num <- c(25, 60000, 3.2)
person_b_num <- c(31, 72000, 4.1)

# Example categorical features
person_a_cat <- c("Canada", "Male")
person_b_cat <- c("United States", "Male")

# Feature weights and standard deviations
weights <- c(1, 1, 1)
std_devs <- c(10, 20000, 1)

# Calculate HAAM distance
distance <- HAAM_Distance(
  x_num = person_a_num,
  y_num = person_b_num,
  x_cat = person_a_cat,
  y_cat = person_b_cat,
  feature_weights = weights,
  std_devs = std_devs,
  transformation = "log"
)

print(distance)
