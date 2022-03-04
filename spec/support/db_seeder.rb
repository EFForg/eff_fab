def create_standard_teams
  FactoryBot.create(:team, name: "Activism", weight: 1)
  FactoryBot.create(:team, name: "International", weight: 2)
  FactoryBot.create(:team, name: "Web Development", weight: 3)
  FactoryBot.create(:team, name: "Tech Projects", weight: 4)
  FactoryBot.create(:team, name: "Tech Ops", weight: 5)
  FactoryBot.create(:team, name: "Press/Graphics", weight: 6)
  FactoryBot.create(:team, name: "Legal", weight: 7)
  FactoryBot.create(:team, name: "Development", weight: 8)
  FactoryBot.create(:team, name: "Finance/HR", weight: 13)
  FactoryBot.create(:team, name: "Operations", weight: 14)
  FactoryBot.create(:team, name: "Executive", weight: 15)
end
