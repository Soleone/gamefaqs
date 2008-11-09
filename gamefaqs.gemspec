lib_files  = %w[caching faq game list platform review search]
test_files = %w[gamefaqs_test]
mock_files = %w[reviews_response search_response]

# add all files from one directory
module Helper
  def self.all_from_dir(dir_name, array, extension=".rb")
    array.map { |file| "#{dir_name}/#{file}#{extension}" }
  end
end

Gem::Specification.new do |s|
  s.name     = "gamefaqs"
  s.version  = "0.0.2"
  s.date     = "2008-11-09"
  s.summary  = "Webcrawler for fetching information about games from www.gamefaqs.com"
  s.email    = "soleone@gmail.com"
  s.homepage = "http://github.com/soleone/gamefaqs"
  s.description = "Ruby library for fetching information about games from www.gamefaqs.com using Hpricot"
  s.has_rdoc = true
  s.authors  = ["Dennis Theisen"]
  s.files    = ["lib/gamefaqs.rb"] + Helper.all_from_dir("lib/gamefaqs", lib_files)
  s.test_files = Helper.all_from_dir("test", test_files) + Helper.all_from_dir("test/mocks", mock_files, ".html")
  s.rdoc_options = ["--main", "README.textile"]
  s.extra_rdoc_files = ["README.textile"]
  s.add_dependency("hpricot", ["> 0.6.0"])
end
