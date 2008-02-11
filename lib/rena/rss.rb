#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

# http://www.purl.org/rss/1.0/spec
module Rena::RSS
  Prefix    = "rss".freeze
  Namespace = "http://purl.org/rss/1.0/".freeze

  # class
  Channel = URI.parse(Namespace + "channel").freeze
  Item    = URI.parse(Namespace + "item").freeze
  Image   = URI.parse(Namespace + "image").freeze

  # predicates
  Title       = URI.parse(Namespace + "title").freeze
  Link        = URI.parse(Namespace + "link").freeze
  Description = URI.parse(Namespace + "description").freeze
  #Image       = URI.parse(Namespace + "image").freeze
  Items       = URI.parse(Namespace + "items").freeze
  TextInput   = URI.parse(Namespace + "textinput").freeze
  Name        = URI.parse(Namespace + "name").freeze
end
