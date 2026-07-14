resource "azurerm_resource_group" "rg" {
  name     = "rg-${{ values.webAppName }}-${{ values.location }}"
  location = "${{ values.location }}"
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${{ values.webAppName }}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "${{ values.sku }}"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "${{ values.webAppName }}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      # Injects Node 24 LTS or selected runtime dynamically
      node_version = split("|", "${{ values.runtime }}")[0] == "node" ? split("|", "${{ values.runtime }}")[1] : null
      dotnet_version = split("|", "${{ values.runtime }}")[0] == "dotnet" ? split("|", "${{ values.runtime }}")[1] : null
    }
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "~24"
    "NODE_ENV"                     = "production"
  }
}
