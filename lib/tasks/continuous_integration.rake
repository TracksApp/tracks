task :ci => ['db:migrate', :test, :cucumber]
