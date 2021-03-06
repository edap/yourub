require 'yourub'

describe Yourub::Validator do
  let(:subject) { Yourub::Validator.confirm(criteria) }

  context 'passing an hash containing the search criteria' do
    context 'with some valid criteria' do
      context 'with an old hash syntax' do
        let(:criteria) { { 'country' => 'US', 'category' => 'Sport' } }
        it 'return the criteria in the sym: val format' do
          expect(subject).to eq(country: ['US'], category: 'Sport')
        end
      end

      context 'with valid nation but unknown parameter city' do
        let(:criteria) { { country: 'US', city: 'Berlin' } }
        it 'return criteria including nation but excluding the city' do
          expect(subject).to eq(country: ['US'])
        end
      end

      context 'with an invalid :order value' do
        let(:criteria) { { order: 'banane', query: 'roberto baggio' } }
        it 'raise an argument error' do
          expect(lambda{ subject }).to raise_error(ArgumentError)
        end
      end

      context 'with a given category without a country' do
        let(:criteria) { { country: '', category: 'Sport' } }
        it 'add the default country' do
          expect(subject).to eq(category: 'Sport', :country => ['US'])
        end
      end

      context 'with all the available parameters present' do
        let(:criteria) do
          { country: 'IT',
            category: 'Sport',
            max_results: 2,
            count_filter: {},
            query: ''
          }
        end
        it 'return only them params that has a value' do
          expect(subject).to eq(
            country: ['IT'], category: 'Sport', max_results: 2
          )
        end
      end
    end

    context 'if none of the criteria are valid' do
      context 'with non valid criteria' do
        let(:criteria) { { big: 1, bang: 2 } }
        it 'raise an argument error' do
          expect(lambda{ subject }).to raise_error(ArgumentError)
        end
      end

      context 'with criteria in the wrong format, like a string' do
        let(:criteria) { 'country = US' }
        it 'raise an argument error' do
          expect(lambda{ subject }).to raise_error(ArgumentError)
        end
      end

      context 'with an invalid country' do
        let(:criteria) { { country: 'MOON' } }
        it 'raise an argument error' do
          expect(lambda{ subject }).to raise_error(ArgumentError)
        end
      end
    end

    context 'with valid criteria but not enough to start a search' do
      context 'only with maximum and count filter' do
        let(:criteria) do
          { max_results: 10, count_filter: { views: '>= 100' } }
        end
        it 'raise an argument error' do
          expect(lambda{ subject }).to raise_error(ArgumentError)
        end
      end
    end
  end

  context 'passing a list of available categories and the selected one' do
    let(:subject) { Yourub::Validator.valid_category(categories, selected_one) }
    let(:categories) { [{'10'=>'music'}, {'15'=>'pets&animals'}, {'17'=>'sports'}, {'18'=>'shortmovies'}] }

    context 'with an invalid category' do
      let(:selected_one) {"spaghetti"}
      it 'raise an argument error' do
        expect(lambda{subject}).to raise_error(ArgumentError)
      end
    end

    context 'with a valid category' do
      let(:selected_one) { 'sports' }
      it 'return it' do
        expect(subject.first.has_value? "sports").to eq true
      end
    end
  end
end
