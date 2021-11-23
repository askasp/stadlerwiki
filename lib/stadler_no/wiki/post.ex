defmodule StadlerNo.Wiki.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :title, :string

    many_to_many :relationships,
                 StadlerNo.Wiki.Post,
                 join_through: StadlerNo.Wiki.PostRelationship,
                 join_keys: [post_id: :id, relation_id: :id]

    many_to_many :reverse_relationships,
                 StadlerNo.Wiki.Post,
                 join_through: StadlerNo.Wiki.PostRelationship,
                 join_keys: [relation_id: :id, post_id: :id]

    many_to_many :tags,
                 StadlerNo.Wiki.Tag,
                 join_through: StadlerNo.Wiki.PostTag

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end

defmodule StadlerNo.Wiki.PostRelationship do
  use Ecto.Schema
  @attrs [:post_id, :relation_id]

  schema "postrelationships" do
    field :post_id, :id
    field :relation_id, :id

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, @attrs)
    |> Ecto.Changeset.unique_constraint(
      [:post_id, :relation_id],
      name: :relationships_person_id_relation_id_index
    )
    |> Ecto.Changeset.unique_constraint(
      [:relation_id, :post_id],
      name: :relationships_relation_id_post_id_index
    )
  end
end

defmodule StadlerNo.Wiki.PostAdmin do
  def form_fields(_) do
    [
      title: nil,
      body: %{type: :textarea, rows: 50}
    ]
  end
end
