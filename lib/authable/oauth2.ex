defmodule Authable.OAuth2 do
  @moduledoc """
  OAut2 authorization strategy router
  """

  alias Authable.AuthorizationCodeGrantType
  alias Authable.ClientCredentialsGrantType
  alias Authable.PasswordGrantType
  alias Authable.RefreshTokenGrantType

  @repo Application.get_env(:authable, :repo)
  @token Application.get_env(:authable, :token_store)
  @client Application.get_env(:authable, :client)
  @app Application.get_env(:authable, :app)
  @strategies Application.get_env(:authable, :strategies)
  @scopes Application.get_env(:authable, :scopes)

  def authorize(params) do
    strategy_check(params["grant_type"])
    case params["grant_type"] do
      "authorization_code" -> AuthorizationCodeGrantType.authorize(params)
      "client_credentials" -> ClientCredentialsGrantType.authorize(params)
      "password" -> PasswordGrantType.authorize(params)
      "refresh_token" -> RefreshTokenGrantType.authorize(params)
    end
  end

  def authorize_app(user, params) do
    @repo.get_by!(@client, id: params["client_id"],
                  redirect_uri: params["redirect_uri"])
    app = @repo.get_by(@app, user_id: user.id, client_id: params["client_id"])


    if is_nil(app) do
      @repo.insert!(@app.changeset(%@app{}, %{
        user_id: user.id,
        client_id: params["client_id"],
        scope: params["scope"]
      }))
    else
      if app.scope != params["scope"] do
        scope = params["scope"]
        |> String.split(",")
        |> Enum.concat(String.split(app.scope, ","))
        |> Enum.uniq()
        scope = @scopes -- (@scopes -- scope)
        @repo.update!(@app.changeset(app, %{scope: Enum.join(scope, ",")}))
      end
    end
  end

  def revoke_app_authorization(user, params) do
    app = @repo.get_by!(@app, id: params["id"], user_id: user.id)
    @repo.delete!(app)

    tokens = @repo.all(@token, user_id: user.id)
    Enum.map(tokens, fn token ->
        if Map.get(token.details, "client_id", "") == app.client_id do
          @repo.delete!(token)
        end
      end
    )
  end

  defp strategy_check(grant_type) do
    unless @strategies[String.to_atom(grant_type)] do
      raise Authable.SuspiciousActivityError,
        message: "Strategy for '#{grant_type}' is not enabled!"
    end
  end
end