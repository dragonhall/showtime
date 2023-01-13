# frozen_string_literal: true

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable,
  # :trackable, :validatable,  :registerable,
  devise :database_authenticatable, :recoverable, :rememberable

  belongs_to :group

  def super_admin?
    group_id == Group.first.id
  end
end
