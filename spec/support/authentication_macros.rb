module AuthenticationMacros
  def login(user)
    cookies[:auth_token] = user.auth_token
  end

  def logout
    cookies[:auth_token] = nil
  end

  def use_http_auth_token(token)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def use_http_auth_token_for(model)
    use_http_auth_token(model.auth_token)
  end
end
