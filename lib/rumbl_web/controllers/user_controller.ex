defmodule RumblWeb.UserController do
  use RumblWeb, :controller

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  plug :authenticate_user when action in [:index, :show]

  def index(conn, _params) do
    render conn, "index.html", users: Accounts.list_users()
  end

  def new(conn, _params) do
    changeset = Accounts.change_registration(%User{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def show(conn, %{"id" => id}) do
    render conn, "show.html", user: Accounts.get_user(id)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
