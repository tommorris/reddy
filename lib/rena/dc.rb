#
# Copyright (c) 2004 Masahiro Sakai <sakai@tom.sfc.keio.ac.jp>
# You can redistribute it and/or modify it under the same term as Ruby.
#

# FIXME
# http://dublincore.org/2003/03/24/dces#
module Rena::DC
  Prefix    = "dc".freeze
  Namespace = "http://purl.org/dc/elements/1.1/".freeze

  # predicate
  Title = URI.parse(Namespace + "title").freeze
  Date  = URI.parse(Namespace + "date").freeze
end
