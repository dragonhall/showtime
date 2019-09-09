module Rails
  class << self
    def public_dir
      Rails.root.join('public')
    end
  end
end
