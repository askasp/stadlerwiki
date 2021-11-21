defmodule StadlerNo.Wiki.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    many_to_many :posts,
                 StadlerNo.Wiki.Tag,
                 join_through: StadlerNo.Wiki.PostTag


    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

defmodule StadlerNo.Wiki.PostTag do
  use Ecto.Schema
  @attrs [:post_id, :tag_id]

  schema "posts_tags" do
    belongs_to(:post, StadlerNo.Wiki.Post)
    belongs_to(:tag, StadlerNo.Wiki.Tag)
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, @attrs)
    |> Ecto.Changeset.foreign_key_constraint(:tag_id)
    |> Ecto.Changeset.foreign_key_constraint(:post_id)
    |> Ecto.Changeset.unique_constraint(
      [:post_id, :tag_id],
      name: :post_id_tag_id_unique_index
    )
  end
end



defmodule StadlerNo.Wiki.TagAdmin do
  def form_fields(_) do
    [
      name: nil,
    ]
  end
  end
