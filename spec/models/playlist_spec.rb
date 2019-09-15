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
    # create :video, path: '/var/intro.mpg',
    #        metadata: {
    #            'title' => 'Intro foo',
    #            'length' => 1.minutes
    #        },
    #        pegi_rating: 'pegi_3',
    #        video_type: 'intro'
    create :intro
  end

  let(:channel) do
    group.save! if group.new_record?
    create :channel
  end

  context :wrap_films! do
    context 'with 1 film' do
      let(:playlist) do
        pl = channel.playlists.create! intro_id: intro.id,
                                       title: 'MyString',
                                       start_time: 1.hours.from_now
        pl.tracks.create(video_id: video.id)

        pl
      end

      let(:wrapped_playlist) do
        playlist.wrap_films!
        playlist.reload
      end

      it 'has 3 tracks' do
        expect(wrapped_playlist.tracks.count).to equal 3
      end

      it 'renumbers tracks' do
        expect(wrapped_playlist.tracks.collect(&:position)).to eq [1, 2, 3]
      end

      it 'adds intro around the film' do
        expect(wrapped_playlist.tracks.first.video_id).to eq intro.id
        expect(wrapped_playlist.tracks.first.position).to eq 1

        expect(wrapped_playlist.tracks.films.first.position).to eq 2

        expect(wrapped_playlist.tracks.last.video_id).to eq intro.id
        expect(wrapped_playlist.tracks.last.position).to eq 3
      end
    end

    context 'with 2 films' do
      let :playlist do
        pl = channel.playlists.create! intro_id: intro.id, title: 'MyString 2', start_time: 2.hours.from_now
        videos = [0, 1].map { create :film }
        videos.each { |video| pl.tracks.create(video_id: video.id) }

        pl
      end

      let :wrapped_playlist do
        playlist.wrap_films!
        playlist.reload
      end

      it 'has 6 tracks' do
        expect(wrapped_playlist.tracks.count).to equal 6
      end

      it 'adds intro around the films' do
        # @type Video[]
        videos = wrapped_playlist.tracks.collect(&:video)

        expect(videos[0].id).to eq intro.id
        expect(videos[1].id).to_not eq intro.id
        expect(videos[1].video_type).to eq 'film'
        expect(videos[2].id).to eq intro.id
        expect(videos[3].id).to eq intro.id
        expect(videos[4].video_type).to eq 'film'
        expect(videos[5].id).to eq intro.id
      end
    end
  end
end
