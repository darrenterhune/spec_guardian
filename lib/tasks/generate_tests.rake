namespace :spec_guardian do
  desc 'Generate a test file for a given source file using AI'
  task :generate, [:file_path] => :environment do |t, args|
    if args[:file_path].nil?
      puts 'Error: Please provide a file path.'
      puts 'Usage: rake spec_guardian:generate[app/models/user.rb]'
      puts "You may need to use quotes if using zsh e.g. ['app/models/user.rb']"
      exit 1
    end

    SpecGuardian.generate_test(args[:file_path])
  end
end
