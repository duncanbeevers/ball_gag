require 'spec_helper'

describe ExampleModel do
  before do
    BallGag.engine = nil
    BallGag.verb = nil
    BallGag.preterite = nil
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
    describe 'return values' do
      context 'when callable returns' do
        context 'true' do
          before do
            ExampleModel.gag :words, lambda { |*| true }
          end

          it '#{attribute}_gagged? should be false' do
            ExampleModel.new.words_gagged?.should be_false
          end
          it '#{attribute}_not_gagged? should be true' do
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
          it '#{attribute}_not_gagged? should be false' do
            ExampleModel.new.words_not_gagged?.should be_false
          end
        end
      end
    end

    specify 'callable is called with attribute value' do
      callable = lambda { |words| }
      ExampleModel.gag :words, callable

      mock_words = mock('words')

      callable.should_receive(:call).
        with(mock_words)

      instance = ExampleModel.new
      instance.stub!(words: mock_words)

      instance.words_gagged?
    end

    specify 'callable is called with single: true in options' do
      callable = lambda { |words, options| }
      ExampleModel.gag :words, callable
      callable.should_receive(:call).
        with(anything, hash_including(single: true))
      ExampleModel.new.words_gagged?
    end
  end

  describe 'multiple attributes gagged' do
    describe 'return values' do
      context 'when results map returns true for attribute' do
        before { ExampleModel.gag :words, :email do |*| { words: true } end }

        it 'should return false for #{attribute}_gagged?' do
          ExampleModel.new.words_gagged?.should be_false
        end

        it 'should return true for #{attribute}_not_gagged?' do
          ExampleModel.new.words_not_gagged?.should be_true
        end
      end
    end

    specify 'callable is called with map of attributes' do
      callable = lambda { |map, options| }
      mock_words = mock('words')
      mock_email = mock('email')

      ExampleModel.gag :words, :email, callable
      callable.should_receive(:call).
        with(
          hash_including(words: mock_words, email: mock_email), anything).
        and_return({})

      instance = ExampleModel.new
      instance.stub!(words: mock_words, email: mock_email)
      instance.words_gagged?
    end

    specify 'callable is called with attr in options' do
      callable = lambda { |map, options| }
      ExampleModel.gag :words, :email, callable

      callable.should_receive(:call).
        with(anything, hash_including(attr: :words)).
        and_return({})
      ExampleModel.new.words_gagged?

      callable.should_receive(:call).
        with(anything, hash_including(attr: :email)).
        and_return({})
      ExampleModel.new.email_gagged?
    end

    specify 'callable is called with single: false in options' do
      callable = lambda { |map, options| }
      ExampleModel.gag :words, :email, callable
      callable.should_receive(:call).
        with(anything, hash_including(single: false)).
        and_return({})
      ExampleModel.new.words_gagged?
    end
  end

  describe 'callable options' do
    specify 'instance is in options' do
      callable = lambda { |words, options| }
      ExampleModel.gag :words, callable

      instance = ExampleModel.new
      callable.should_receive(:call).
        with(anything, hash_including(instance: instance))

      instance.words_gagged?
    end

    specify 'attr is in options' do
      callable = lambda { |words, options| }
      ExampleModel.gag :words, callable
      callable.should_receive(:call).
        with(anything, hash_including(attr: :words))

      ExampleModel.new.words_gagged?
    end

    specify 'gag options are in options' do
      callable = lambda { |words, options| }
      mock_options = mock('options')
      mock_options.stub(:kind_of?).
        with(Hash).and_return(true)

      ExampleModel.gag :words, mock_options, callable
      callable.should_receive(:call).
        with(anything, hash_including(options: mock_options))

      ExampleModel.new.words_gagged?
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
      callable = lambda { |words, instance| }
      mock_words = mock('words')
      mock_email = mock('email')

      ExampleModel.gag :words, callable
      ExampleModel.gag :email, callable

      instance = ExampleModel.new
      instance.stub!(words: mock_words, email: mock_email)

      callable.should_receive(:call).
        with(mock_words, anything).
        once

      callable.should_receive(:call).
        with(mock_email, anything).
        once

      2.times { instance.words_gagged? }
      2.times { instance.email_gagged? }
    end

    it 'can invalidate cache' do
      callable = lambda {}
      mock_words = mock('words')
      ExampleModel.gag :words, callable


      instance = ExampleModel.new
      instance.stub!(words: mock_words)
      callable.should_receive(:call).
        with(mock_words, anything).
        exactly(2).times

      instance.words_gagged?

      instance.invalidate_gag_cache([:words])

      instance.words_gagged?
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

