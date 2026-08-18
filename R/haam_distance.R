HAAM_Distance <- function(
  x_num,
  y_num,
  x_cat = NULL,
  y_cat = NULL,
  feature_weights = NULL,
  std_devs = NULL,
  transformation = "log"
) {

  if (length(x_num) != length(y_num)) {
    stop("x_num and y_num must have the same length.")
  }

  if (is.null(feature_weights)) {
    feature_weights <- rep(1, length(x_num))
  }

  if (is.null(std_devs)) {
    std_devs <- rep(1, length(x_num))
  }

  if (length(feature_weights) != length(x_num)) {
    stop("feature_weights must match the number of numeric features.")
  }

  if (length(std_devs) != length(x_num)) {
    stop("std_devs must match the number of numeric features.")
  }

  if (any(std_devs <= 0, na.rm = TRUE)) {
    stop("All standard deviations must be greater than zero.")
  }

  difference <- abs(x_num - y_num)

  transformed_difference <- switch(
    transformation,
    log  = log1p(difference),
    sqrt = sqrt(difference),
    tanh = tanh(difference),
    stop("transformation must be 'log', 'sqrt', or 'tanh'.")
  )

  numeric_distance <- sum(
    feature_weights * transformed_difference / std_devs,
    na.rm = TRUE
  )

  categorical_distance <- 0

  if (!is.null(x_cat) && !is.null(y_cat)) {

    if (length(x_cat) != length(y_cat)) {
      stop("x_cat and y_cat must have the same length.")
    }

    categorical_distance <- mean(
      x_cat != y_cat,
      na.rm = TRUE
    )
  }

  numeric_distance + categorical_distance
}
