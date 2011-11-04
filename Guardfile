guard 'spork' do
  watch('spec/spec_helper.rb')
end

guard 'rspec', version: 2, cli: '--drb --color --format nested', all_after_pass: false do
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^lib\/ball-gag\/(.+)\.rb$/) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { 'spec' }
  watch(/spec\/support\/.+\.rb$/)    { 'spec' }
end

