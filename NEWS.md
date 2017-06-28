## Version 0.3.0
1. Rewrote the plotting functions based on the `ggstance` functions. The new `dwplot` allows cooperating with more `ggplot` functions, such as `facet_*`. 
1. Drew whiskers based on the CI estimates directly from the model output. See more details in [`tidy.lm`](https://github.com/tidyverse/broom/blob/master/R/lm_tidiers.R) and [`confint`](https://github.com/cran/MASS/blob/master/R/confint.R).
1. Clarified the description of `by_2sd`.

## Version 0.2.6
1. Fixed the bug in `relabel_predictors`.

## Version 0.2.5
1. Expanded capabilities of `relabel_predictors`. `relabel_predictors` now accepts plots as well as tidy dataframes as input; that is, it may now be used both before and after calls to `dwplot`.
1. Deprecated `relabel_y_axis`.  It is easy to mistakenly mislabel variables with `relabel_y_axis`, and it has a conflict with `add_brackets` in single-model plots. 
1. Provided example of using multiple shapes for multiple models in vignette.
1. `dwplot` works for `polr` projects.

## Version 0.2.4
1. Improved the presentation of `small_multiple`.

## Version 0.2.3
1. Fixed the error of variable ordering with a single model.

## Version 0.2.2
1. Fixed the error in presenting multiple models.

## Version 0.2.1
1. Fixed the error due to the update of `dplyr::group_by`
2. Fixing the errors in vignette.
3. Adding the `show_intercept` argument. 
4. Shorten the version number to three digits as `devtools` suggests.


## Version 0.2.0.5
1. Fixed the error due to the update of `gridExtra`.
2. Fixed the error due to the update of `ggplot2`.

## Version 0.2.0.4
1. Fixed presenting error in multilevel models (#44)

## Version 0.2.0.3
1. Fixed the link error in `kl2007_example.Rmd`.

## Version 0.2.0.2
1. Improving the vignette.
2. The function works for `ggplot2` 2.0.0.

## Version 0.2.0.1
1. Fixed the error in the vignette.

## Version 0.2.0.0
1. Allowing directly using model objects besides `tidy` data.frame.
2. Adding two new special plotting functions: `secret_weapon` and `small_multiple`.
3. Adding two graph adjusting functions: `relabel_predictor` and `relabel_y_axis`.

More details about the new functions are available in the vignette.




