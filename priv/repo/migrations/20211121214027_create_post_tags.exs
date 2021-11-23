defmodule StadlerNo.Repo.Migrations.CreatePostTags do
  use Ecto.Migration

  def change do
    create table(:posts_tags) do
      add(:post_id, references(:posts))
      add(:tag_id, references(:tags))
      timestamps()
    end

    create(index(:posts_tags, [:tag_id]))
    create(index(:posts_tags, [:post_id]))

    create(unique_index(:posts_tags, [:post_id, :tag_id], name: :post_id_tag_id_unique_index))
  end
end
