# Colors ------------------------------------------------------------------

# This palette was generated with 7 values from scico's "roma" palette, but
# ignoring the extra light greenish 4th color
# https://github.com/thomasp85/scico
#
# scico(7, palette = "roma")
ngo_red <- "#7E1900"
ngo_orange <- "#AC7825"
ngo_yellow <- "#D9D26A"
ngo_blue_lt <- "#60C3D4"
ngo_blue <- "#3877B6"
ngo_blue_dk <- "#1A3399"


# ggplot themes -----------------------------------------------------------

update_geom_defaults("label", list(family = "Oswald Light"))
update_geom_defaults("text", list(family = "Oswald Light"))

theme_ngo <- function(base_size = 9, base_family = "Oswald-Regular") {
  ret <- theme_bw(base_size, base_family) +
    theme(plot.title = element_text(size = rel(1.4), face = "plain",
                                    family = "Oswald SemiBold"),
          plot.subtitle = element_text(size = rel(1), face = "plain",
                                       family = "Oswald Light"),
          plot.caption = element_text(size = rel(0.8), color = "grey50", face = "plain",
                                      family = "Oswald Light",
                                      margin = margin(t = 10)),
          strip.text = element_text(size = rel(1), face = "plain",
                                    family = "Oswald SemiBold"),
          panel.border = element_blank(), 
          panel.grid.minor = element_blank(),
          strip.background = element_rect(fill = "#ffffff", colour = NA),
          axis.ticks = element_blank(),
          axis.title.x = element_text(margin = margin(t = 10)),
          legend.key = element_blank(),
          legend.text = element_text(size = rel(1), family = "Oswald Light", face = "plain"),
          legend.spacing = unit(0.1, "lines"),
          legend.box.margin = margin(t = -0.5, unit = "lines"),
          legend.margin = margin(t = 0),
          legend.position = "bottom")
  
  ret
}

theme_ngo_map <- function(base_size = 11, base_family = "Oswald-Regular") {
  ret <- theme_void(base_size, base_family) +
    theme(legend.position = "bottom",
          legend.text = element_text(size = rel(1), family = "Oswald Light", face = "plain"),
          legend.title = element_text(family = "Oswald-Regular", face = "plain"),
          legend.key.size = unit(0.7, "lines"))
  
  ret
}
