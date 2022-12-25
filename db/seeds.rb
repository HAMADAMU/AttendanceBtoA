# coding: utf-8

User.create!( name: "管理者",
              email: "admin@email.com",
              password: "password",
              password_confirmation: "password",
              admin: true,
              affiliation: "管理部",
              employee_number: 0,
              uid: 0
              )

User.create!( name: "上長A",
              email: "superior-a@email.com",
              password: "password",
              password_confirmation: "password",
              superior: true,
              affiliation: "技術部",
              employee_number: 1,
              uid: 1
              )

User.create!( name: "上長B",
              email: "superior-b@email.com",
              password: "password",
              password_confirmation: "password",
              superior: true,
              affiliation: "技術部",
              employee_number: 2,
              uid: 2
              )

User.create!( name: "上長C",
              email: "superior-c@email.com",
              password: "password",
              password_confirmation: "password",
              superior: true,
              affiliation: "技術部",
              employee_number: 3,
              uid: 3
              )

              
5.times do |n|
  name = Faker::Name.name
  email = "sample-#{n}@email.com"
  number = (n + 4)
  password = "password"
  User.create!( name: name,
                email: email,
                password: password,
                password_confirmation: password,
                affiliation: "技術部",
                employee_number: number,
                uid: number
                )
end