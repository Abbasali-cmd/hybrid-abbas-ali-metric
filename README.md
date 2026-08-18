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

```math
D_{\mathrm{HAAM}}(x,y)
=
\sum_{j=1}^{p}
\frac{w_j}{s_j}
f\left(|x_j-y_j|\right)
+
\frac{1}{q}
\sum_{k=1}^{q}
I(x_k \neq y_k)
```

### Where

* $D_{\mathrm{HAAM}}(x,y)$ is the HAAM distance between observations $x$ and $y$.
* $p$ is the number of numerical features.
* $q$ is the number of categorical features.
* $x_j$ and $y_j$ are the values of numerical feature $j$ for observations $x$ and $y$.
* $w_j$ is the weight assigned to numerical feature $j$.
* $s_j$ is the scaling factor or standard deviation of numerical feature $j$.
* $f(\cdot)$ is the transformation applied to the absolute numerical difference. The current implementation supports `log`, `sqrt`, and `tanh`.
* $|x_j-y_j|$ is the absolute difference between observations $x$ and $y$ for numerical feature $j$.
* $x_k$ and $y_k$ are the values of categorical feature $k$.
* $I(x_k \neq y_k)$ equals 1 when the categorical values differ and 0 when they are the same.
* $\frac{1}{q}\sum_{k=1}^{q} I(x_k \neq y_k)$ represents the proportion of categorical features for which the two observations differ.

The first component of HAAM measures transformed, weighted, and standardized differences among numerical features. The second component measures categorical dissimilarity using a normalized Hamming-style distance. These components are combined into a single distance value for mixed numerical and categorical data.

## R Implementation

The main implementation is available here:

[`R/haam_distance.R`](R/haam_distance.R)

Example:

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

The current repository provides:

* the HAAM distance function;
* support for `log`, `sqrt`, and `tanh` transformations;
* separate handling of numerical and categorical variables;
* a reproducible usage example.

Formal benchmarking against established distance measures is planned.

## Planned Benchmarking

Future evaluation will compare HAAM with methods such as:

* Euclidean distance
* Manhattan distance
* Gower distance

Potential evaluation metrics include:

* Accuracy
* F1 score
* Balanced accuracy

Any performance claims should be based on benchmark results from the same datasets and evaluation procedure.

## Limitations

HAAM should not currently be interpreted as universally superior to established distance measures.

Its performance may depend on:

* the dataset;
* feature scaling;
* selected feature weights;
* transformation choice;
* the number and type of variables;
* the downstream statistical or machine-learning method.

Additional benchmarking across multiple datasets is required before making broader performance claims.

## Future Work

Planned improvements include:

* benchmarking HAAM against established distance measures;
* testing the metric on multiple mixed-type datasets;
* evaluating different weighting strategies;
* studying sensitivity to transformation choice;
* adding automated tests;
* expanding reproducible examples.

## Skills Demonstrated

R · Statistical Computing · Distance Metrics · Mixed Data Analysis · Machine Learning · Reproducible Research

## Repository

https://github.com/Abbasali-cmd/hybrid-abbas-ali-metric

## License

See the [`LICENSE`](LICENSE) file for licensing information.

---

**Hybrid Abbas Ali Metric (HAAM)** is an exploratory statistical-computing project developed by **Abbas Ali**.
