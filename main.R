library(tidyverse)
library(magick)
library(sf)
library(ggstar)

states <- spData::us_states
places <- tigris::places(state = "California")

par <- places |> 
  filter(NAMELSAD == "Paradise town") |> 
  mutate(geometry = st_centroid(geometry))

sac <- places |> 
  filter(NAME == "Sacramento") |> 
  st_transform(crs = 3309) |> 
  as_tibble() |> 
  select(NAME, geometry) |> 
  mutate(geometry = st_centroid(geometry))

with_coords <- cbind(sac, st_coordinates(sac$geometry))

# To avoid shadowing text annotations, I create shadow effect
# from plot with only the border I want shadowed

cali_p <- states |> 
  filter(NAME == "California") |> 
  ggplot() +
  geom_sf(fill = "white", size = .5) +
  #geom_sf_text(data = these, aes(label = NAMELSAD)) +
  coord_sf(crs = 3309) +
  theme_void()

ggsave(cali_p, filename = "images/california.png", device = "png")

# Add annotations to plot

labs_p <- cali_p + 
  geom_sf_text(aes(label = str_to_upper(NAME)), nudge_x = 200000, nudge_y = -250000,
               size = 12, color = "grey60", family = "Gurmukhi MN") +
  geom_label(data = with_coords, aes( x = X, y = Y, label = NAME),
            nudge_x = 20000, nudge_y = -20000, hjust = 0, label.size = 0,
            label.padding = unit(0, "cm"), fill = alpha("white", .75),
            color = "grey60", size = 10, family = "Gurmukhi MN") +
  geom_star(data = with_coords,
            aes(x = X, y = Y), color = "grey60", fill = "grey60",
            size = 5) +
  geom_sf(data = par, size = 5) +
  geom_sf_label(data = par, aes(label = NAME),  nudge_x = 20000, nudge_y = 20000,
               size = 10, family = "Gurmukhi MN", label.size = 0,
               label.padding = unit(0, "cm"), fill = alpha("white", .75),
               hjust = 0) +
  coord_sf(crs = 3309)

ggsave(labs_p, filename = "images/labs.png", device = "png")

img_labs <- image_read("images/labs.png")

img <- image_read("images/california.png")

# Again, create shadow from just state border without annotations
s <- image_shadow_mask(img, geometry = "30x30-20+10") |> 
  image_background("white")

out <- image_mosaic(c(s, img_labs)) |> 
  image_background("white")

image_write(out, "cali_out.png")

