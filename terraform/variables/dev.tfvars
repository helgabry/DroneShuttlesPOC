resource_group_name = "drone-shutles-rg"
primary_location    = "West Europe"
secondary_location  = "North Europe"

app_service_plan_name = "drone-shutles-web-app-plan"
app_service_plan_sku = {
  tier = "Standard"
  size = "S1"
}

monitor_autoscale_capacity = {
  default = 4
  minimum = 4
  maximum = 10
}

app_service_name                      = "drone-shutles-web-app"
app_service_application_insights_name = "drone-shutles-web-app-insights"
mysql_database_username                 = "drone-shutles-db-admin"
traffic_manager_profile_name          = "drone-shutles-tm-profile"
