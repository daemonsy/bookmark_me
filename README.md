Bookmark Me
==============
This Rails app is a simple bookmarking tool that saves a URL you paste in. It was done as a technical exercise.

My command chain to run: (Ruby 1.9.2)
--------------------------------------------------------------------------

		bundle
		script/delayed_job start
		rails server

User Modeling
--------------------------------------------------------------------------
* Users should never lose a bookmark pasted into the box
* Most of the time, URLs will be pasted, not typed
* Tagging should be easy to do (using JS)

Core Modeling
--------------------------------------------------------------------------
* Bookmark
* Site
* Tag (using ActsAsTaggableOn)

The bookmark object is the core part of this app. When a user pastes in the url, it goes into `bookmark.full_url`. This string is parsed by `URI` to find the hostname (e.g. URL without path and query).
Before saving, a site is created if the same hostname does not exist. Either way, the link to go back the URL is always the full_url, i.e. the user should usually be linked to whatever he pasted into the box.

Originally, I wanted to remove `www.` and handle them as the same, but I realized that's assuming too much. Further reasoning is left in code comments.

Tagging is handled by a `has_many` polymorphic association abstracted by ActsAsTaggableOn.

Gem Usage
--------------------------------------------------------------------------
* pismo => Get basic meta-data from the bookmarks
* bitly => Ruby wrapper for accessing bit.ly API
* delayed_job => To run the two APIs above in the background queue
* acts-as-taggable-on => Simple tagging
* will_paginate
* twitter-bootstrap-rails
* [sqsearch](https://github.com/daemonsy/sqsearch) => a very mini SQL like search plugin written for the exercise

Javascript
--------------------------------------------------------------------------
* autoSuggest by Drew Wilson

The plugin above queries the tag controller for a json list of available tags when the user starts typing. jquery-tokeninput and Chosen were considered, but they were hard to manage for this usage.

Known Problems
==============
* The callback pattern in my Bookmark model causes a loop if the job is not handled async by delayed_job due to callbacks running again.
* Have not handled redirect with PISMO yet. Tricky because e.g. www.gmail.com leads you to multiple redirects.
* Some URLs have unique hashes, the moment it's bookmarked it's invalid already.

Next Up
==============
Iteration 2
--------------------------------------------------------------------------
* Writing tests
* Understanding how testing javascript works. It's scary that we depend on JS a lot for frontend usability, but it's much harder to make it work

Iteration 3
--------------------------------------------------------------------------
* Make the search gem a bit better. Now it's fragile and does nothing much.
* Better crawling of pages and their meta-data (e.g. handle redirect)
* Bells and Whistles => friendlyID, better views
* Caching
* Playing with bit.ly's API to get more information about the pages

Learnt and To Learn
==============
* How to deploy changes using Capistrano?
* Testing?
* How to write docs
* Take a look at HAML. Closing tags is tiring and error-prone
* How to use SASS properly

==============