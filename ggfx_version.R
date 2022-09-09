library(ggfx)

states |> 
  filter(NAME == "California") |> 
  ggplot() +
  with_shadow(geom_sf(fill = "white", size = .5),
              size = 30, x_offset = -10, y_offset = 20, sigma = 10) +
  #geom_sf_text(data = these, aes(label = NAMELSAD)) +
  coord_sf(crs = 3309, clip = "off") +
  theme_void()


library(wisconsink12)

make_mke_schools() |> 
  filter(str_detect(dpi_true_id, "^3619") & broad_agency_type == "Independently Operated" &
           school_year == "2020-21")
