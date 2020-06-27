# frozen_string_literal: true

class User < ApplicationRecord
  CareerPaths = %w[
    academia
    entrepeneurship
    established_company
    freelance
    management
    research
    scaleup
    startup
  ].freeze

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :confirmation_pending, -> { where(confirmed_at: nil) }
  scope :mentor, -> { where(mentor: true) }
  scope :student, -> { where(mentor: false) }
  scope :active, -> { where(active: true) }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_feup_email, on: :create, if: -> { student? }

  after_create :reload
  before_save :clean_empty

  def clean_empty
    careers.select!(&:present?)
  end

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

  private

  def validate_feup_email
    return if email&.split('@')&.last&.casecmp('fe.up.pt')&.zero?

    errors.add(:email, :feup_address_required)
  end
end
