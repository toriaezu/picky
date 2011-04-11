# Tasks for testing your engine configuration in the terminal.
#
desc 'Simple terminal search - pass it an URL to search on, e.g. /books.'
task :search do
  load File.expand_path '../../picky/auxiliary/terminal.rb', __FILE__
  url_or_path = ARGV[1] || raise("Usage:\n  rake search <URL> [<result ids>]\n  E.g. rake search /books\n       rake search localhost:8080/books")
  ids         = ARGV[2]
  terminal = Terminal.new url_or_path, ids
  terminal.run
end