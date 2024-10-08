## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  message = FALSE,
  warning = FALSE
  # dpi = 300,
  # fig.dim = c(2.2, 2.5)
)

library(parameters)
library(ggplot2)

## ----basic--------------------------------------------------------------------
#Package preload
library(dotwhisker)
library(dplyr)

# run a regression compatible with tidy
m1 <- lm(mpg ~ wt + cyl + disp + gear, data = mtcars)

# draw a dot-and-whisker plot
dwplot(m1)

## ----ci-----------------------------------------------------------------------
dwplot(m1, ci = .60) +   # using 60% of confidence intervals
    theme(legend.position = "none") 

## ----multipleModels-----------------------------------------------------------
m2 <- update(m1, . ~ . + hp) # add another predictor
m3 <- update(m2, . ~ . + am) # and another 

dwplot(list(m1, m2, m3))

## ----intercept----------------------------------------------------------------
dwplot(list(m1, m2, m3), show_intercept = TRUE)

## ----ggplot-------------------------------------------------------------------
dwplot(list(m1, m2, m3),
       vline = geom_vline(
           xintercept = 0,
           colour = "grey60",
           linetype = 2
       ),
       vars_order = c("am", "cyl", "disp", "gear", "hp", "wt"),
       model_order = c("Model 2", "Model 1", "Model 3")
       )  |>  # plot line at zero _behind_coefs
    relabel_predictors(
        c(
            am = "Manual",
            cyl = "Cylinders",
            disp = "Displacement",
            wt = "Weight",
            gear = "Gears",
            hp = "Horsepower"
        )
    ) +
    theme_bw(base_size = 4) + 
    # Setting `base_size` for fit the theme
    # No need to set `base_size` in most usage
    xlab("Coefficient Estimate") + ylab("") +
    geom_vline(xintercept = 0,
               colour = "grey60",
               linetype = 2) +
    ggtitle("Predicting Gas Mileage") +
    theme(
        plot.title = element_text(face = "bold"),
        legend.position = c(0.007, 0.01),
        legend.justification = c(0, 0),
        legend.background = element_rect(colour = "grey80"),
        legend.title = element_blank()
    ) 

## ----tidyData-----------------------------------------------------------------
# regression compatible with tidy
m1_df <- broom::tidy(m1) # create data.frame of regression results
m1_df # a tidy data.frame available for dwplot
dwplot(m1_df) #same as dwplot(m1)

## ----tidy---------------------------------------------------------------------
m1_df <-
    broom::tidy(m1) |> filter(term != "(Intercept)") |> mutate(model = "Model 1")
m2_df <-
    broom::tidy(m2) |> filter(term != "(Intercept)") |> mutate(model = "Model 2")

two_models <- rbind(m1_df, m2_df)

dwplot(two_models)

## ----regularExpression--------------------------------------------------------
# Transform cyl to factor variable in the data
m_factor <-
    lm(mpg ~ wt + cyl + disp + gear, data = mtcars |> mutate(cyl = factor(cyl)))

# Remove all model estimates that start with cyl*
m_factor_df <- broom::tidy(m_factor) |>
    filter(!grepl('cyl*', term))

dwplot(m_factor_df)

## ----relabel------------------------------------------------------------------
# Run model on subsets of data, save results as tidy df, make a model variable, and relabel predictors
by_trans <- mtcars |>
    group_by(am) |>                                         # group data by trans
    do(broom::tidy(lm(mpg ~ wt + cyl + disp + gear, data = .))) |> # run model on each grp
    rename(model = am) |>                                     # make model variable
    relabel_predictors(c(
        wt = "Weight",
        # relabel predictors
        cyl = "Cylinders",
        disp = "Displacement",
        gear = "Gear"
    ))

by_trans

dwplot(by_trans,
       vline = geom_vline(
           xintercept = 0,
           colour = "grey60",
           linetype = 2
       )) + # plot line at zero _behind_ coefs
    theme_bw(base_size = 4) + xlab("Coefficient Estimate") + ylab("") +
    ggtitle("Predicting Gas Mileage by Transmission Type") +
    theme(
        plot.title = element_text(face = "bold"),
        legend.position = c(0.007, 0.01),
        legend.justification = c(0, 0),
        legend.background = element_rect(colour = "grey80"),
        legend.title.align = .5
    ) +
    scale_colour_grey(
        start = .3,
        end = .7,
        name = "Transmission",
        breaks = c(0, 1),
        labels = c("Automatic", "Manual")
    )

## ----custom-------------------------------------------------------------------
dwplot(
    by_trans,
    vline = geom_vline(
        xintercept = 0,
        colour = "grey60",
        linetype = 2
    ),
    # plot line at zero _behind_ coefs
    dot_args = list(aes(shape = model)),
    whisker_args = list(aes(linetype = model))
) +
    theme_bw(base_size = 4) + xlab("Coefficient Estimate") + ylab("") +
    ggtitle("Predicting Gas Mileage by Transmission Type") +
    theme(
        plot.title = element_text(face = "bold"),
        legend.position = c(0.007, 0.01),
        legend.justification = c(0, 0),
        legend.background = element_rect(colour = "grey80"),
        legend.title.align = .5
    ) +
    scale_colour_grey(
        start = .1,
        end = .1,
        # if start and end same value, use same colour for all models
        name = "Model",
        breaks = c(0, 1),
        labels = c("Automatic", "Manual")
    ) +
    scale_shape_discrete(
        name = "Model",
        breaks = c(0, 1),
        labels = c("Automatic", "Manual")
    ) +
    guides(
        shape = guide_legend("Model"), 
        colour = guide_legend("Model")
    ) # Combine the legends for shape and color

## ----clm----------------------------------------------------------------------
# the ordinal regression model is not supported by tidy
m4 <- ordinal::clm(factor(gear) ~ wt + cyl + disp, data = mtcars)
m4_df <- coef(summary(m4)) |>
    data.frame() |>
    tibble::rownames_to_column("term") |>
    rename(estimate = Estimate, std.error = Std..Error)
m4_df
dwplot(m4_df)

## ----by2sd--------------------------------------------------------------------
# Customize the input data frame
m1_df_mod <-
    m1_df |>                 # the original tidy data.frame
    by_2sd(mtcars) |>                 # rescale the coefficients
    arrange(term)                      # alphabetize the variables

m1_df_mod  # rescaled, with variables reordered alphabetically
dwplot(m1_df_mod)

## ----brackets, fig.dim=c(5, 2.5)----------------------------------------------
# Create list of brackets (label, topmost included predictor, bottommost included predictor)
three_brackets <- list(
    c("Overall", "Weight", "Weight"),
    c("Engine", "Cylinders", "Horsepower"),
    c("Transmission", "Gears", "Manual")
)

{
    dwplot(list(m1, m2, m3),
           vline = geom_vline(
               xintercept = 0,
               colour = "grey60",
               linetype = 2
           )) |> # plot line at zero _behind_ coefs
        relabel_predictors(
            c(
                wt = "Weight",
                # relabel predictors
                cyl = "Cylinders",
                disp = "Displacement",
                hp = "Horsepower",
                gear = "Gears",
                am = "Manual"
            )
        ) + xlab("Coefficient Estimate") + ylab("") +
        ggtitle("Predicting Gas Mileage") +
        theme(
            plot.title = element_text(face = "bold"),
            legend.position = c(0.993, 0.99),
            legend.justification = c(1, 1),
            legend.background = element_rect(colour = "grey80"),
            legend.title = element_blank()
        )
} |>
    add_brackets(three_brackets, fontSize = 0.3)

## ----distribution, fig.dim=c(5, 2.5)------------------------------------------
by_transmission_brackets <- list(
    c("Overall", "Weight", "Weight"),
    c("Engine", "Cylinders", "Horsepower"),
    c("Transmission", "Gears", "1/4 Mile/t")
)

{
    mtcars %>%
        split(.$am) |>
        purrr::map( ~ lm(mpg ~ wt + cyl + gear + qsec, data = .x)) |>
        dwplot(style = "distribution") |>
        relabel_predictors(
            wt = "Weight",
            cyl = "Cylinders",
            disp = "Displacement",
            hp = "Horsepower",
            gear = "Gears",
            qsec = "1/4 Mile/t"
        ) +
        theme_bw(base_size = 4) + xlab("Coefficient") + ylab("") +
        geom_vline(xintercept = 0,
                   colour = "grey60",
                   linetype = 2) +
        theme(
            legend.position = c(.995, .99),
            legend.justification = c(1, 1),
            legend.background = element_rect(colour = "grey80"),
            legend.title.align = .5
        ) +
        scale_colour_grey(
            start = .8,
            end = .4,
            name = "Transmission",
            breaks = c("Model 0", "Model 1"),
            labels = c("Automatic", "Manual")
        ) +
        scale_fill_grey(
            start = .8,
            end = .4,
            name = "Transmission",
            breaks = c("Model 0", "Model 1"),
            labels = c("Automatic", "Manual")
        ) +
        ggtitle("Predicting Gas Mileage by Transmission Type") +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
} |>
    add_brackets(by_transmission_brackets, fontSize = 0.3)
    

## ----secretWeapon, fig.width=5------------------------------------------------
data(diamonds)

# Estimate models for many subsets of data, put results in a tidy data.frame
by_clarity <- diamonds |>
    group_by(clarity) |>
    do(broom::tidy(lm(price ~ carat + cut + color, data = .), conf.int = .99)) |>
    ungroup() |> 
  rename(model = clarity)

# Deploy the secret weapon
secret_weapon(by_clarity, var = "carat") +
    xlab("Estimated Coefficient (Dollars)") + ylab("Diamond Clarity") +
    ggtitle("Estimates for Diamond Size Across Clarity Grades") +
    theme(plot.title = element_text(face = "bold"))

## ----smallMultiple, fig.height=7----------------------------------------------
# Generate a tidy data frame of regression results from six models
m <- list()
ordered_vars <- c("wt", "cyl", "disp", "hp", "gear", "am")
m[[1]] <- lm(mpg ~ wt, data = mtcars)
m123456_df <- m[[1]] |>
    broom::tidy() |>
    by_2sd(mtcars) |>
    mutate(model = "Model 1")
for (i in 2:6) {
    m[[i]] <- update(m[[i - 1]], paste(". ~ . +", ordered_vars[i]))
    m123456_df <- rbind(m123456_df,
                        m[[i]] |>
                            broom::tidy() |>
                            by_2sd(mtcars) |>
                            mutate(model = paste("Model", i)))
}

# Relabel predictors (they will appear as facet labels)
m123456_df <- m123456_df |>
    relabel_predictors(
        c(
            "(Intercept)" = "Intercept",
            wt = "Weight",
            cyl = "Cylinders",
            disp = "Displacement",
            hp = "Horsepower",
            gear = "Gears",
            am = "Manual"
        )
    )

# Generate a 'small multiple' plot
small_multiple(m123456_df) +
    theme_bw(base_size = 4) + ylab("Coefficient Estimate") +
    geom_hline(yintercept = 0,
               colour = "grey60",
               linetype = 2) +
    ggtitle("Predicting Mileage") +
    theme(
        plot.title = element_text(face = "bold"),
        legend.position = "none",
        axis.text.x = element_text(angle = 60, hjust = 1)
    ) 

## ----smallMultiple2, fig.width=4, fig.height=6--------------------------------
# Generate a tidy data frame of regression results from five models on
# the mtcars data subset by transmission type
ordered_vars <- c("wt", "cyl", "disp", "hp", "gear")
mod <- "mpg ~ wt"

by_trans2 <- mtcars |>
    group_by(am) |>                        # group data by transmission
    do(broom::tidy(lm(mod, data = .))) |>         # run model on each group
    rename(submodel = am) |>               # make submodel variable
    mutate(model = "Model 1") |>           # make model variable
    ungroup()

for (i in 2:5) {
    mod <- paste(mod, "+", ordered_vars[i])
    by_trans2 <- rbind(
        by_trans2,
        mtcars |>
            group_by(am) |>
            do(broom::tidy(lm(mod, data = .))) |>
            rename(submodel = am) |>
            mutate(model = paste("Model", i)) |>
            ungroup()
    )
}

# Relabel predictors (they will appear as facet labels)
by_trans2 <- by_trans2 |>
    select(-submodel, everything(), submodel) |>
    relabel_predictors(
        c(
            "(Intercept)" = "Intercept",
            wt = "Weight",
            cyl = "Cylinders",
            disp = "Displacement",
            hp = "Horsepower",
            gear = "Gears"
        )
    )

by_trans2

small_multiple(by_trans2) +
    theme_bw(base_size = 4) +
    ylab("Coefficient Estimate") +
    geom_hline(yintercept = 0,
               colour = "grey60",
               linetype = 2) +
    theme(
        axis.text.x  = element_text(angle = 45, hjust = 1),
        legend.position = c(0.02, 0.008),
        legend.justification = c(0, 0),
        legend.title = element_text(size = 8),
        legend.background = element_rect(color = "gray90"),
        legend.spacing = unit(-4, "pt"),
        legend.key.size = unit(10, "pt")
    ) +
    scale_colour_hue(
        name = "Transmission",
        breaks = c(0, 1),
        labels = c("Automatic", "Manual")
    ) +
    ggtitle("Predicting Gas Mileage\nby Transmission Type")

## ----stats, fig.height=5------------------------------------------------------
dwplot(m1, show_stats = TRUE, stats_size = 3)

dwplot(list(m1, m2, m3), show_stats = TRUE, stats_size = 3)

small_multiple(list(m1, m2, m3), show_stats = TRUE, stats_size = 3)

## ----stats_custom-------------------------------------------------------------
stats_fakeCustom <-
  dotwhisker:::dw_stats(m1, stats_digits = 2)

dwplot(
  m1_df,
  show_stats = TRUE,
  stats_tb = stats_fakeCustom,
  stats_size = 3
)

## ----combo, fig.height=6, fig.width=4-----------------------------------------
library(gridExtra)
library(patchwork)

three_brackets <- list(
    c("Overall", "Weight", "Weight"),
    c("Engine", "Cylinders", "Horsepower"),
    c("Transmission", "Gears", "Manual")
)

plot_brackets <- {
    dwplot(m3, 
           vline = geom_vline(
               xintercept = 0,
               colour = "grey60",
               linetype = 2
           )) |> # plot line at zero _behind_ coefs
        relabel_predictors(
            c(
                wt = "Weight",
                # relabel predictors
                cyl = "Cylinders",
                disp = "Displacement",
                hp = "Horsepower",
                gear = "Gears",
                am = "Manual"
            )
        ) + xlab("Coefficient Estimate") + ylab("") +
        ggtitle("Predicting Gas Mileage") 
} |>
    add_brackets(three_brackets, fontSize = 0.3)

plot_brackets / tableGrob(
  dotwhisker:::dw_stats(
    m3,
    stats_digits = 2,
    stats_compare = FALSE
  ),
  rows = NULL,
  theme = ttheme_default(base_size = 3)
) +
  plot_layout(heights = c(5, -0.5, 1)) # the negative value is used to adjust the space between the plot and the model fits


