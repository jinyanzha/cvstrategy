#' Plot CV curves and runtime comparison across methods
#'
#' @param res_list Named list of CV results. Each element should contain `lambda`, `cvm`, and `time`.
#' @return A list with `plot`, `time_table`, and `combined_grob`.
#' @export
plot_cv_compare <- function(res_list) {

  df <- lapply(names(res_list), function(m) {
    r <- res_list[[m]]
    data.frame(
      method = m,
      log_lambda = log(r$lambda),
      cvm = r$cvm,
      stringsAsFactors = FALSE
    )
  })
  df <- dplyr::bind_rows(df)

  best_points <- df |>
    dplyr::group_by(.data$method) |>
    dplyr::slice(which.min(.data$cvm)) |>
    dplyr::ungroup()

  hlines <- dplyr::mutate(best_points, y = .data$cvm)

  time_df <- data.frame(
    text = paste0(
      names(res_list), ": ",
      sprintf("%.3f", vapply(res_list, function(x) x$time, numeric(1))),
      "s"
    ),
    stringsAsFactors = FALSE
  )

  time_grob <- gridExtra::tableGrob(
    time_df,
    rows = NULL,
    theme = gridExtra::ttheme_minimal(
      core = list(fg_params = list(hjust = 0, x = 0.05, fontsize = 12)),
      colhead = list(fg_params = list(fontsize = 0))
    )
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$log_lambda, y = .data$cvm, color = .data$method)) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::geom_hline(
      data = hlines,
      ggplot2::aes(yintercept = .data$y, color = .data$method),
      linetype = "dotted", alpha = 0.5, linewidth = 0.8, show.legend = FALSE
    ) +
    ggplot2::geom_vline(
      data = best_points,
      ggplot2::aes(xintercept = .data$log_lambda, color = .data$method),
      linetype = "dashed", alpha = 0.6, show.legend = FALSE
    ) +
    ggplot2::geom_point(data = best_points, size = 3, show.legend = FALSE) +
    ggplot2::labs(
      title = "Comparison of CV Strategies",
      x = "log(lambda)",
      y = "CV Error"
    ) +
    ggplot2::theme_minimal(base_size = 15) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_blank()
    )

  combined <- gridExtra::grid.arrange(
    p, time_grob,
    ncol = 2,
    widths = c(4.5, 1),
    heights = 2
  )

  invisible(list(plot = p, time_table = time_df, combined_grob = combined))
}
