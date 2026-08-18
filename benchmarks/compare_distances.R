# ============================================================
# HAAM Benchmark Study
# Repository: hybrid-abbas-ali-metric
# Project author: Abbas Ali
#
# Purpose:
# Compare the experimental Hybrid Abbas Ali Metric (HAAM)
# with Euclidean, Manhattan, and Gower distances using the
# same k-nearest-neighbours classification task.
# ============================================================

source("R/haam_distance.R")

if (!requireNamespace("ISLR2", quietly = TRUE)) {
  stop("Install ISLR2 first with: install.packages('ISLR2')")
}

if (!requireNamespace("cluster", quietly = TRUE)) {
  stop("Install cluster first with: install.packages('cluster')")
}

# ------------------------------------------------------------
# 1. Data
# ------------------------------------------------------------

carseats <- ISLR2::Carseats

carseats$High <- factor(
  ifelse(carseats$Sales > 8, "Yes", "No"),
  levels = c("No", "Yes")
)

# Sales defines the outcome, so remove it from the predictors.
carseats$Sales <- NULL

outcome <- "High"

numeric_features <- names(carseats)[
  vapply(carseats, is.numeric, logical(1))
]

categorical_features <- setdiff(
  names(carseats)[vapply(carseats, is.factor, logical(1))],
  outcome
)

# ------------------------------------------------------------
# 2. Helper functions
# ------------------------------------------------------------

make_stratified_split <- function(y, train_fraction = 0.70) {

  class_rows <- split(seq_along(y), y)

  train_rows <- unlist(
    lapply(class_rows, function(rows) {

      n_train <- floor(length(rows) * train_fraction)
      n_train <- max(1, min(n_train, length(rows) - 1))

      sample(rows, n_train)
    })
  )

  sort(train_rows)
}


majority_vote <- function(distances, labels, k = 5) {

  k <- min(k, length(distances))

  nearest <- order(distances)[seq_len(k)]
  nearest_labels <- as.character(labels[nearest])

  counts <- table(nearest_labels)
  winners <- names(counts)[counts == max(counts)]

  if (length(winners) == 1) {
    return(winners)
  }

  # Deterministic tie-break: choose the class of the closest
  # neighbour among the tied classes.
  for (idx in nearest) {
    candidate <- as.character(labels[idx])

    if (candidate %in% winners) {
      return(candidate)
    }
  }
}


classification_scores <- function(actual, predicted, positive = "Yes") {

  actual <- as.character(actual)
  predicted <- as.character(predicted)

  tp <- sum(actual == positive & predicted == positive)
  tn <- sum(actual != positive & predicted != positive)
  fp <- sum(actual != positive & predicted == positive)
  fn <- sum(actual == positive & predicted != positive)

  accuracy <- (tp + tn) / length(actual)

  recall <- if ((tp + fn) == 0) NA_real_ else tp / (tp + fn)
  specificity <- if ((tn + fp) == 0) NA_real_ else tn / (tn + fp)
  precision <- if ((tp + fp) == 0) 0 else tp / (tp + fp)

  f1 <- if (is.na(recall) || (precision + recall) == 0) {
    0
  } else {
    2 * precision * recall / (precision + recall)
  }

  balanced_accuracy <- mean(c(recall, specificity), na.rm = TRUE)

  c(
    Accuracy = accuracy,
    F1 = f1,
    Balanced_Accuracy = balanced_accuracy
  )
}


standardize_from_training <- function(train_df, test_df, columns) {

  train_matrix <- as.matrix(train_df[, columns, drop = FALSE])
  test_matrix <- as.matrix(test_df[, columns, drop = FALSE])

  means <- colMeans(train_matrix)
  sds <- apply(train_matrix, 2, sd)

  sds[!is.finite(sds) | sds == 0] <- 1

  train_scaled <- sweep(train_matrix, 2, means, "-")
  train_scaled <- sweep(train_scaled, 2, sds, "/")

  test_scaled <- sweep(test_matrix, 2, means, "-")
  test_scaled <- sweep(test_scaled, 2, sds, "/")

  list(
    train = train_scaled,
    test = test_scaled
  )
}


encode_for_numeric_distances <- function(
  train_df,
  test_df,
  train_scaled,
  test_scaled,
  categorical_columns
) {

  train_ready <- data.frame(
    train_scaled,
    train_df[, categorical_columns, drop = FALSE],
    check.names = FALSE
  )

  test_ready <- data.frame(
    test_scaled,
    test_df[, categorical_columns, drop = FALSE],
    check.names = FALSE
  )

  combined <- rbind(train_ready, test_ready)

  encoded <- model.matrix(~ . - 1, data = combined)

  n_train <- nrow(train_df)

  list(
    train = encoded[seq_len(n_train), , drop = FALSE],
    test = encoded[n_train + seq_len(nrow(test_df)), , drop = FALSE]
  )
}


predict_numeric_knn <- function(
  train_matrix,
  test_matrix,
  labels,
  method = c("euclidean", "manhattan"),
  k = 5
) {

  method <- match.arg(method)

  predictions <- vapply(
    seq_len(nrow(test_matrix)),
    function(i) {

      difference <- sweep(
        train_matrix,
        2,
        test_matrix[i, ],
        "-"
      )

      distances <- if (method == "euclidean") {
        sqrt(rowSums(difference^2))
      } else {
        rowSums(abs(difference))
      }

      majority_vote(distances, labels, k)
    },
    character(1)
  )

  factor(predictions, levels = levels(labels))
}


row_categories <- function(df, row_id, columns) {

  if (length(columns) == 0) {
    return(NULL)
  }

  vapply(
    columns,
    function(column) as.character(df[[column]][row_id]),
    character(1)
  )
}


predict_haam_knn <- function(
  train_df,
  test_df,
  train_scaled,
  test_scaled,
  labels,
  categorical_columns,
  k = 5,
  transformation = "log"
) {

  feature_weights <- rep(1, ncol(train_scaled))
  scale_factors <- rep(1, ncol(train_scaled))

  predictions <- vapply(
    seq_len(nrow(test_df)),
    function(test_id) {

      x_num <- as.numeric(test_scaled[test_id, ])
      x_cat <- row_categories(
        test_df,
        test_id,
        categorical_columns
      )

      distances <- vapply(
        seq_len(nrow(train_df)),
        function(train_id) {

          y_num <- as.numeric(train_scaled[train_id, ])
          y_cat <- row_categories(
            train_df,
            train_id,
            categorical_columns
          )

          HAAM_Distance(
            x_num = x_num,
            y_num = y_num,
            x_cat = x_cat,
            y_cat = y_cat,
            feature_weights = feature_weights,
            std_devs = scale_factors,
            transformation = transformation
          )
        },
        numeric(1)
      )

      majority_vote(distances, labels, k)
    },
    character(1)
  )

  factor(predictions, levels = levels(labels))
}


predict_gower_knn <- function(
  train_df,
  test_df,
  labels,
  predictor_columns,
  k = 5
) {

  train_x <- train_df[, predictor_columns, drop = FALSE]
  test_x <- test_df[, predictor_columns, drop = FALSE]

  combined <- rbind(train_x, test_x)

  gower_matrix <- as.matrix(
    cluster::daisy(combined, metric = "gower")
  )

  n_train <- nrow(train_x)

  predictions <- vapply(
    seq_len(nrow(test_x)),
    function(test_id) {

      combined_test_id <- n_train + test_id

      distances <- gower_matrix[
        combined_test_id,
        seq_len(n_train)
      ]

      majority_vote(distances, labels, k)
    },
    character(1)
  )

  factor(predictions, levels = levels(labels))
}

# ------------------------------------------------------------
# 3. Repeated benchmark
# ------------------------------------------------------------

set.seed(2026)

repetitions <- 20
k_neighbours <- 5

predictor_features <- setdiff(names(carseats), outcome)

benchmark_rows <- list()
result_id <- 1

for (rep_id in seq_len(repetitions)) {

  train_id <- make_stratified_split(
    carseats[[outcome]],
    train_fraction = 0.70
  )

  train_data <- carseats[train_id, , drop = FALSE]
  test_data <- carseats[-train_id, , drop = FALSE]

  y_train <- train_data[[outcome]]
  y_test <- test_data[[outcome]]

  scaled <- standardize_from_training(
    train_data,
    test_data,
    numeric_features
  )

  encoded <- encode_for_numeric_distances(
    train_data,
    test_data,
    scaled$train,
    scaled$test,
    categorical_features
  )

  predictions <- list(
    Euclidean = predict_numeric_knn(
      encoded$train,
      encoded$test,
      y_train,
      method = "euclidean",
      k = k_neighbours
    ),

    Manhattan = predict_numeric_knn(
      encoded$train,
      encoded$test,
      y_train,
      method = "manhattan",
      k = k_neighbours
    ),

    Gower = predict_gower_knn(
      train_data,
      test_data,
      y_train,
      predictor_features,
      k = k_neighbours
    ),

    HAAM = predict_haam_knn(
      train_data,
      test_data,
      scaled$train,
      scaled$test,
      y_train,
      categorical_features,
      k = k_neighbours,
      transformation = "log"
    )
  )

  for (method_name in names(predictions)) {

    scores <- classification_scores(
      y_test,
      predictions[[method_name]]
    )

    benchmark_rows[[result_id]] <- data.frame(
      Repeat = rep_id,
      Method = method_name,
      Accuracy = unname(scores["Accuracy"]),
      F1 = unname(scores["F1"]),
      Balanced_Accuracy = unname(scores["Balanced_Accuracy"])
    )

    result_id <- result_id + 1
  }

  cat(
    sprintf(
      "Completed repeat %d of %d\n",
      rep_id,
      repetitions
    )
  )
}

benchmark_results <- do.call(rbind, benchmark_rows)

# ------------------------------------------------------------
# 4. Summary
# ------------------------------------------------------------

benchmark_summary <- do.call(
  rbind,
  lapply(
    split(benchmark_results, benchmark_results$Method),
    function(method_results) {

      data.frame(
        Method = unique(method_results$Method),
        Accuracy_Mean = mean(method_results$Accuracy),
        Accuracy_SD = sd(method_results$Accuracy),
        F1_Mean = mean(method_results$F1),
        F1_SD = sd(method_results$F1),
        Balanced_Accuracy_Mean =
          mean(method_results$Balanced_Accuracy),
        Balanced_Accuracy_SD =
          sd(method_results$Balanced_Accuracy)
      )
    }
  )
)

row.names(benchmark_summary) <- NULL

benchmark_summary <- benchmark_summary[
  order(-benchmark_summary$Balanced_Accuracy_Mean),
  ,
  drop = FALSE
]

print(
  benchmark_summary,
  digits = 3,
  row.names = FALSE
)

# ------------------------------------------------------------
# 5. Save results
# ------------------------------------------------------------

dir.create(
  "benchmarks",
  showWarnings = FALSE,
  recursive = TRUE
)

write.csv(
  benchmark_results,
  "benchmarks/benchmark_results.csv",
  row.names = FALSE
)

write.csv(
  benchmark_summary,
  "benchmarks/benchmark_summary.csv",
  row.names = FALSE
)

cat("\nBenchmark complete.\n")
cat("Saved: benchmarks/benchmark_results.csv\n")
cat("Saved: benchmarks/benchmark_summary.csv\n")
