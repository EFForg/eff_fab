def create_standard_teams
  FactoryGirl.create(:team, name: "Activism", weight: 1)
  FactoryGirl.create(:team, name: "International", weight: 2)
  FactoryGirl.create(:team, name: "Web Development", weight: 3)
  FactoryGirl.create(:team, name: "Tech Projects", weight: 4)
  FactoryGirl.create(:team, name: "Tech Ops", weight: 5)
  FactoryGirl.create(:team, name: "Press/Graphics", weight: 6)
  FactoryGirl.create(:team, name: "Legal", weight: 7)
  FactoryGirl.create(:team, name: "Development", weight: 8)
  FactoryGirl.create(:team, name: "Finance/HR", weight: 13)
  FactoryGirl.create(:team, name: "Operations", weight: 14)
  FactoryGirl.create(:team, name: "Executive", weight: 15)
end
