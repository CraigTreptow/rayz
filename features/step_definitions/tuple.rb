Given('this will pass') do
  @this_will_pass = true
end

Given('this will fail') do
  @this_will_pass = false
end

When('I do an action') do
  :no_op
end

Then("some results should be there") do
  expect(@this_will_pass).to be true
end
