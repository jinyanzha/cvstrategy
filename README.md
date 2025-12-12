## GenAI Tutorial

This project includes a tutorial describing how generative AI tools were
used during the development of this package.

-  [GenAI Tutorial](GenAI_Tutorial.md)


# cvstrategy

## Overview

`cvstrategy` is an R package designed to compare multiple cross-validation
strategies for L1-regularized logistic regression.  
The package provides a unified framework for evaluating predictive
performance, computational efficiency, and stability of different
cross-validation schemes.

Specifically, `cvstrategy` implements and compares four approaches:
basic cross-validation, warm-start cross-validation, adaptive
coarse-to-fine search, and the official `cv.glmnet` procedure.

- You can run examples in the `?compare_cv_methods` help page.
- The package outputs a summary table for easy comparison across methods.
- Visualization functions are provided for CV error curves and coefficient paths.

---

## Features

`cvstrategy` provides the following functionality:

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

# Install cvstrategy from GitHub
devtools::install_github("jinyanzha/cvstrategy")
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

### Input Parameters

- `X`  
  A numeric design matrix of predictors (n × p).

- `y`  
  A binary response vector coded as 0/1.

- `lambda_path`  
  Optional numeric vector specifying the regularization path.  
  If `NULL`, a default path is generated internally.

- `K`  
  Number of cross-validation folds.

- `foldid`  
  Optional vector assigning observations to folds.

- `seed`  
  Random seed for reproducibility.

- `n_lambda_coarse`  
  Number of coarse grid points for adaptive CV.

- `n_lambda_fine`  
  Number of fine grid points for adaptive CV.

- `threshold`  
  Classification threshold used for accuracy calculation.

---

### Output

The function returns a `data.frame` comparing four cross-validation strategies:

- **basic**: standard cross-validation  
- **warm**: warm-start cross-validation  
- **adaptive**: coarse-to-fine adaptive search  
- **official**: `cv.glmnet` baseline  

For each method, the following metrics are reported:

- `best_lambda`  
- `best_cvm` (minimum cross-validation deviance)  
- `train_mse`  
- `accuracy`  
- `auc`  
- `stability_sd_best`  
- `stability_mean_sd`  
- `runtime` (in seconds)

---

## Interpretation of Output

- The **cross-validation deviance** reflects predictive performance on held-out data.
- **Accuracy** and **AUC** evaluate classification performance.
- **Stability metrics** quantify the sensitivity of coefficient estimates across folds.
- **Runtime** highlights computational efficiency differences among CV strategies.

Lower CV error and higher stability indicate more reliable model selection.

