# Create 100 todos 

Apartment::Tenant.each do |tenant|
  100.times.with_index do |i|
      Todo.create(
          title: Faker::Lorem.sentence(word_count: 3),
          details: Faker::Lorem.paragraph(sentence_count: 3),
      )
      puts "Created todo #{i + 1}"
  end
end
