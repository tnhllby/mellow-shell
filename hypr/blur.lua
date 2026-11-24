-- Blur the live windows behind MELLOW, also when xray is on.
hl.layer_rule({ name = "mellow-live-blur", match = { namespace = "^mellow:" }, xray = false })
