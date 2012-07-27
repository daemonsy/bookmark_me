Bookmarkme::Application.routes.draw do
  root :to => "bookmarks#new"
  resources :bookmarks do
    collection do
      post :search
    end
  end
  
  resources :sites do
    collection do
      post :search
    end
  end
  
  resources :tags do
    collection do
      get :search 
    end
  end
end
