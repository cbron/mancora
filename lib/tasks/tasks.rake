desc 'my plugins rake task'
task :mancora => :environment do
  puts "Mancora running..."
  Mancora.run
end