# coding: utf-8

User.create!( name: "admin-user",
              email: "admin@email.com",
              password: "password",
              password_confirmation: "password",
              admin: true
              )

User.create!( name: "boss-user",
              email: "boss@email.com",
              password: "password",
              password_confirmation: "password",
              boss: true
              )
              
5.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!( name: name,
                email: email,
                password: password,
                password_confirmation: password
                )
end