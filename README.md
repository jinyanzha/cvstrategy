

# cvcompare

## Overview

`cvcompare` is an R package designed to compare multiple cross-validation
strategies for L1-regularized logistic regression.  
The package provides a unified framework for evaluating predictive
performance, computational efficiency, and stability of different
cross-validation schemes.

Specifically, `cvcompare` implements and compares four approaches:
basic cross-validation, warm-start cross-validation, adaptive
coarse-to-fine search, and the official `cv.glmnet` procedure.

- You can run examples in the `?compare_cv_methods` help page.
- The package outputs a summary table for easy comparison across methods.
- Visualization functions are provided for CV error curves and coefficient paths.

---

## Features

`cvcompare` provides the following functionality:

- Compare four cross-validation strategies for L1-regularized logistic regression:
  - Basic CV (cold start)
  - Warm-start CV
  - Adaptive coarse-to-fine CV
  - Official `cv.glmnet`

- Automatically select the optimal regularization parameter (`lambda`)
  for each method.

- Report predictive performance metrics, including:
  - Cross-validated deviance
  - Classification accuracy
  - AUC

- Quantify model stability across folds using coefficient variability.

- Measure and report runtime for each cross-validation strategy.

- Provide plotting utilities for:
  - Cross-validation error curves
  - Coefficient paths across lambda values

---

## Installation

```r
# Install devtools if not already installed
install.packages("devtools")

# Install cvcompare from GitHub
devtools::install_github("jinyanzha/cvcompare")
```




## Usage

``` r
library(cvstrategy)
data(Sonar, package = "mlbench")

X <- as.matrix(Sonar[, 1:60])
y <- ifelse(Sonar$Class == "M", 1, 0)

tab <- compare_cv_methods(X, y, K = 5, seed = 1)
print(tab)

    method best_lambda best_cvm train_mse  accuracy       auc stability_sd_best stability_mean_sd runtime
1    basic  0.03359275 1.070146 0.1343958 0.8173077 0.9083310        0.09162666        1.33953828    0.19
2     warm  0.03359275 1.070146 0.1343958 0.8173077 0.9083310        0.09162666        1.33953828    0.19
3 adaptive  0.03248939 1.070109 0.1332396 0.8125000 0.9099099        0.09063466        0.08706317    0.11
4 official  0.03359275 1.070493 0.1343958 0.8173077 0.9083310        0.09162666        1.33953828    0.37

  
```

## Function Details

- Input Parameters:

  - `Y`: The response variable (character string representing the column name in `data`).
  - `X`: Predictor variables(eg.,"X1+X2")
  - `data`: A data frame that contains both `Y` and `X` variables.
  

- Output:
  - model metrics including R-squared, Adjusted R-squared, F-statistic and p-values.
  - Residuals Table: A table summarizing residuals (`Min`, `1Q`, `Median`, `3Q`, `Max`).
  - Regression Table: A table containing coefficients, standard errors, t-values, and relevant p-values.
  - Confidence Interval: A table containing all coefficients' confidence interval


## Interpretation of Output
- The R-squared value represents the proportion of the variance explained by the model.
- The Adjusted R-squared accounts for the number of predictors in the model, providing a better measure for models with multiple predictors.
- The F-statistic tests whether the overall regression model is a good fit for the data.
- Residual standard error provides a measure of the typical size of residuals.
- Confidence Interval provide a range within which we expect the true value of the regression coefficient to lie, with a certain level of confidence, in this case, 95%.
