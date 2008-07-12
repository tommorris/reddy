require 'lib/rena'

# W3C test suite: http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/

describe "RDFa parser" do
  it "should be able to pass xhtml1-0001.xhtml" do
    sampledoc = <<-EOF;
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:dc="http://purl.org/dc/elements/1.1/">
    <head>
    	<title>Test 0001</title>
    </head>
    <body>
    	<p>This photo was taken by <span class="author" about="photo1.jpg" property="dc:creator">Mark Birbeck</span>.</p>
    </body>
    </html>
    EOF
    
    parser = RdfaParser.new(sampledoc, uri = "http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/0001.xhtml")
    parser.graph.size.should == 1
  end
end