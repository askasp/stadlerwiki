defmodule StadlerNo.WikiFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StadlerNo.Wiki` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> StadlerNo.Wiki.create_post()

    post
  end
end
