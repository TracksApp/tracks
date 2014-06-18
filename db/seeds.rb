# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "Seeding..."
ActiveRecord::Base.transaction do
  user = User.create!(
    login: "teatro",
    password: "teatro",
    password_confirmation: "teatro",
    is_admin: true,
    first_name: "John",
    last_name: "Doe",
    auth_type: "database"
  )

  user.create_preference!

  context = Context.create!(
    name: "work",
    user_id: user.id,
    state: "active"
  )

  project = Project.create!(
    name: "Teatro Development",
    user_id: user.id,
    state: "active"
  )

  Todo.create!([
    {
      context_id: context.id,
      project_id: nil,
      description: "Create a to-do list",
      due: 5.days.from_now,
      completed_at: 1.day.ago,
      user_id: 1,
      state: "completed"
    }, {
      context_id: context.id,
      project_id: nil,
      description: "Put a check mark",
      user_id: 1,
      state: "active"
    }, {
      context_id: context.id,
      project_id: nil,
      description: "Have a fun",
      user_id: 1,
      state: "active"
    }, {
      context_id: context.id,
      project_id: project.id,
      description: "Create a project",
      user_id: 1,
      state: "active"
    }, {
      context_id: context.id,
      project_id: project.id,
      description: "Have a dinner",
      notes: "Visit a good restaurant",
      user_id: 1,
      state: "active"
    }, {
      context_id: context.id,
      project_id: project.id,
      description: "Write a code",
      due: 3.days.from_now,
      user_id: 1,
      state: "active"
    }
  ])

  puts "Seeding done"
end
