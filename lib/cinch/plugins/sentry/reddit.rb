require 'cinch'
require 'redditkit'
require 'twitter-text'
require 'uri'
require "sentry/helper"

module Cinch
  module Plugins
    module Sentry
      class Reddit
        include Cinch::Plugin
        include Twitter::Extractor

        # Fetch all github links
        listen_to :channel

        def initialize(*)
          super

          # Sign in
          RedditKit.sign_in config['username'], config['password']
        end

        def listen(m)
          # Make sure we are logged in
          if not RedditKit.signed_in?
            # Sign in again
            RedditKit.sign_in config['username'], config['password']
          end

          # Exctract urls
          urls = extract_urls(m.message)

          # Go through all links
          urls.each do |url|
            # Parse the url
            uri = URI.parse(URI.escape(url.to_url))

            # We only handle GitHub links
            case uri.host
            when "www.reddit.com", "reddit.com", "redd.it", "www.redd.it"
              begin
                if not uri.path.to_s.empty?
                  # Split the path by forward slash
                  split = uri.path.split "/"

                  # Check if we have a link to a sub-reddit or a user
                  case split[1]
                  when "r", "tb"
                    # We have a link to a sub-reddit
                    if split[3].nil? and not split[2].nil?
                      # Fetch the information about the subreddit
                      subreddit = RedditKit.subreddit(split[2])

                      # Reply with the information
                      m.reply("[%s] %s (subscribers: %s) (%s)" % [
                        Format(:green, "Reddit"),
                        Format(:bold, subreddit.title),
                        Format(:teal, subreddit.subscribers.to_s),
                        Format(if not subreddit.nsfw? then :green else :red end,
                               if not subreddit.nsfw? then "SFW" else "NSFW" end)])

                    # We have a link to a thread
                    elsif (split[3] == "comments" and not split[4].nil?) or (split[3] != "comments" and split[4].nil?)
                      # Fetch the thread id
                      id = if split[4].nil? then split[3] else split[4] end

                      # Fetch the information about the thread
                      thread = RedditKit.link("t3_" + id)

                      # Reply with the information
                      m.reply("[%s][%s] %s (upvotes: %s) (comments: %s) (link: %s) (%s)" % [
                          Format(:green, "Reddit"),
                          Format(:blue, thread.author),
                          Format(:bold, thread.title),
                          Format(:orange, thread.upvotes.to_s),
                          Format(:teal, thread.total_comments.to_s),
                          Format(:underline, thread.short_link),
                          Format(if not thread.nsfw? then :green else :red end,
                                 if not thread.nsfw? then "SFW" else "NSFW" end)])
                    end
                  when "u"
                    # Fetch the information about the user
                    user = RedditKit.user(split[2])

                    # Reply with the information
                    m.reply("[%s] %s (comment karma: %s) (link karma: %s)" % [
                      Format(:green, "Reddit"),
                      Format(:bold, user.name),
                      Format(:orange, user.comment_karma.to_s),
                      Format(:orange, user.link_karma.to_s)])
                  else
                    # We have a short-link for a thread

                    # Fetch the information about the thread
                    thread = RedditKit.link("t3_" + split[1])

                    # Reply with the information
                    m.reply("[%s][%s] %s (upvotes: %s) (comments: %s) (link: %s) (%s)" % [
                        Format(:green, "Reddit"),
                        Format(:blue, thread.author),
                        Format(:bold, thread.title),
                        Format(:orange, thread.upvotes.to_s),
                        Format(:teal, thread.total_comments.to_s),,
                        Format(:underline, thread.short_link),
                        Format(if not thread.nsfw? then :green else :red end,
                                 if not thread.nsfw? then "SFW" else "NSFW" end)])
                  end
                end
              rescue Exception => e
                # Log the exception
                puts e

                # Send back error message
                m.reply("[%s] %s" % [
                  Format(:green, "LINK"),
                  Format(:bold, "reddit: the frontpage of the internet")
                ])
              end
            end
          end
        end
      end
    end
  end
end