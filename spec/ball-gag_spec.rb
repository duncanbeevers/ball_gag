require 'spec_helper'

describe 'Plain Old Ruby Object' do
  it 'should have no gagged attributes' do
    ActiveModelExample.gagged_attributes.should be_empty
  end

end

