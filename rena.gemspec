Gem::Specification.new do |s|
  s.name = "rena"
  s.version = "0.0.1"
  s.date = "2008-07-13"
  s.summary = "Ruby RDF library."
  s.email = "tom@tommorris.org"
  s.homepage = "http://github.com/tommorris/rena"
  s.description = "Rena is a Ruby library for manipulating RDF files."
  s.has_rdoc = true
  s.authors = ['Tom Morris', 'Pius Uzamere']
  s.files = ["README.txt", "Rakefile", "rena.gemspec", "lib/rena.rb", "lib/rena/bnode.rb", "lib/rena/graph.rb", "lib/rena/literal.rb", "lib/rena/namespace.rb", "lib/rena/rdfxmlparser.rb", "lib/rena/rexml_hacks.rb", "lib/rena/triple.rb", "lib/rena/uriref.rb", "lib/rena/exceptions/about_each_exception.rb", "lib/rena/exceptions/uri_relative_exception.rb"]
  s.test_files = ["test/test_uris.rb", "test/xml.rdf", "test/spec/bnode.spec.rb", "test/spec/graph.spec.rb", "test/spec/literal.spec.rb", "test/spec/namespaces.spec.rb", "test/spec/parser.spec.rb", "test/spec/rexml_hacks.spec.rb", "test/spec/triple.spec.rb", "test/spec/uriref.spec.rb"]
  #s.rdoc_options = ["--main", "README.txt"]
  #s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.add_dependency("addressable", ["> 0.0.1"])
end