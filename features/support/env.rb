require "minitest/autorun"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

classes = %w[canvas color util tuple point vector]

classes.each do |class_file_name|
  require class_file_name
end
