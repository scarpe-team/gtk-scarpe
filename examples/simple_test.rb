Shoes.app do
  para "Here we are..."
  @push = button "Push me"
  @push.click {
    alert "Aha! Click!"
  }
end
