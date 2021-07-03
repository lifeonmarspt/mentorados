# frozen_string_literal: true

UserPolicy = Struct.new(:current_user, :record) do
  def edit?
    current_user == record && current_user.mentor?
  end

  def update?
    current_user == record && current_user.mentor?
  end

  def permitted_attributes_for_update
    [
      :active,
      :bio_en,
      :bio_pt,
      :email,
      :location,
      :name,
      :picture,
      :url_text,
      :year_in,
      :year_out,
      tag_ids: [],
    ]
  end
end
