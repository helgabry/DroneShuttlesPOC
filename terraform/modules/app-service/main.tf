# create app service plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  kind     = "Linux"
  reserved = true

  sku {
    tier = var.app_service_plan_sku.tier
    size = var.app_service_plan_sku.size
  }
}

# create application insights
resource "azurerm_application_insights" "app_insights" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.application_insights_name
  application_type    = var.application_insights_type
}

# create azure app service
resource "azurerm_app_service" "app_service" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version  = "DOCKER|ghost:4-alpine"
    always_on                = true
  }

  identity {
    type = "SystemAssigned"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].linux_fx_version
    ]
  }

  app_settings = merge(var.application_settings, {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
  })
}

resource "azurerm_app_service_slot" "app_service_slot_blue" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version  = "DOCKER|ghost:4-alpine"
    always_on                = true
  }

  identity {
    type = "SystemAssigned"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].linux_fx_version
    ]
  }

  app_settings = merge(var.application_settings, {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
  })
}

resource "azurerm_monitor_autoscale_setting" "web-app-service-autoscale" {
  name                = "${azurerm_app_service.app_service.name}-autoscale"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  target_resource_id  = "${azurerm_app_service_plan.app_service_plan.id}"

  profile {
    name = "${var.location}-app-service-autoscale-profile"

    capacity {
      default = var.monitor_autoscale_capacity.default
      minimum = var.monitor_autoscale_capacity.minimum
      maximum = var.monitor_autoscale_capacity.maximum
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = "${azurerm_app_service_plan.app_service_plan.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = "${azurerm_app_service_plan.app_service_plan.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 50
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails = ["hany.elgabry@gmail.com"]
    }
  }
}
