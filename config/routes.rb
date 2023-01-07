# frozen_string_literal: true

require 'resque_web'
require 'resque/status/web'
#
# class DomainConstraint
#   def initialize(domain = nil, inverse = false)
#     @domain = domain
#     @inverse = inverse
#   end
#
#   def matches?(request)
#
#     return false if @domain.nil? or "#{@domain}".empty?
#
#     host = "#{request.host}"
#
#     if request.subdomain == 'www'
#       host = host[4..-1]
#     end
#
#
#     ret = @domain.is_a?(Regexp) ? @domain.match(host) : @domain == host
#
#     @inverse ? !ret : ret
#   end
# end

Rails.application.routes.draw do
  devise_for :admins

  resources :channels do
    resources :playlists do
      member do
        get :play
        get :program
      end

      collection do
        get :current_program
      end

      resources :tracks do
        collection do
          post 'reorder'
          post 'wrap'
        end
      end
    end
  end

  resources :videos do
    collection do
      get 'autocomplete'
    end
  end

  # resources :footages, constraints: DomainConstraint.new(/^tv\./)

  # get '/viewers/:id', to: 'viewers#show',
  #                     constraints: {id: /\d+/}, as: 'viewer'
  # post '/viewers/kill/:id', to: 'viewers#kill', as: 'viewer_kill'
  # post '/viewers/block/:id', to: 'viewers#block', as: 'viewer_block'

  resources :viewers do
    member do
      get 'kill'
      get 'block'
    end
  end

  root to: 'dashboard#index'

  authenticated :admin do
    mount ResqueWeb::Engine => '/job_status'
  end
end
