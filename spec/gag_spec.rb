require 'spec_helper'

describe ExampleModel do
  before do
    BallGag.engine = nil
    ExampleModel.clear_gagged_attributes
  end

  describe '#gag' do
    it 'should add #{attribute}_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to :words_gagged?
    end

    it 'should add #{attribute}_not_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to :words_not_gagged?
    end
  end

  describe '#gagged_attributes' do
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
  end

  describe '#clear_gagged_attributes' do
    it 'should clear gagged attributes' do
      ExampleModel.gag :words
      ExampleModel.clear_gagged_attributes
      ExampleModel.gagged_attributes.should be_empty
    end

    it 'should remove #{attribute}_not_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to(:words_not_gagged?)
      ExampleModel.clear_gagged_attributes
      ExampleModel.new.should_not respond_to(:words_not_gagged?)
    end

    it 'should remove #{attribute}_gagged? method' do
      ExampleModel.gag :words
      ExampleModel.new.should respond_to(:words_gagged?)
      ExampleModel.clear_gagged_attributes
      ExampleModel.new.should_not respond_to(:words_gagged?)
    end
  end

  describe 'single attribute gagged' do
    context 'when callable returns' do
      context 'true' do
        before do
          ExampleModel.gag :words, lambda { |*| true }
        end

        it '#{attribute}_gagged? should be false' do
          ExampleModel.new.words_gagged?.should be_false
        end
        it '#{attribute}_gagged? should be true' do
          ExampleModel.new.words_not_gagged?.should be_true
        end
      end

      context 'false' do
        before do
          ExampleModel.gag :words, lambda { |*| false }
        end

        it '#{attribute}_gagged? should be true' do
          ExampleModel.new.words_gagged?.should be_true
        end
        it '#{attribute}_gagged? should be false' do
          ExampleModel.new.words_not_gagged?.should be_false
        end
      end
    end

    context 'when callable is of arity 1' do
      it 'callable is called without instance' do
        mock_words = mock('words')

        callable = lambda { |words| }
        ExampleModel.gag :words, callable

        callable.should_receive(:call).
          with(hash_including(words: mock_words))

        instance = ExampleModel.new
        instance.stub!(words: mock_words)

        instance.words_gagged?
      end
    end
  end

  describe 'multiple attributes gagged' do
    context 'when results map returns true for attribute' do
      before { ExampleModel.gag :words do |*| { words: true } end }

      it 'should return false for #{attribute}_gagged?' do
        ExampleModel.new.words_gagged?.should be_false
      end

      it 'should return true for #{attribute}_not_gagged?' do
        ExampleModel.new.words_not_gagged?.should be_true
      end
    end
  end

  context 'when gagged with no callable' do
    it 'should call engine when one is configured' do
      BallGag.engine = lambda { |unsanitized_attributes, instance| }
      ExampleModel.gag :words

      BallGag.engine.should_receive(:call)
      ExampleModel.new.words_gagged?
    end
  end

  context 'when gagged with a callable object' do
    it 'should check if object is callable' do
      callable = {}
      callable.should_receive(:respond_to?).with(:call)
      ExampleModel.gag :words, callable
    end
  end

  context 'when gagged with a block' do
    it 'should call block when checking whether attribute is gagged' do
      a = nil
      b = nil
      ExampleModel.gag :words do |unsanitized_values, instance|
        a = unsanitized_values
        b = instance
      end
      instance = ExampleModel.new
      attribute_value = instance.words

      instance.words_gagged?

      a.should have_key(:words)
      a[:words].should eq attribute_value

      b.should eq instance
    end
  end

  context 'when gagged with a lambda' do
    it 'should call lambda' do
      callable = lambda {}
      ExampleModel.gag :words, callable

      callable.should_receive(:call)
      ExampleModel.new.words_gagged?
    end

    it 'should call callable when checking whether attribute is gagged' do
      callable = lambda {}

      # Create a mock for this method to verify that original
      # object is passed through to the callable
      mock_words = mock('words')

      ExampleModel.gag :words, callable

      instance = ExampleModel.new
      instance.stub!(words: mock_words)

      callable.should_receive(:call).
        with(hash_including(words: mock_words), instance)

      instance.words_gagged?
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
  end

  context 'when multiple attributes are gagged' do
    it 'should invoke callable with all attributes and instance' do
      callable = lambda {}
      ExampleModel.gag :words, :email, callable

      instance = ExampleModel.new

      mock_words = mock('words')
      mock_email = mock('email')
      instance.stub!(words: mock_words, email: mock_email)

      callable.should_receive(:call).with(
        hash_including(words: mock_words, email: mock_email), instance).
        and_return({})

      instance.words_gagged?
    end
  end

  describe 'callable result caching' do
    it 'should cache the result of the callable' do
      callable = lambda {}
      ExampleModel.gag :words, callable

      callable.should_receive(:call).once

      instance = ExampleModel.new
      2.times { instance.words_gagged? }
    end

    it 'should separate invocations and cache results' do
      callable = lambda {}
      mock_words = mock('words')
      mock_email = mock('email')

      ExampleModel.gag :words, callable
      ExampleModel.gag :email, callable

      instance = ExampleModel.new
      instance.stub!(words: mock_words, email: mock_email)

      callable.should_receive(:call).
        with({words: mock_words}, instance).
        once

      callable.should_receive(:call).
        with({email: mock_email}, instance).
        once

      2.times { instance.words_gagged? }
      2.times { instance.email_gagged? }
    end
  end

  describe 'error cases' do
    context 'when gagged with no callable and no engine is configured' do
      it 'should raise when gag is checekd' do
        ExampleModel.gag :words

        -> { ExampleModel.new.words_gagged? }.
          should raise_error(BallGag::NoEngineConfiguredError)
      end
    end

    context 'when multiple attributes are gagged' do
      it 'should raise if callable returns non-map result' do
        mock_result = mock('result')

        mock_result.should_receive(:respond_to?).
          with(:[]).and_return(false)

        callable = lambda { |*| mock_result }
        ExampleModel.gag :words, :email, callable

        -> { ExampleModel.new.words_gagged? }.
          should raise_error(BallGag::BadResultsMappingError)
      end
    end
  end
end

