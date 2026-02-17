resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-users"

  alias_attributes = ["email"]
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
    temporary_password_validity_days = 7
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_group" "users" {
  name         = "users"
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Regular users who can submit and view their own tickets"
}

resource "aws_cognito_user_group" "admins" {
  name         = "admins"
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Administrators who can view all tickets and update statuses"
}

resource "aws_cognito_user_pool_client" "customer_portal" {
  name         = "customer-portal"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  refresh_token_validity = 30
  access_token_validity  = 60
  id_token_validity      = 60

  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  prevent_user_existence_errors = "ENABLED"

  read_attributes = [
    "email",
    "email_verified"
  ]

  write_attributes = [
    "email"
  ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = var.customer_portal_callback_urls
  logout_urls                          = var.customer_portal_logout_urls
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user_pool_client" "internal_portal" {
  name         = "internal-portal"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  refresh_token_validity = 30
  access_token_validity  = 60
  id_token_validity      = 60

  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  prevent_user_existence_errors = "ENABLED"

  read_attributes = [
    "email",
    "email_verified"
  ]

  write_attributes = [
    "email"
  ]
}

resource "aws_cognito_user" "test_user" {
  user_pool_id = aws_cognito_user_pool.main.id
  username     = "testuser"

  attributes = {
    email          = "testuser@faultline.demo"
    email_verified = true
  }

  temporary_password = "TempPass123!"

  lifecycle {
    ignore_changes = [
      temporary_password,
      attributes["email_verified"]
    ]
  }
}

resource "aws_cognito_user" "test_admin" {
  user_pool_id = aws_cognito_user_pool.main.id
  username     = "testadmin"

  attributes = {
    email          = "testadmin@faultline.demo"
    email_verified = true
  }

  temporary_password = "TempPass123!"

  lifecycle {
    ignore_changes = [
      temporary_password,
      attributes["email_verified"]
    ]
  }
}

resource "aws_cognito_user_in_group" "test_user_membership" {
  user_pool_id = aws_cognito_user_pool.main.id
  group_name   = aws_cognito_user_group.users.name
  username     = aws_cognito_user.test_user.username
}

resource "aws_cognito_user_in_group" "test_admin_membership" {
  user_pool_id = aws_cognito_user_pool.main.id
  group_name   = aws_cognito_user_group.admins.name
  username     = aws_cognito_user.test_admin.username
}
