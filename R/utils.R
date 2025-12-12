binom_dev <- function(y, eta) {
  p <- 1 / (1 + exp(-eta))
  p <- pmin(pmax(p, 1e-15), 1 - 1e-15)
  -2 * mean(y * log(p) + (1 - y) * log(1 - p))
}
