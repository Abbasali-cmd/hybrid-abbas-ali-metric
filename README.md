Conceptually, HAAM can be represented as:

$$
D_{\mathrm{HAAM}}(x,y)
=
\sum_{j=1}^{p}
\frac{w_j}{s_j}
f\left(|x_j-y_j|\right)
+
\frac{1}{q}
\sum_{k=1}^{q}
I(x_k \neq y_k)
$$

where:

- $w_j$ is the weight assigned to numerical feature $j$;
- $s_j$ is the standard deviation or scaling value for numerical feature $j$;
- $f$ is the transformation applied to the numerical difference;
- $I(x_k \neq y_k)$ equals 1 when two categorical values differ and 0 otherwise.
