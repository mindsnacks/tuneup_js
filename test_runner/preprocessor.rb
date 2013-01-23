class Preprocessor
  def self.process(file, app_name)
    self.process_imports(file, app_name, [])
  end
  
private
  IMPORT_STATEMENT = /#import "([^"]+)"/
  BUNDLE_ID_PLACEHOLDER = /\{bundle_id\}/
  def self.process_imports(file, app_name, imported_file_names)
    content = File.read(file)

    content.gsub(IMPORT_STATEMENT) do
      parsed_file_name = $1.gsub(BUNDLE_ID_PLACEHOLDER, app_name)
      import_file = File.join(File.dirname(file), parsed_file_name)

      next if imported_file_names.include? import_file
      imported_file_names << import_file

      begin
        "// begin #{File.basename(parsed_file_name)}" << "\n" <<
        process_imports(import_file, app_name, imported_file_names) << "\n" <<
        "// end #{File.basename(parsed_file_name)}" << "\n"
      rescue Exception => e
        STDERR.puts "Unable to process file #{import_file}: #{e}"
        $&
      end
    end
  end
end