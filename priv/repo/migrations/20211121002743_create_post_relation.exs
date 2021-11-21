defmodule StadlerNo.Repo.Migrations.CreatePostRelation do
  use Ecto.Migration



  def change do
        create table(:postrelationships) do
    add :post_id, references(:posts)
    add :relation_id, references(:posts)
    timestamps()
  end

  create index(:postrelationships, [:post_id])
  create index(:postrelationships, [:relation_id])

  create unique_index(
    :postrelationships,
    [:post_id, :relation_id],
    name: :postrelationships_post_id_relation_id_index
  )
  create unique_index(
    :postrelationships,
    [:relation_id, :post_id],
    name: :postrelationships_relation_id_post_id_index
  )

  end

end


