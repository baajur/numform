#' Detect Column Alignment
#'
#' Many of the specialized functions in numform can change the type of the data
#' from numeric to character causing the table formatting functions in various
#' add-on packages to improperly align the elements.  This function passes the
#' columns with a regular expression to detect alignment regardless of column
#' class.
#'
#' @param x A \code{data.frame}.
#' @param left A value to print for left aligned columns.
#' @param right A value to print for right aligned columns.  If \code{left = "l"}
#' \code{right} will default to \code{"r"} otherwise defaults to \code{"right"}.
#' @param additional.numeric An additional regex to consider as numeric.  To turn
#' off this feature use \code{additional.numeric = NULL}.
#' @param sep A string to collapse the vector on.
#' @param \ldots ignored.
#' @return Returns a vector of lefts and rights or a string (if \code{sep} is not
#' \code{NULL}.
#' @export
#' @examples
#' CO <- CO2
#' CO[] <- lapply(CO, as.character)
#' alignment(CO)
#' head(CO2)
#'
#'
#' \dontrun{
#' library(dplyr)
#' library(pander)
#' library(xtable)
#'
#' set.seed(10)
#' dat <- data_frame(
#'     Team = rep(c("West Coast", "East Coast"), each = 4),
#'     Year = rep(2012:2015, 2),
#'     YearStart = round(rnorm(8, 2e6, 1e6) + sample(1:10/100, 8, TRUE), 2),
#'     Won = round(rnorm(8, 4e5, 2e5) + sample(1:10/100, 8, TRUE), 2),
#'     Lost = round(rnorm(8, 4.4e5, 2e5) + sample(1:10/100, 8, TRUE), 2),
#'     WinLossRate = Won/Lost,
#'     PropWon = Won/YearStart,
#'     PropLost = Lost/YearStart
#' )
#'
#'
#' dat %>%
#'     group_by(Team) %>%
#'     mutate(
#'         `%&Delta;WinLoss` = fv_percent_diff(WinLossRate, 0),
#'         `&Delta;WinLoss` = f_sign(Won - Lost, '<b>+</b>', '<b>&ndash;</b>')
#'
#'     ) %>%
#'     ungroup() %>%
#'     mutate_at(vars(Won:Lost), .funs = ff_denom(relative = -1, prefix = '$')) %>%
#'     mutate_at(vars(PropWon, PropLost), .funs = ff_prop2percent(digits = 0)) %>%
#'     mutate(
#'         YearStart = f_denom(YearStart, 1, prefix = '$'),
#'         Team = fv_runs(Team),
#'         WinLossRate = f_num(WinLossRate, 1)
#'     ) %>%
#'     as.data.frame() %>%
#'     pander::pander(split.tables = Inf, justify = alignment(.))
#'
#'
#' alignment(CO, 'l', 'r')
#'
#' CO %>%
#'     xtable(align = c('', alignment(CO, 'l', 'r'))) %>%
#'     print(include.rownames = FALSE)
#'
#'
#' CO %>%
#'     xtable(align = c('', alignment(CO, 'l|', 'r|'))) %>%
#'     print(include.rownames = FALSE)
#' }
alignment <- function(x, left = 'left', right = ifelse(left == 'l', 'r', 'right'),
    additional.numeric = paste0(
        '^((<b>(&ndash;|\\+)</b>)|(<?([0-9.%-]+)',
        '|(\\$?\\s*\\d+[KBM])))|(NaN|NA|Inf)$'
    ),
    sep = NULL, ...){

    stopifnot(is.data.frame(x))

    out <- ifelse(right_align(x, additional.numeric =  additional.numeric), right, left)

    if (!is.null(sep)) out <- paste(out, collapse = sep)

    out
}


right_align <- function(df, additional.numeric = NULL){
    unname(unlist(lapply(df, function(x){
        x <- as.character(x)
        if (!is.null(additional.numeric)) numregex <- paste(paste0('(', unlist(c(numregex, additional.numeric, additional.numeric)), ')'), collapse = "|")

        grepl(numregex, trimws(rm_na(x)[1]), perl = TRUE) & !grepl('^-*\\s*$', trimws(rm_na(x)[1]), perl = TRUE)
    })))
}


numregex <- '^((((\\$)?[0-9.,+-]+( ?%|[KMB])?)|([0-9/:.-T ]{5,}))|(-?[0-9.]+(&deg;)?[WESNFC]?))$'
# numregex <- "^(?!.*((^-*\\s*$)))(?=.*(^((((\\$)?[0-9.,+-]+( ?%|[KMB])?)|([0-9/:.-T ]{5,}))|(-?[0-9.]+(&deg;)?[WESNFC]?))$))"

