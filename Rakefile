desc "compile the shopbox.coffee to js and minify"
task :compile do
  system "coffee -c shopbox.coffee"
  system "java -jar bin/compiler.jar --js=shopbox.js > shopbox.min.js"
  puts("failed to compress coffee.js") if $?.exitstatus != 0
end