# Hybrid Abbas Ali Metric (HAAM)

**An experimental distance metric for mixed numerical and categorical data**

**Author:** Abbas Ali

## Overview

The **Hybrid Abbas Ali Metric (HAAM)** is an experimental distance measure designed for datasets containing both numerical and categorical variables.

HAAM combines transformed and standardized numerical differences with a categorical mismatch component. The goal is to explore whether this approach can provide a useful alternative to conventional distance measures when working with mixed-type data.

This repository provides an R implementation of the metric together with a reproducible usage example.

## Motivation

Many distance measures work naturally with numerical variables but require additional preprocessing when a dataset also contains categorical features.

HAAM was developed to explore a hybrid approach in which:

* numerical differences are transformed to reduce the influence of very large differences;
* numerical features can be weighted and standardized;
* categorical differences are measured using a normalized mismatch or Hamming-style component.

## Mathematical Definition

Conceptually, HAAM can be represented as:

$$
D_{\text{HAAM}}(x,y)
====================

\sum_{j=1}^{p}
\frac{w_j}{s_j}
f(|x_j-y_j|)
+
\frac{1}{q}
\sum_{k=1}^{q}
I(x_k \neq y_k)
$$

where:

* (w_j) is the weight assigned to numerical feature (j);
* (s_j) is the standard deviation or scaling value for feature (j);
* (f) is a transformation applied to the numerical difference;
* (I(x_k \neq y_k)) equals 1 when two categorical values differ and 0 otherwise.

The current implementation supports the following numerical transformations:

`log`, `sqrt`, and `tanh`.

## R Implementation

The main implementation is available here:

[`R/haam_distance.R`](R/haam_distance.R)

The function separates numerical and categorical inputs to avoid type-coercion problems when mixed data are stored in R.

Example usage:

```r
source("R/haam_distance.R")

person_a_num <- c(25, 60000, 3.2)
person_b_num <- c(31, 72000, 4.1)

person_a_cat <- c("Canada", "Male")
person_b_cat <- c("United States", "Male")

weights <- c(1, 1, 1)
std_devs <- c(10, 20000, 1)

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
```

A complete example is available in:

[`examples/haam_example.R`](examples/haam_example.R)

## Current Project Structure

```text
hybrid-abbas-ali-metric/
├── R/
│   └── haam_distance.R
├── examples/
│   └── haam_example.R
├── README.md
└── LICENSE
```

## Current Status

HAAM is currently an **experimental research and data-science project**.

The repository provides the metric implementation and a reproducible example. Formal benchmarking against established distance measures is a planned next step.

Future evaluation will compare HAAM with methods such as:

* Euclidean distance
* Manhattan distance
* Gower distance

Potential evaluation measures include classification accuracy, F1 score, and balanced accuracy when the distance metric is used in appropriate machine-learning workflows.

## Limitations

HAAM should not currently be interpreted as universally superior to established distance measures.

Its performance may depend on:

* the dataset;
* feature scaling;
* selected feature weights;
* transformation choice;
* proportions of numerical and categorical variables;
* the downstream statistical or machine-learning method.

Additional benchmarking across multiple datasets is required before making broader performance claims.

## Future Work

Planned improvements include benchmarking HAAM against established mixed-data distance measures, testing the metric on multiple datasets, evaluating different weighting strategies, documenting sensitivity to transformation choices, and developing additional reproducible examples.

## Skills Demonstrated

R · Statistical Computing · Distance Metrics · Mixed Data Analysis · Machine Learning · Reproducible Research

## Repository

**GitHub:**
https://github.com/Abbasali-cmd/hybrid-abbas-ali-metric

## License

See the [`LICENSE`](LICENSE) file for licensing information.

---

**Hybrid Abbas Ali Metric (HAAM)** is an exploratory statistical computing project developed by **Abbas Ali**.
