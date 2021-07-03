# frozen_string_literal: true

class User < ApplicationRecord
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :confirmation_pending, -> { where(confirmed_at: nil) }
  scope :mentor, -> { where(mentor: true) }
  scope :student, -> { where(mentor: false) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_feup_email, on: :create, if: -> { student? }

  belongs_to :invited_by, class_name: 'User', optional: true
  has_many :user_tags
  has_many :tags, through: :user_tags

  after_create :reload

  has_secure_password
  has_one_attached :picture

  def confirmed?
    !confirmed_at.nil?
  end

  def student?
    !mentor
  end

  def mentor?
    mentor
  end

  def urls
    url_text&.delete("\r")&.split("\n") || []
  end

  def confirm!
    update(confirmed_at: Time.current)
  end

  def location_locality
    location&.split(',')&.first&.strip
  end

  def location_country
    location&.split(',')&.second&.strip
  end

  def self.search_word(word)
    %w[users.name bio_en bio_pt location url_text year_in year_out tags.name->>'pt' tags.name->>'en'].map do |field|
      where(["unaccent(#{field}::text) ILIKE CONCAT('%', unaccent(?), '%')", word])
    end.reduce(&:or).joins(:tags).distinct
  end

  def self.search(query)
    return all if query.blank?

    sanitize_sql_like(query)
      .split(/\s/)
      .map { |word| search_word(word) }
      .reduce(all, &:merge)
  end

  private

  def validate_feup_email
    return if email&.split('@')&.last&.casecmp('fe.up.pt')&.zero?

    errors.add(:email, :feup_address_required)
  end
end
