require 'spec_helper'

describe 'Plain Old Ruby Object' do
  before do
    BallGag.engine = nil
    ExampleModel.clear_gagged_attributes
  end

  it 'should have no gagged attributes' do
    ExampleModel.gagged_attributes.should be_empty
  end

  it 'should gag attribute' do
    ExampleModel.gag :words
    ExampleModel.gagged_attributes.should include :words
  end

  it 'should gag multiple attributes' do
    ExampleModel.gag :words, :email
    ExampleModel.gagged_attributes.should include :words
    ExampleModel.gagged_attributes.should include :email
  end

  it 'should invoke callable with all attributes' do
    mock_callable = mock('callable')
    mock_callable.stub!(:respond_to?).
      with(:call).and_return(true)

    mock_words = mock('words')
    mock_email = mock('email')

    ExampleModel.gag :words, :email, mock_callable

    instance = ExampleModel.new
    instance.stub!(words: mock_words, email: mock_email)

    mock_callable.should_receive(:call).with(
      hash_including(words: mock_words, email: mock_email), instance).
      and_return({})

    instance.words_gagged?
  end

  it 'should cache the result of the callable' do
    mock_callable = mock('callable')
    mock_callable.stub!(:respond_to?).
      with(:call).and_return(true)

    ExampleModel.gag :words, :email, mock_callable

    mock_callable.should_receive(:call).
      once.and_return({})

    instance = ExampleModel.new

    instance.words_gagged?
    instance.email_gagged?
  end

  it 'should cache separate gaggings' do
    mock_engine = mock('engine')
    mock_words = mock('words')
    mock_email = mock('email')
    BallGag.engine = mock_engine

    ExampleModel.gag :words
    ExampleModel.gag :email

    instance = ExampleModel.new
    instance.stub!(words: mock_words, email: mock_email)

    mock_engine.should_receive(:call).
      with(hash_including(words: mock_words), instance).
      once.and_return({})

    mock_engine.should_receive(:call).
      with(hash_including(email: mock_email), instance).
      once.and_return({})

    2.times { instance.words_gagged? }
    2.times { instance.email_gagged? }
  end

  describe 'when clearing gagged attributes' do
    it 'should clear gagged attributes' do
      ExampleModel.gag :words
      ExampleModel.clear_gagged_attributes
      ExampleModel.gagged_attributes.should be_empty
    end

    it 'should remove attribute_not_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to(:words_not_gagged?)
      ExampleModel.clear_gagged_attributes
      ExampleModel.new.should_not respond_to(:words_not_gagged?)
    end

    it 'should remove attribute_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to(:words_gagged?)
      ExampleModel.clear_gagged_attributes
      ExampleModel.new.should_not respond_to(:words_gagged?)
    end
  end

  it 'should add new attribute_gagged? method' do
    ExampleModel.gag :words
    ExampleModel.new.should respond_to :words_gagged?
  end

  it 'should add new attribute_not_gagged? method' do
    ExampleModel.gag :words
    ExampleModel.new.should respond_to :words_not_gagged?
  end

  context 'when gagged with a callable' do
    it 'should check whether the callable object is callable' do
      mock_callable = mock('callable')
      mock_callable.should_receive(:respond_to?).
        with(:call)
      ExampleModel.gag :words, mock_callable
    end

    it 'should call callable when checking whether attribute is gagged' do
      mock_callable = mock('callable')
      mock_callable.stub!(:respond_to?).
        with(:call).and_return(true)

      # Create a mock for this method to verify that original
      # object is passed through to the callable
      mock_words = mock('words')

      ExampleModel.gag :words, mock_callable

      instance = ExampleModel.new
      instance.stub!(words: mock_words)

      mock_callable.should_receive(:call).
        with(hash_including(words: mock_words), instance).
        and_return({})

      instance.words_gagged?
    end

    it 'should call block when checking whether attribute is gagged' do
      a = nil
      b = nil
      ExampleModel.gag :words do |unsanitized_values, instance|
        a = unsanitized_values
        b = instance
        {}
      end
      instance = ExampleModel.new
      attribute_value = instance.words

      instance.words_gagged?

      a.should have_key(:words)
      a[:words].should eq attribute_value

      b.should eq instance
    end

    it 'should forward options to callable' do
      passed_options = nil
      options = { strict: true }
      ExampleModel.gag :words, options do |_, _, options|
        passed_options = options
      end

      ExampleModel.new.words_gagged?
      passed_options.should eq options
    end

    context 'when callable provides true for attribute' do
      before { ExampleModel.gag :words do |*| { words: true } end }

      it 'should return false for attribute_gagged?' do
        ExampleModel.new.words_gagged?.should be_false
      end

      it 'should return true for attribute_not_gagged?' do
        ExampleModel.new.words_not_gagged?.should be_true
      end
    end

    context 'when callable returns true' do
      context 'and a single attribute is gagged' do
        before { ExampleModel.gag :words do |*| true end }

        it 'should return false for attribute_gagged?' do
          ExampleModel.new.words_gagged?.should be_false
        end

        it 'should return true for attribute_not_gagged?' do
          ExampleModel.new.words_not_gagged?.should be_true
        end
      end

      context 'and multiple attributes are gagged' do
        before { ExampleModel.gag :words, :email do |*| true end }

        it 'should raise' do
          -> { ExampleModel.new.words_gagged? }.
            should raise_error(BallGag::BadResultsMappingError)
        end
      end
    end
  end

  context 'when gagged with no arguments' do
    context 'when no engine is configured' do
      it 'should raise when checking whether attribute is gagged' do
        ExampleModel.gag :words
        -> { ExampleModel.new.words_gagged? }.
          should raise_error(BallGag::NoEngineConfiguredError)
      end
    end

    context 'when configured with an engine' do
      it 'should call engine when checking whether attribute is gagged' do
        mock_engine = mock('engine')
        BallGag.engine = mock_engine
        ExampleModel.gag :words

        # Create a mock for this method to verify that original
        # object is passed through to the engine
        mock_words = mock('words')

        instance = ExampleModel.new
        instance.stub!(words: mock_words)

        mock_engine.should_receive(:call).
          with(hash_including(words: mock_words), instance).
          and_return({})

        instance.words_gagged?
      end
    end
  end
end

