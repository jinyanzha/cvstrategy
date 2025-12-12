cv_lambda_adaptive <- function(X, y, lambda_path, foldid,
                               n_lambda_coarse = 20,
                               n_lambda_fine   = 40) {
  K <- max(foldid)
  p <- ncol(X)
  idx_coarse <- unique(round(seq(1, length(lambda_path),
                                 length.out = n_lambda_coarse)))
  lambda_coarse <- lambda_path[idx_coarse]
  n_coarse <- length(lambda_coarse)
  coarse_err <- matrix(NA_real_, nrow = K, ncol = n_coarse)
  t0 <- proc.time()[3]
  for (k in 1:K) {
    train <- which(foldid != k)
    test  <- which(foldid == k)
    fit <- glmnet::glmnet(X[train, ], y[train],
                  family = "binomial",
                  lambda = lambda_coarse,
                  standardize = TRUE)
    eta_mat <- stats::predict(fit, X[test, ], s = lambda_coarse, type = "link")
    for (j in seq_along(lambda_coarse)) {
      coarse_err[k, j] <- binom_dev(y[test], eta_mat[, j])
    }
  }
  coarse_cvm <- colMeans(coarse_err, na.rm = TRUE)
  best_idx <- which.min(coarse_cvm)
  left_id  <- max(1, best_idx - 1)
  right_id <- min(n_coarse, best_idx + 1)
  lambda_left  <- max(lambda_coarse[left_id], lambda_coarse[right_id])
  lambda_right <- min(lambda_coarse[left_id], lambda_coarse[right_id])
  lambda_fine <- exp(seq(log(lambda_left), log(lambda_right),
                         length.out = n_lambda_fine))
  lambda_fine <- lambda_fine[lambda_fine <= max(lambda_path) &
                               lambda_fine >= min(lambda_path)]
  if (length(lambda_fine) == 0) {
    lambda_fine <- seq(lambda_left, lambda_right, length.out = 5)
  }
  n_fine <- length(lambda_fine)
  fine_err <- matrix(NA_real_, nrow = K, ncol = n_fine)
  beta_path <- matrix(0, nrow = p, ncol = n_fine)
  for (k in 1:K) {
    train <- which(foldid != k)
    test  <- which(foldid == k)
    fit <- glmnet::glmnet(X[train, ], y[train],
                  family = "binomial",
                  lambda = lambda_fine,
                  standardize = TRUE)
    tmp_beta <- as.matrix(fit$beta)
    if (ncol(tmp_beta) < n_fine) {
      diff <- n_fine - ncol(tmp_beta)
      tmp_beta <- cbind(tmp_beta, matrix(tmp_beta[, ncol(tmp_beta)], p, diff))
    }
    beta_path <- beta_path + tmp_beta
    eta_mat <- stats::predict(fit, X[test, ], s = lambda_fine, type = "link")
    for (j in seq_along(lambda_fine)) {
      fine_err[k, j] <- binom_dev(y[test], eta_mat[, j])
    }
  }
  t1 <- proc.time()[3]
  beta_path <- beta_path / K
  list(
    method    = "adaptive",
    lambda    = lambda_fine,
    cvm       = colMeans(fine_err, na.rm = TRUE),
    cvs       = apply(fine_err, 2, sd, na.rm = TRUE) / sqrt(K),
    best      = which.min(colMeans(fine_err, na.rm = TRUE)),
    time      = t1 - t0,
    beta_path = beta_path,
    cv_raw    = fine_err
  )
}
