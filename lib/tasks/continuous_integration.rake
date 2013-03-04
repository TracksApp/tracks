task :ci => ['db:schema:load', :test, :cucumber]
