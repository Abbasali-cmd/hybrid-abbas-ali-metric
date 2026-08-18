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

* (D_{\mathrm{HAAM}}(x,y)) is the HAAM distance between observations (x) and (y).
* (p) is the number of numerical features.
* (q) is the number of categorical features.
* (x_j) and (y_j) are the values of numerical feature (j) for observations (x) and (y).
* (w_j) is the weight assigned to numerical feature (j).
* (s_j) is the scaling factor or standard deviation of numerical feature (j).
* (f(\cdot)) is the transformation applied to the absolute numerical difference. The current implementation supports `log`, `sqrt`, and `tanh`.
* (|x_j-y_j|) is the absolute difference between observations (x) and (y) for numerical feature (j).
* (x_k) and (y_k) are the values of categorical feature (k).
* (I(x_k \neq y_k)) is an indicator function equal to 1 when the categorical values differ and 0 when they are the same.
* (\frac{1}{q}\sum_{k=1}^{q}I(x_k \neq y_k)) represents the proportion of categorical features for which the two observations differ.

The **first component** of HAAM measures transformed, weighted, and standardized differences among numerical features. The **second component** measures categorical dissimilarity using a normalized Hamming-style distance. These components are combined to produce a single distance value for mixed numerical and categorical data.
