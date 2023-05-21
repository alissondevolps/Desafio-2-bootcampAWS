#definindo o recurso do User Pool
resource "aws_cognito_user_pool" "example_user_pool" {
  name = "example-user-pool"
  # Outras configurações do User Pool
}

########################################################
#autenticar os usuários da API.
resource "aws_cognito_user_pool_client" "example_user_pool_client" {
  name         = "example-user-pool-client"
  user_pool_id = aws_cognito_user_pool.example_user_pool.id
  # Outras configurações do App Client
}

########################################################
#definindo o recurso do Authorizer, associado ao User Pool
resource "aws_api_gateway_authorizer" "example_authorizer" {
  name                   = "example-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.example_api.id
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [aws_cognito_user_pool.example_user_pool.arn]
  identity_source        = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = 300
}

##########################################################
#adicionando a configuração authorizer em cada recurso e método 
resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.example_authorizer.id
}

resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id     = aws_api_gateway_rest_api.example_api.id
  resource_id     = aws_api_gateway_resource.example_resource.id
  http_method     = aws_api_gateway_method.example_method.http_method
  type            = "AWS_PROXY"
  integration_http_method = "POST"
  uri             = "YOUR_LAMBDA_FUNCTION_ARN"
}
