Gem::Specification.new do |s|
  s.name = ""
  s.version = "0.0.2"
  s.date = "2008-10-5"
  s.summary = "Ruby RDF library."
  s.email = "tom@tommorris.org"
  s.homepage = "http://github.com/tommorris/"
  s.description = "Rena is a Ruby library for manipulating RDF files."
  s.has_rdoc = true
  s.authors = ['Tom Morris', 'Pius Uzamere', 'Patrick Sinclair']
  s.files = ["README.txt", "Rakefile", ".gemspec", "lib/.rb", "lib//bnode.rb", "lib//graph.rb", "lib//literal.rb", "lib//n3parser.rb", "lib//n3_grammar.treetop", "lib//namespace.rb", "lib//rdfxmlparser.rb", "lib//rexml_hacks.rb", "lib//triple.rb", "lib//uriref.rb", "lib//exceptions/about_each_exception.rb", "lib//exceptions/uri_relative_exception.rb"]  
  s.test_files = ["test/test_uris.rb", "test/xml.rdf", "spec/bnode_spec.rb", "spec/graph_spec.rb", "spec/literal_spec.rb", "spec/namespaces_spec.rb", "spec/parser_spec.rb", "spec/rexml_hacks_spec.rb", "spec/triple_spec.rb", "spec/uriref_spec.rb"]
  #s.rdoc_options = ["--main", "README.txt"]
  #s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.add_dependency("addressable", [">= 1.0.4"])
  s.add_dependency("treetop", [">= 1.2.4"])
end
