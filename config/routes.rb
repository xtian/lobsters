# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index',
       protocol: (Rails.application.config.force_ssl ? 'https://' : 'http://'),
       as: :root

  get '/ping.txt', to: proc { [200, {}, ['ok']] }

  get '/404', to: 'home#four_oh_four', via: :all

  get '/rss', to: 'home#index', format: 'rss'
  get '/hottest', to: 'home#index', format: 'json'

  get '/page/:page', to: 'home#index'

  get '/newest', to: 'home#newest'
  get '/newest/page/:page', to: 'home#newest'
  get '/newest/:user', to: 'home#newest_by_user'
  get '/newest/:user/page/:page', to: 'home#newest_by_user'
  get '/recent', to: 'home#recent'
  get '/recent/page/:page', to: 'home#recent'
  get '/hidden', to: 'home#hidden'
  get '/hidden/page/:page', to: 'home#hidden'
  get '/saved', to: 'home#saved'
  get '/saved/page/:page', to: 'home#saved'

  get '/upvoted', to: 'home#upvoted'
  get '/upvoted/page/:page', to: 'home#upvoted'

  get '/top', to: 'home#top'
  get '/top/page/:page', to: 'home#top'
  get '/top/:length', to: 'home#top'
  get '/top/:length/page/:page', to: 'home#top'

  get '/threads', to: 'comments#threads'
  get '/threads/:user', to: 'comments#threads', as: :user_threads

  get '/replies', to: 'replies#all'
  get '/replies/page/:page', to: 'replies#all'
  get '/replies/comments', to: 'replies#comments'
  get '/replies/comments/page/:page', to: 'replies#comments'
  get '/replies/stories', to: 'replies#stories'
  get '/replies/stories/page/:page', to: 'replies#stories'
  get '/replies/unread', to: 'replies#unread'
  get '/replies/unread/page/:page', to: 'replies#unread'

  get '/login', to: 'login#index'
  post '/login', to: 'login#login'
  post '/logout', to: 'login#logout'
  get '/login/2fa', to: 'login#twofa'
  post '/login/2fa_verify', to: 'login#twofa_verify', as: :twofa_login

  get '/signup', to: 'signup#index'
  post '/signup', to: 'signup#signup'
  get '/signup/invite', to: 'signup#invite'

  get '/login/forgot_password', to: 'login#forgot_password',
                                as: :forgot_password
  post '/login/reset_password', to: 'login#reset_password',
                                as: :reset_password
  match '/login/set_new_password', to: 'login#set_new_password',
                                   as: :set_new_password, via: %i[get post]

  get '/t/:tag', to: 'home#tagged', as: :tag
  get '/t/:tag/page/:page', to: 'home#tagged'

  get '/search', to: 'search#index'
  get '/search/:q', to: 'search#index'

  resources :stories do
    post 'upvote'
    post 'downvote'
    post 'unvote'
    post 'undelete'
    post 'hide'
    post 'unhide'
    post 'save'
    post 'unsave'
    get 'suggest'
    post 'suggest', action: 'submit_suggestions'
  end

  post '/stories/fetch_url_attributes', format: 'json'
  post '/stories/preview', to: 'stories#preview'
  post '/stories/check_url_dupe', to: 'stories#check_url_dupe'

  resources :comments do
    member do
      get 'reply'
      post 'upvote'
      post 'downvote'
      post 'unvote'

      post 'delete'
      post 'undelete'
      post 'disown'
    end
  end

  get '/comments/page/:page', to: 'comments#index'
  get '/comments', to: 'comments#index'

  get '/messages/sent', to: 'messages#sent'
  get '/messages', to: 'messages#index'
  post '/messages/batch_delete', to: 'messages#batch_delete',
                                 as: :batch_delete_messages

  resources :messages do
    post 'keep_as_new'
    post 'mod_note'
  end

  get '/c/:id', to: 'comments#redirect_from_short_id'
  get '/c/:id.json', to: 'comments#show_short_id', format: 'json'

  # deprecated
  get '/s/:story_id/:title/comments/:id', to: 'comments#redirect_from_short_id'

  get '/s/:id/(:title)', to: 'stories#show'

  get '/u', to: 'users#tree'
  get '/u/:username', to: 'users#show', as: :user

  post '/users/:username/ban', to: 'users#ban', as: :user_ban
  post '/users/:username/unban', to: 'users#unban', as: :user_unban
  post '/users/:username/disable_invitation', to: 'users#disable_invitation',
                                              as: :user_disable_invite
  post '/users/:username/enable_invitation', to: 'users#enable_invitation',
                                             as: :user_enable_invite

  get '/settings', to: 'settings#index'
  post '/settings', to: 'settings#update'
  post '/settings/delete_account', to: 'settings#delete_account',
                                   as: :delete_account
  get '/settings/2fa', to: 'settings#twofa', as: :twofa
  post '/settings/2fa_auth', to: 'settings#twofa_auth', as: :twofa_auth
  get '/settings/2fa_enroll', to: 'settings#twofa_enroll',
                              as: :twofa_enroll
  get '/settings/2fa_verify', to: 'settings#twofa_verify',
                              as: :twofa_verify
  post '/settings/2fa_update', to: 'settings#twofa_update',
                               as: :twofa_update

  post '/settings/pushover_auth', to: 'settings#pushover_auth'
  get '/settings/pushover_callback', to: 'settings#pushover_callback'
  get '/settings/github_auth', to: 'settings#github_auth'
  get '/settings/github_callback', to: 'settings#github_callback'
  post '/settings/github_disconnect', to: 'settings#github_disconnect'
  get '/settings/twitter_auth', to: 'settings#twitter_auth'
  get '/settings/twitter_callback', to: 'settings#twitter_callback'
  post '/settings/twitter_disconnect', to: 'settings#twitter_disconnect'

  get '/filters', to: 'filters#index'
  post '/filters', to: 'filters#update'

  get '/tags', to: 'tags#index'
  get '/tags.json', to: 'tags#index', format: 'json'
  get '/tags/new', to: 'tags#new', as: :new_tag
  get '/tags/:id/edit', to: 'tags#edit', as: :edit_tag
  post '/tags', to: 'tags#create'
  post '/tags/:id', to: 'tags#update', as: :update_tag

  post '/invitations', to: 'invitations#create'
  get '/invitations', to: 'invitations#index'
  get '/invitations/request', to: 'invitations#build'
  post '/invitations/create_by_request', to: 'invitations#create_by_request',
                                         as: :create_invitation_by_request
  get '/invitations/confirm/:code', to: 'invitations#confirm_email'
  post '/invitations/send_for_request', to: 'invitations#send_for_request',
                                        as: :send_invitation_for_request
  get '/invitations/:invitation_code', to: 'signup#invited'
  post '/invitations/delete_request', to: 'invitations#delete_request',
                                      as: :delete_invitation_request

  get '/hats', to: 'hats#index'
  get '/hats/build_request', to: 'hats#build_request',
                             as: :request_hat
  post '/hats/create_request', to: 'hats#create_request',
                               as: :create_hat_request
  get '/hats/requests', to: 'hats#requests_index'
  post '/hats/approve_request/:id', to: 'hats#approve_request',
                                    as: :approve_hat_request
  post '/hats/reject_request/:id', to: 'hats#reject_request',
                                   as: :reject_hat_request

  get '/moderations', to: 'moderations#index'
  get '/moderations/page/:page', to: 'moderations#index'
  get '/moderators', to: 'users#tree', moderators: true

  get '/mod', to: 'mod#index'
  get '/mod/flagged/:period', to: 'mod#flagged', as: :mod_flagged
  get '/mod/downvoted/:period', to: 'mod#downvoted', as: :mod_downvoted
  get '/mod/commenters/:period', to: 'mod#commenters', as: :mod_commenters
  get '/mod/notes(/:period)', to: 'mod_notes#index', as: :mod_notes
  post '/mod/notes', to: 'mod_notes#create'

  get '/privacy', to: 'home#privacy'
  get '/about', to: 'home#about'
  get '/chat', to: 'home#chat'
end
