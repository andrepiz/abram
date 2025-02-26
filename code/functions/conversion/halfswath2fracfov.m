function fracfov = halfswath2fracfov(hs_max, hs_min, Rbody, d_body2cam, fov)

br_max = atan(Rbody*sin(hs_max)./(d_body2cam - Rbody*cos(hs_max)));
br_min = atan(Rbody*sin(hs_min)./(d_body2cam - Rbody*cos(hs_min)));
fracfov = (br_max - br_min)./fov;

end