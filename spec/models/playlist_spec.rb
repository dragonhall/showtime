# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Playlist, type: :model do
  # Simulate db/seeds.rb
  let(:group) { create :group, name: 'FullAdmin' }
  let(:admin) do
    create :admin, name: 'Atyauristen',
                   email: 'admin@example.com',
                   password: 'secret',
                   password_confirmation: 'secret',
                   group_id: group.id
  end
  let(:video) do
    create :video, path: '/var/film.mpg',
                   metadata: {
                     'title' => 'Foobar',
                     'length' => 45.minutes
                   },
                   pegi_rating: 'pegi_3',
                   video_type: 'film'
  end
  let(:intro) do
    create :video, path: '/var/intro.mpg',
                   metadata: {
                     'title' => 'Intro foo',
                     'length' => 1.minutes
                   },
                   pegi_rating: 'pegi_3',
                   video_type: 'intro'
  end

  context :finalize! do
    let(:channel) do
      group.save!
      create :channel
    end

    let(:playlist) do
      pl = channel.playlists.create! intro_id: intro.id,
                                     title: 'MyString',
                                     start_time: 1.hours.from_now
      pl.tracks.create(video_id: video.id)

      pl
    end

    let(:finalized_playlist) do
      playlist.finalize! unless playlist.finalized?
      playlist.reload
    end

    it 'has 3 tracks' do
      expect(finalized_playlist.tracks.count).to equal 3
    end

    it 'renumbers tracks' do
      expect(finalized_playlist.tracks.collect(&:position)).to eq [1, 2, 3]
    end

    it 'adds intro around the film' do
      expect(finalized_playlist.tracks.first.video_id).to eq intro.id
      expect(finalized_playlist.tracks.first.position).to eq 1

      expect(finalized_playlist.tracks.films.first.position).to eq 2

      expect(finalized_playlist.tracks.last.video_id).to eq intro.id
      expect(finalized_playlist.tracks.last.position).to eq 3
    end
  end
end
